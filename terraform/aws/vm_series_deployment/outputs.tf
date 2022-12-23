output "subnets" {
  value = module.security_subnet_sets
}

/*
output "subnet_names" {
  value = { for k, v in module.panorama_subnet_sets : k => try(v.tags.Name, null) }
}

output "security_group_ids" {
  value = { for k, v in module.panorama_vpc.security_group_ids : k => try(v, null) }
}

output "app1_inspected_public_ip" {
  value = aws_eip.this.public_ip
}
*/

##### Security VPC #####

output "security_gwlb_service_name" {
  description = "The AWS Service Name of the created GWLB, which is suitable to use for subsequent VPC Endpoints."
  value       = module.security_gwlb.endpoint_service.service_name
}
