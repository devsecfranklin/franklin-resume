# TODOs

TODO: new name gwlbe_set

TODO: in single_vpc it turned out that secondary cidrs don't work, so a second apply is needed as a temp workaround

TOTHINK: how is next hop set compatible with various scenarios of inbound LB: single vpc, gwlb common, gwlb uncommon, old tgw?

TODO: examples/vpc_endpoints

```hcl2

### vpc_endpoints

The `vpc_endpoints` variable is a map of maps, where each map represents a VPC Endpoint. Supports both interface and gateway endpoint types.

There is no brownfield support yet for this resource type.

Each vpc_endpoints map has the following inputs available (please see examples folder for additional references):

[Provider's manual](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) for the `aws_vpc_endpoint` resource.

| Name | Description | Type | Default | Required | Brownfield Required
|------|-------------|:----:|:-----:|:-----:|:-----:|
| name | The Name Tag of the new VPC Endpoint to create | string | - | yes | n/a |
| service_name | AWS Service Name in format `com.amazonaws.<region>.<service>` | string | - | yes | n/a |
| vpc_endpoint_type | "Interface" or "Gateway" | string | - | yes | n/a |
| security_groups | "Interface" type only. List of security groups to associate (using terraform resource identifier key) | list(string) | - | yes (for "Interface" type) | n/a |
| subnet_ids | "Interface" type only. List of subnets to associate (using terraform resource identifier key) | list(string) | - | no | n/a |
| route_table_ids | "Gateway" type only. List of route tables to associate (using terraform resource identifier key) | list(string) | - | no | n/a |
| local_tags  | Map of aribrary tags key/value pairs to apply to this resource | map | - | no | n/a |

############################################################
# VPC Endpoints
############################################################

locals {
  vpc_endpoints_i = { for k, v in var.vpc_endpoints : k => v.create ? try(aws_vpc_endpoint.interface[k], null) : try(data.aws_vpc_endpoint.interface[k], null)
    if v.vpc_endpoint_type == "Interface"
  }
  vpc_endpoints_g = { for k, v in var.vpc_endpoints : k => v.create ? try(aws_vpc_endpoint.gateway[k], null) : try(data.aws_vpc_endpoint.gateway[k], null)
    if v.vpc_endpoint_type == "Gateway"
  }
  # Each entry of the input goes into one of four choices:
  existing_vpc_endpoints_i = {
    for k, v in var.vpc_endpoints : k => v
    if v.vpc_endpoint_type == "Interface" && v.create == false
  }
  create_vpc_endpoints_i = {
    for k, v in var.vpc_endpoints : k => v
    if v.vpc_endpoint_type == "Interface" && v.create == true
  }
  existing_vpc_endpoints_g = {
    for k, v in var.vpc_endpoints : k => v
    if v.vpc_endpoint_type == "Gateway" && v.create == false
  }
  create_vpc_endpoints_g = {
    for k, v in var.vpc_endpoints : k => v
    if v.vpc_endpoint_type == "Gateway" && v.create == true
  }
}

data "aws_vpc_endpoint" "interface" {
  for_each = local.existing_vpc_endpoints_i

  service_name = each.value.service_name
  tags         = { Name = each.value.name }
}

resource "aws_vpc_endpoint" "interface" {
  for_each = local.create_vpc_endpoints_i

  vpc_id              = var.vpc.id
  service_name        = each.value.service_name
  vpc_endpoint_type   = each.value.vpc_endpoint_type
  auto_accept         = lookup(each.value, "auto_accept", null)
  policy              = lookup(each.value, "policy", null)
  private_dns_enabled = lookup(each.value, "private_dns_enabled", null)
  security_group_ids  = each.value.security_group_ids
  tags                = merge(var.global_tags, lookup(each.value, "local_tags", {}), { Name = "${var.prefix_name_tag}${coalesce(each.value.name, "endpoint")}" })
}

locals {
  endpoint_subnet_associations_flat = flatten([
    for vepkey, vep in local.vpc_endpoints_i : [
      for subnetkey in var.vpc.availability_zones : {
        vepkey    = vepkey
        vep       = vep
        subnetkey = subnetkey
        subnet_id = local.subnets[subnetkey]
      }
    ]
  ])
  endpoint_subnet_associations = { for v in local.endpoint_subnet_associations_flat : "${v.vepkey}-${v.subnetkey}" => v }
}

resource "aws_vpc_endpoint_subnet_association" "this" {
  for_each = local.endpoint_subnet_associations

  vpc_endpoint_id = each.value.vep.id
  subnet_id       = each.value.subnet_id
}

data "aws_vpc_endpoint" "gateway" {
  for_each = local.existing_vpc_endpoints_g

  service_name = each.value.service_name
  tags         = { Name = each.value.name }
}

resource "aws_vpc_endpoint" "gateway" {
  for_each = local.create_vpc_endpoints_g

  vpc_id              = var.vpc.id
  service_name        = each.value.service_name
  vpc_endpoint_type   = each.value.vpc_endpoint_type
  auto_accept         = lookup(each.value, "auto_accept", null)
  policy              = lookup(each.value, "policy", null)
  private_dns_enabled = lookup(each.value, "private_dns_enabled", null)

  tags = merge(var.global_tags, lookup(each.value, "local_tags", {}), { Name = "${var.prefix_name_tag}${coalesce(each.value.name, each.key, "endpoint")}" })
}

locals {
  endpoint_rt_associations_flat = flatten([])
}

resource "aws_vpc_endpoint_route_table_association" "this" {
  for_each = {}
  # maybe distinct local.route_tables[*].id

  vpc_endpoint_id = each.value.id
  route_table_id  = each.value
}

variable vpc_endpoints { default = {} }
```

`if lookup(v, "vpc_endpoint_type", null) == "Interface" && lookup(v, "create", true) == false`
instead of
`if v.vpc_endpoint_type == "Interface" && v.create == false`

TODO: on vpc_endpoint comment how to find out simple_service_name, there are some aws cli commands

TODO: vpc needs var.read_internet_gateway, not var.use_internet_gateway - consistency with subnet_set var.read_route_table

TODO: A good place for the igw next_hop cycle test-case seems tests/tgw_existing: # minor test: add egress through igw for subnets which will be created on this vpc (i.e. there is a bit of circularity).

TOTHINK: v.associate_route_table: Assume that any pre-existing subnet always has an associated route table and we will fail to associate another one.

TODO: using one module.natgw.next_hop_set gather for Troubleshooting what is the error on create_shared_route_table = true

TOTHINK:  aws_dx_gateway_association - search on github, maybe we don't need to implement a detached VGW:

```hcl
resource "aws_vpn_gateway" "unattached" {
  count = var.create_vpn_gateway ? 1 : 0
 
  vpc_id          = null  # null for unattached VGW # a must for dx # Web says: (2) Detached VGWs can advertise BGP prefixes learned from multiple endpoints, unlike a VGW attached a VPC. # (3) I believe that source/destination IP validation is also disabled in detached VGWs.
  amazon_side_asn = 65000
  # tags            = merge(var.global_tags, { Name = var.name })
}
 
resource "aws_dx_gateway_association" "this" {
  # for_each              = { for name, vgw in var.vpn_gateways : name => vgw if contains(keys(vgw), "dx_gateway_id") }
  # dx_gateway_id         = each.value.dx_gateway_id
  # associated_gateway_id = aws_vpn_gateway.this[each.key].id
}

module subnet {
  source = "../../modules/subnet_set"

  vpc_id = module.vpc.id
  cidrs = {
    "10.100.0.0/25"  = { az = "us-east-1a" }
    "10.100.64.0/25" = { az = "us-east-1b" }
  }
  propagate_routes_from = { myvpn = module.vpc.vpn_gateway.id /* Optionally also a Detached VGW (that is, one not parented by a VPC). */ }
}

### old examples/vpc_endpoints/terraform.tfvars from vpc_all_options

vpc_route_tables = {
  mgmt = { name = "mgmt", vgw_propagation = "vmseries-vgw" }
  # igw-ingress = { name = "igw-ingress", igw_association = "vmseries-vpc" }
  vgw-ingress = { name = "vgw-ingress", vgw_association = "vmseries-vgw" }
}

subnets = {
  mgmt-1a = { name = "mgmt-1a", cidr = "10.100.0.0/25", az = "us-east-1a", rt = "mgmt" }
  mgmt-1b = { name = "mgmt-1b", cidr = "10.100.0.128/25", az = "us-east-1b", rt = "mgmt" }
}

vpn_gateways = {
  vmseries-vgw = {
    name            = "vmseries-vgw"
    vpc_attached    = true
    amazon_side_asn = "7224"
    # dx_gateway_id   = "3d3388c7-eab9-408b-a33d-796dcfa231d4"
    local_tags = { "foo" = "bar" }
  }
  detached-vgw = {
    name            = "detached-vgw"
    vpc_attached    = false
    amazon_side_asn = "65200"
  }
}
```
