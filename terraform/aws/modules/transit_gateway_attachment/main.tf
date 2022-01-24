resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  vpc_id                                          = var.subnet_set.vpc_id
  subnet_ids                                      = [for _, subnet in var.subnet_set.subnets : subnet.id]
  transit_gateway_id                              = var.transit_gateway_route_table.transit_gateway_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  appliance_mode_support                          = var.appliance_mode_support
  tags                                            = merge(var.tags, var.name != null ? { Name = var.name } : {})
}

variable "transit_gateway_route_table" {
  type = object({
    id                 = string
    transit_gateway_id = string
  })
}

variable "subnet_set" {
  description = "The subnets set where the Attachment will be placed. The aws_ec2_transit_gateway_vpc_attachment does not support multiple subnet sets."
  type = object({
    vpc_id = string
    subnets = map(
      object({ id = string })
    )
  })
}

variable "tags" {
  default = {}
}

variable "name" {}

variable "appliance_mode_support" {
  default = "enable"
}

output "subnet_set" {
  description = "Same as the input `subnet_set`. Intended to be used as a dependency."
  value       = contains(aws_ec2_transit_gateway_vpc_attachment.this.subnet_ids, "!") == false ? var.subnet_set : null
}

output "next_hop_set" {
  value = {
    type = "transit_gateway"
    id   = aws_ec2_transit_gateway_vpc_attachment.this.transit_gateway_id
    ids  = {}
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "this" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = var.transit_gateway_route_table.id
}
