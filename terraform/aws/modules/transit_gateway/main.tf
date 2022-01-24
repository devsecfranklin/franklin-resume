################
# Locals to combine data source and resource references for optional browfield support
################


locals {
  transit_gateway              = var.create ? try(aws_ec2_transit_gateway.this[0], null) : try(data.aws_ec2_transit_gateway.this[0], null)
  transit_gateway_route_tables = { for k, v in var.route_tables : k => v.create ? try(aws_ec2_transit_gateway_route_table.this[k], null) : try(data.aws_ec2_transit_gateway_route_table.this[k], null) }
}

#### Transit Gateways #### 

data "aws_ec2_transit_gateway" "this" {
  count = var.create == false ? 1 : 0

  filter {
    name   = "tag:Name"
    values = [var.name]
  }
}

variable "create" { default = true }
variable "name" {}
variable "shared_principals" { default = {} }
variable "asn" { default = 65200 }
variable "route_tables" {

}

resource "aws_ec2_transit_gateway" "this" {
  count = var.create ? 1 : 0

  amazon_side_asn                 = var.asn
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags                            = merge(var.tags, { Name = var.name })
}

#### Route Tables ####

data "aws_ec2_transit_gateway_route_table" "this" {
  for_each = { for k, v in var.route_tables : k => v if v.create == false }

  filter {
    name   = "tag:Name"
    values = [each.value.name]
  }
}

resource "aws_ec2_transit_gateway_route_table" "this" {
  for_each = { for k, v in var.route_tables : k => v if v.create }

  transit_gateway_id = local.transit_gateway.id
  tags               = merge(var.tags, lookup(each.value, "local_tags", {}), { Name = coalesce(lookup(each.value, "name", ""), var.name) })
}

output "route_tables" {
  value = local.transit_gateway_route_tables
}

##########################
# Resource Shares for TGWs
##########################

# Create Resource Share if 'shared_principals' key is defined
resource "aws_ram_resource_share" "this" {
  count = length(var.shared_principals) != 0 ? 1 : 0

  name                      = coalesce(var.ram_resource_share_name, var.name)
  tags                      = merge(var.tags, { Name = coalesce(var.ram_resource_share_name, var.name) })
  allow_external_principals = true
}

# Associate TGW to Share
resource "aws_ram_resource_association" "this" {
  count = length(var.shared_principals) != 0 ? 1 : 0

  resource_arn       = local.transit_gateway.arn
  resource_share_arn = aws_ram_resource_share.this[0].arn
}

# Loop through list of accounts to associate with each share
resource "aws_ram_principal_association" "this" {
  for_each = var.shared_principals

  principal          = each.value
  resource_share_arn = aws_ram_resource_share.this[0].arn
}


##########################
# Create TGW Cross Region Peering
##########################

# provider "aws" {
#   alias  = "tgw_peer"
#   region = var.transit_gateway_peer_region
# }

variable "transit_gateway_peerings" {
  type        = map(any)
  description = "Map of parameters to peer TGWs with cross-region / cross-account existing TGW"
  default     = {}
}

variable "transit_gateway_peer_region" {
  type        = string
  description = "Region for alias provider for Transit Gateway Peering"
  default     = ""
}

variable "ram_resource_share_name" { default = null }
# resource "aws_ec2_transit_gateway_peering_attachment" "this" {
#   for_each                = var.transit_gateway_peerings
#   peer_account_id         = each.value.peer_account_id
#   peer_region             = each.value.peer_region
#   peer_transit_gateway_id = each.value.peer_transit_gateway_id
#   transit_gateway_id      = aws_ec2_transit_gateway.this[each.key].id

#   tags = merge({ Name = "${var.prefix_name_tag}${each.value.name}" }, var.tags, lookup(each.value, "local_tags", {}))
# }

# resource "aws_ec2_transit_gateway_peering_attachment_accepter" "this" {
#   provider                      = aws.tgw_peer
#   for_each                      = var.transit_gateway_peerings
#   transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.this[each.key].id

#   tags = merge({ Name = "${var.prefix_name_tag}${each.value.name}" }, var.tags, lookup(each.value, "local_tags", {}))
# }

# resource "aws_ec2_transit_gateway_route_table_association" "tgw_peer_local" {
#   for_each                       = var.transit_gateway_peerings
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.this[each.key].id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this[each.value.tgw_rt_association].id
# }

# resource "aws_ec2_transit_gateway_route_table_association" "tgw_peer_remote" {
#   provider                       = aws.tgw_peer
#   for_each                       = var.transit_gateway_peerings
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.this[each.key].id
#   transit_gateway_route_table_id = each.value.peer_tgw_rt_association
# }
