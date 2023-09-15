module "security_vpc" {
  source  = "PaloAltoNetworks/vmseries-modules/aws//modules/vpc"
  version = "1.0.6"

  create_vpc              = var.create_vpc
  name                    = "${var.name_prefix}${var.security_vpc_name}"
  cidr_block              = var.security_vpc_cidr
  security_groups         = var.security_vpc_security_groups
  secondary_cidr_blocks   = var.secondary_cidr_blocks
  create_internet_gateway = true
  enable_dns_hostnames    = true
  enable_dns_support      = true
  instance_tenancy        = "default"
}

### NATGW ###
#module "natgw_set" {
#  # This also a "set" and it means the same thing: we will repeat a nat gateway for each subnet (of the subnet_set).
#  source  = "PaloAltoNetworks/vmseries-modules/aws//modules/nat_gateway_set"
#  version = "0.2.0"

#  subnets = module.security_subnet_sets[var.security_subnet_natgw_name].subnets
#}

module "security_subnet_sets" {
  # The "set" here means we will repeat in each AZ an identical/similar subnet.
  # The notion of "set" is used a lot here, it extends to nat gateways, routes, routes' next hops,
  # gwlb endpoints and any other resources which would be a single point of failure when placed
  # in a single AZ.
  for_each = toset(distinct([for _, v in var.security_vpc_subnets : v.set]))
  source   = "PaloAltoNetworks/vmseries-modules/aws//modules/subnet_set"
  version  = "1.0.6"

  name                = each.key
  vpc_id              = module.security_vpc.id
  has_secondary_cidrs = module.security_vpc.has_secondary_cidrs
  cidrs               = { for k, v in var.security_vpc_subnets : k => v if v.set == each.key }
}

### TGW ###

module "transit_gateway" {
  source  = "PaloAltoNetworks/vmseries-modules/aws//modules/transit_gateway"
  version = "1.0.6"

  create = var.create_tgw

  name         = "${var.name_prefix}${var.transit_gateway_name}"
  asn          = var.transit_gateway_asn
  route_tables = var.transit_gateway_route_tables
}

module "security_transit_gateway_attachment" {
  source  = "PaloAltoNetworks/vmseries-modules/aws//modules/transit_gateway_attachment"
  version = "1.0.6"

  name                        = "${var.name_prefix}${var.security_vpc_tgw_attachment_name}"
  vpc_id                      = module.security_subnet_sets[var.security_subnet_transit_name].vpc_id
  subnets                     = module.security_subnet_sets[var.security_subnet_transit_name].subnets
  transit_gateway_route_table = module.transit_gateway.route_tables["from_security_vpc"]
  propagate_routes_to = {
    #    to1 = module.transit_gateway.route_tables["from_spoke_vpc"].id
  }
}

#resource "aws_ec2_transit_gateway_route" "from_spokes_to_security" {
#  transit_gateway_route_table_id = module.transit_gateway.route_tables["from_spoke_vpc"].id
#  # Next hop.
#  transit_gateway_attachment_id = module.security_transit_gateway_attachment.attachment.id
#  # Default to inspect all packets coming through TGW route table from_spoke_vpc:
#  destination_cidr_block = "0.0.0.0/0"
#  blackhole              = false
#}

### GWLB ###

module "security_gwlb" {
  source  = "PaloAltoNetworks/vmseries-modules/aws//modules/gwlb"
  version = "1.0.6"

  name    = "${var.name_prefix}${var.gwlb_name}"
  vpc_id  = module.security_subnet_sets[var.security_subnet_gwlb_name].vpc_id
  subnets = module.security_subnet_sets[var.security_subnet_gwlb_name].subnets

  target_instances = { for k, v in module.vmseries : k => { id = v.instance.id } }
}

module "gwlbe_eastwest" {
  source  = "PaloAltoNetworks/vmseries-modules/aws//modules/gwlb_endpoint_set"
  version = "1.0.6"

  name              = "${var.name_prefix}${var.gwlb_endpoint_set_eastwest_name}"
  gwlb_service_name = module.security_gwlb.endpoint_service.service_name
  vpc_id            = module.security_subnet_sets[var.security_subnet_gwlbe_eastwest_name].vpc_id
  subnets           = module.security_subnet_sets[var.security_subnet_gwlbe_eastwest_name].subnets
}

module "gwlbe_outbound" {
  source  = "PaloAltoNetworks/vmseries-modules/aws//modules/gwlb_endpoint_set"
  version = "1.0.6"

  name              = "${var.name_prefix}${var.gwlb_endpoint_set_outbound_name}"
  gwlb_service_name = module.security_gwlb.endpoint_service.service_name
  vpc_id            = module.security_subnet_sets[var.security_subnet_gwlbe_outbound_name].vpc_id
  subnets           = module.security_subnet_sets[var.security_subnet_gwlbe_outbound_name].subnets
}


locals {
  security_vpc_routes = concat(
    [for cidr in var.security_vpc_routes_outbound_destin_cidrs :
      {
        subnet_key   = var.security_subnet_mgmt_name
        next_hop_set = module.security_vpc.igw_as_next_hop_set
        to_cidr      = cidr
      }
    ],
    [for cidr in concat(var.security_vpc_routes_eastwest_cidrs, var.security_vpc_mgmt_routes_to_tgw) :
      {
        subnet_key   = var.security_subnet_mgmt_name
        next_hop_set = module.security_transit_gateway_attachment.next_hop_set
        to_cidr      = cidr
      }
    ],
    [for cidr in var.security_vpc_routes_eastwest_cidrs :
      {
        subnet_key   = var.security_subnet_transit_name
        next_hop_set = module.gwlbe_eastwest.next_hop_set
        to_cidr      = cidr
      }
    ],
    [for cidr in var.security_vpc_routes_outbound_destin_cidrs :
      {
        subnet_key   = var.security_subnet_transit_name
        next_hop_set = module.gwlbe_outbound.next_hop_set
        to_cidr      = cidr
      }
    ],
    #    [for cidr in var.security_vpc_routes_outbound_destin_cidrs :
    #      {
    #        subnet_key   = var.security_subnet_gwlbe_outbound_name
    #        next_hop_set = module.natgw_set.next_hop_set
    #        to_cidr      = cidr
    #      }
    #    ],
    [for cidr in var.security_vpc_routes_outbound_source_cidrs :
      {
        subnet_key   = var.security_subnet_gwlbe_outbound_name
        next_hop_set = module.security_transit_gateway_attachment.next_hop_set
        to_cidr      = cidr
      }
    ],
    [for cidr in var.security_vpc_routes_eastwest_cidrs :
      {
        subnet_key   = var.security_subnet_gwlbe_eastwest_name
        next_hop_set = module.security_transit_gateway_attachment.next_hop_set
        to_cidr      = cidr
      }
    ],
    #    [for cidr in var.security_vpc_routes_outbound_destin_cidrs :
    #      {
    #        subnet_key   = var.security_subnet_natgw_name
    #        next_hop_set = module.security_vpc.igw_as_next_hop_set
    #        to_cidr      = cidr
    #      }
    #    ],
    #    [for cidr in var.security_vpc_routes_outbound_source_cidrs :
    #      {
    #        subnet_key   = var.security_subnet_natgw_name
    #        next_hop_set = module.gwlbe_outbound.next_hop_set
    #        to_cidr      = cidr
    #      }
    #    ],
  )
}

module "security_vpc_routes" {
  for_each = { for route in local.security_vpc_routes : "${route.subnet_key}_${route.to_cidr}" => route }
  source   = "PaloAltoNetworks/vmseries-modules/aws//modules/vpc_route"
  version  = "1.0.6"

  route_table_ids = module.security_subnet_sets[each.value.subnet_key].unique_route_table_ids
  to_cidr         = each.value.to_cidr
  next_hop_set    = each.value.next_hop_set
}

#module "s3_vpc_endpoint" {
#  source = "PaloAltoNetworks/vmseries-modules/aws//modules/vpc_endpoint"
#  version = "0.2.0"
#
#  name                = var.s3_endpoint_name
#  simple_service_name = "s3"
#  type                = var.s3_endpoint_type
#  vpc_id              = module.security_vpc.id

# The "Gateway" endpoint accepts identifiers of route tables instead of subnets.
#  route_table_ids = module.security_subnet_sets[var.security_subnet_mgmt_name].unique_route_table_ids
#}
