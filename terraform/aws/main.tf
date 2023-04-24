
resource "aws_ec2_managed_prefix_list" "mgmt_ips" {
  name           = "${var.name} public permitted incoming IPs"
  address_family = "IPv4"
  max_entries    = 20

  dynamic "entry" {
    for_each = var.mgmt_ips
    content {
      cidr        = entry.value.cidr
      description = entry.value.description
    }
  }
}


resource "aws_ec2_managed_prefix_list_entry" "natgw" {
  provider       = aws.base
  for_each       = module.vpc_eks.nat_gateways
  cidr           = "${each.value.public_ip}/32"
  prefix_list_id = var.pl-mgmt-csp_nat_ips
  description    = "aws-${var.name}-natgw-${each.key}"
}