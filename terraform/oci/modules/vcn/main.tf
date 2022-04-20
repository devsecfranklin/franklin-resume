# Virtual Cloud Network
data "oci_core_vcn" "this" {
  count  = var.create_vcn ? 0 : 1
  vcn_id = var.vcn_id
}

resource "oci_core_vcn" "this" {
  count          = var.create_vcn ? 1 : 0
  compartment_id = var.compartment
  cidr_blocks    = var.cidr_blocks
  display_name   = var.virtual_network_name
  freeform_tags  = var.tags
  dns_label      = var.dns_label
}

locals {
  vcn_id = try(oci_core_vcn.this[0].id, data.oci_core_vcn.this[0].id)
}

# Create Internet Gateway
resource "oci_core_internet_gateway" "this" {
  count          = var.create_igw ? 1 : 0
  compartment_id = var.compartment
  vcn_id         = local.vcn_id
  display_name   = coalesce(var.internet_gateway_name, "${var.virtual_network_name}-igw")
  enabled        = true
}

# Peering
resource "oci_core_local_peering_gateway" "this" {
  for_each = { for k, v in var.peerings : k => v }

  compartment_id = var.compartment
  vcn_id         = local.vcn_id
  display_name   = each.key
  freeform_tags  = var.tags
  peer_id        = try(each.value.peer_id, null)
}

# Create Route Tables
resource "oci_core_route_table" "this" {
  for_each = var.route_tables

  compartment_id = var.compartment
  vcn_id         = local.vcn_id
  freeform_tags  = var.tags
  display_name   = each.key

  // igw
  dynamic "route_rules" {
    for_each = merge(

      { for k, v in each.value.routes : k => {
        cidr_block = v.cidr_block
        dst        = oci_core_internet_gateway.this[0].id
        }
        if v.next_hop_type == "igw"
      },

      { for k, v in each.value.routes : k => {
        cidr_block = v.cidr_block
        dst        = var.drg_id
        }
        if v.next_hop_type == "drg"
      },

      { for k, v in var.peerings : k => {
        cidr_block = v.cidr_block
        dst        = oci_core_local_peering_gateway.this[k].id
        }
        if v.route_table == each.key
      }

    )
    content {
      network_entity_id = route_rules.value.dst
      destination       = route_rules.value.cidr_block
    }
  }

  // TODO - support for other route types
}

# Subnets
data "oci_core_subnet" "this" {
  for_each = { for k, v in var.subnets : k => v if lookup(v, "create", true) == true ? false : true }

  subnet_id = each.value.id
}

resource "oci_core_subnet" "this" {
  for_each = { for k, v in var.subnets : k => v if lookup(v, "create", true) == true ? true : false }

  compartment_id             = var.compartment
  vcn_id                     = local.vcn_id
  freeform_tags              = var.tags
  cidr_block                 = each.value.cidr_block
  display_name               = each.key
  route_table_id             = oci_core_route_table.this[each.value.route_table].id
  security_list_ids          = [oci_core_security_list.this[each.value.security_list].id]
  prohibit_public_ip_on_vnic = try(each.value.private, false)
  dns_label                  = try(each.value.dns_label, null)

  # dhcp_options_id = oci_core_dhcp_options.this.id // TODO - implement (or skip)

  # without this parameter, regional subnet will be created
  # are we going to support AD-specific subnets?
  # https://docs.oracle.com/en-us/iaas/releasenotes/changes/08c01d20-c829-47f2-8d54-9e9958f50ba8/
  # availability_domain = var.subnet_availability_domain
}

resource "oci_core_drg_attachment" "this" {
  count = var.use_drg ? 1 : 0
  # count = var.drg_id == null ? 0 : 1

  drg_id        = var.drg_id
  freeform_tags = var.tags
  display_name  = var.virtual_network_name

  # drg_route_table_id = lookup(each.value, "drg_route_table", null) == null ? null : oci_core_drg_route_table.this[each.value.drg_route_table].id
  network_details {
    id   = local.vcn_id
    type = "VCN"
    # route_table_id = oci_core_route_table.test_route_table.id
    # vcn_route_type = var.drg_attachment_network_details_vcn_route_type
  }
}

resource "oci_core_security_list" "this" {
  for_each = var.security_lists

  compartment_id = var.compartment
  vcn_id         = local.vcn_id
  freeform_tags  = var.tags
  display_name   = each.key

  dynamic "egress_security_rules" {
    for_each = each.value.egress_rules
    content {
      description = egress_security_rules.key
      protocol    = egress_security_rules.value.protocol
      destination = egress_security_rules.value.destination
      stateless   = try(egress_security_rules.value.stateless, false)
      # destination_type = var.security_list_egress_security_rules_destination_type

      dynamic "tcp_options" {
        for_each = egress_security_rules.value.protocol == 6 ? ["tcp"] : []
        content {
          min = egress_security_rules.value.destination_port != "*" ? egress_security_rules.value.destination_port : 1
          max = egress_security_rules.value.destination_port != "*" ? egress_security_rules.value.destination_port : 65535
        }
      }

      dynamic "udp_options" {
        for_each = egress_security_rules.value.protocol == 17 ? ["udp"] : []
        content {
          min = egress_security_rules.value.destination_port != "*" ? egress_security_rules.value.destination_port : 1
          max = egress_security_rules.value.destination_port != "*" ? egress_security_rules.value.destination_port : 65535
        }
      }

    }
  }

  dynamic "ingress_security_rules" {
    for_each = each.value.ingress_rules
    content {
      description = ingress_security_rules.key
      protocol    = ingress_security_rules.value.protocol
      source      = ingress_security_rules.value.source
      stateless   = try(ingress_security_rules.value.stateless, false)
      # source_type = var.security_list_ingress_security_rules_source_type

      dynamic "tcp_options" {
        for_each = ingress_security_rules.value.protocol == 6 ? ["tcp"] : []
        content {
          min = ingress_security_rules.value.destination_port != "*" ? ingress_security_rules.value.destination_port : 1
          max = ingress_security_rules.value.destination_port != "*" ? ingress_security_rules.value.destination_port : 65535
        }
      }

      dynamic "udp_options" {
        for_each = ingress_security_rules.value.protocol == 17 ? ["udp"] : []
        content {
          min = ingress_security_rules.value.destination_port != "*" ? ingress_security_rules.value.destination_port : 1
          max = ingress_security_rules.value.destination_port != "*" ? ingress_security_rules.value.destination_port : 65535
        }
      }

    }
  }
}
