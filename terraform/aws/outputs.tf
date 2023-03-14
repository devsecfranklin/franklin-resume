
############
# Instance #
############
output "aws_instance_id" {
  value = aws_instance.jump.id
}
output "aws_instance_arn" {
  value = aws_instance.jump.arn
}
output "aws_instance_availability_zone" {
  value = aws_instance.jump.availability_zone
}
output "aws_instance_placement_group" {
  value = aws_instance.jump.placement_group
}
output "aws_instance_key_name" {
  value = aws_instance.jump.key_name
}
output "aws_instance_password_data" {
  value = aws_instance.jump.password_data
}
output "aws_instance_public_dns" {
  value = aws_instance.jump.public_dns
}
output "aws_instance_public_ip" {
  value = aws_instance.jump.public_ip
}
output "aws_instance_ipv6_addresses" {
  value = aws_instance.jump.ipv6_addresses
}
output "aws_instance_primary_network_interface_id" {
  value = aws_instance.jump.primary_network_interface_id
}
output "aws_instance_private_dns" {
  value = aws_instance.jump.private_dns
}
output "aws_instance_private_ip" {
  value = aws_instance.jump.private_ip
}
output "aws_instance_security_groups" {
  value = aws_instance.jump.security_groups
}
output "aws_instance_vpc_security_group_ids" {
  value = aws_instance.jump.vpc_security_group_ids
}
output "aws_instance_subnet_id" {
  value = aws_instance.jump.subnet_id
}
output "aws_instance_credit_specification" {
  value = aws_instance.jump.credit_specification
}

##################
# Security group #
##################
output "aws_security_group_id" {
  value = aws_security_group.jump.id
}
output "aws_security_group_arn" {
  value = aws_security_group.jump.arn
}
output "aws_security_group_vpc_id" {
  value = aws_security_group.jump.vpc_id
}
output "aws_security_group_owner_id" {
  value = aws_security_group.jump.owner_id
}
output "aws_security_group_name" {
  value = aws_security_group.jump.name
}
output "aws_security_group_description" {
  value = aws_security_group.jump.description
}
output "aws_security_group_ingress" {
  value = aws_security_group.jump.ingress
}
output "aws_security_group_egress" {
  value = aws_security_group.jump.egress
}

##############
# Elastic IP #
##############
output "aws_eip_id" {
  value = aws_eip.jump.id
}
output "aws_eip_private_ip" {
  value = aws_eip.jump.private_ip
}
output "aws_eip_private_dns" {
  value = aws_eip.jump.private_dns
}
output "aws_eip_associate_with_private_ip" {
  value = aws_eip.jump.associate_with_private_ip
}
output "aws_eip_public_ip" {
  value = aws_eip.jump.public_ip
}
output "aws_eip_public_dns" {
  value = aws_eip.jump.public_dns
}
output "aws_eip_instance" {
  value = aws_eip.jump.instance
}
output "aws_eip_network_interface" {
  value = aws_eip.jump.network_interface
}
output "aws_eip_public_ipv4_pool" {
  value = aws_eip.jump.public_ipv4_pool
}