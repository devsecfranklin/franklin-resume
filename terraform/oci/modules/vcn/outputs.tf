output "virtual_network_id" {
  description = "The identifier of the Virtual Network."
  # value       = oci_core_vcn.this[0].id
  value = local.vcn_id
}

output "subnet_ids" {
  description = "The identifiers of the created Subnets."
  value       = merge({ for k, v in oci_core_subnet.this : k => v.id }, { for k, v in data.oci_core_subnet.this : k => v.id })
}

output "security_list_ids" {
  description = "The identifiers of the created Security Lists."
  value       = { for k, v in oci_core_security_list.this : k => v.id }
}

output "route_table_ids" {
  description = "The identifiers of the created Route Tables."
  value       = { for k, v in oci_core_route_table.this : k => v.id }
}

output "internet_gateway_id" {
  description = "The identifier of the created Internet Gateway (or 'null' if not created)."
  value       = var.create_igw ? oci_core_internet_gateway.this[0].id : null
}

output "peering_ids" {
  description = "The identifiers of the created Peerings."
  value       = { for k, v in oci_core_local_peering_gateway.this : k => v.id }
}