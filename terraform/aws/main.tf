module "security_vpc" {
  source = "./modules/vpc"

  name                    = var.security_vpc_name
  cidr_block              = var.security_vpc_cidr
  security_groups         = var.security_vpc_security_groups
  create_internet_gateway = true
  enable_dns_hostnames    = true
  enable_dns_support      = true
  instance_tenancy        = "default"
}

module "security_subnet_sets" {
  # The "set" here means we will repeat in each AZ an identical/similar subnet.
  # The notion of "set" is used a lot here, it extends to nat gateways, routes, routes' next hops,
  # gwlb endpoints and any other resources which would be a single point of failure when placed
  # in a single AZ.
  for_each = toset(distinct([for _, v in var.security_vpc_subnets : v.set]))
  source   = "./modules/subnet_set"

  name   = each.key
  vpc_id = module.security_vpc.id
  cidrs  = { for k, v in var.security_vpc_subnets : k => v if v.set == each.key }
}

module "natgw_set" {
  source     = "./modules/nat_gateway_set"
  subnet_set = module.security_subnet_sets["nj-courts-natgw"]
}


module "transit_gateway" {
  source = "./modules/transit_gateway"

  create = var.create_tgw
  name   = var.transit_gateway_name
  asn    = var.transit_gateway_asn
  route_tables = {
    "from_security_vpc" = {
      create = true
      name   = "${var.prefix_name_tag}from_security"
    }
    "from_app1_vpc" = {
      create = true
      name   = "${var.prefix_name_tag}from_spokes"
    }
  }
  //auto_accept_shared_attachments = "enable" # TODO: stay at the default "disable" for extra security
}

module "security_transit_gateway_attachment" {
  source = "./modules/transit_gateway_attachment"

  name                        = var.security_transit_gateway_attachment
  subnet_set                  = module.security_subnet_sets["tgw_attach"]
  transit_gateway_route_table = module.transit_gateway.route_tables["from_security_vpc"]
  //propagate_routes_to = {
  //  to1 = module.transit_gateway.route_tables["from_spoke_vpc"].id
  //}
}

module "vmseries" {
  source              = "./modules/vmseries"
  region              = var.region
  prefix_name_tag     = var.prefix_name_tag
  ssh_key_name        = var.ssh_key_name
  fw_license_type     = var.fw_license_type
  fw_version          = var.fw_version
  fw_instance_type    = var.fw_instance_type
  tags                = var.global_tags
  firewalls           = var.firewalls
  interfaces          = var.interfaces
  subnets_map         = merge(module.security_subnet_sets["nj-courts-data"].subnet_ids, module.security_subnet_sets["nj-courts-mgmt"].subnet_ids)
  security_groups_map = module.security_vpc.security_group_ids
  #buckets_map         = local.buckets_map
}

module "security_gwlb" {
  source = "./modules/gwlb"

  name       = var.gwlb_name
  subnet_set = module.security_subnet_sets["nj-courts-data"] # Assumption: one ss per gwlb.

  #target_instances = {}
  # Take an aws_instance.id and adds it to the aws_lb_target_group:
  target_instances = module.vmseries.firewalls
}

module "gwlbe_eastwest" {
  source = "./modules/gwlb_endpoint_set"

  name       = var.gwlb_endpoint_set_eastwest_name
  gwlb       = module.security_gwlb
  subnet_set = module.security_subnet_sets["gwlbe_eastwest"]
}

module "gwlbe_outbound" {
  source = "./modules/gwlb_endpoint_set"

  name       = var.gwlb_endpoint_set_outbound_name
  gwlb       = module.security_gwlb
  subnet_set = module.security_subnet_sets["gwlbe_outbound"]
}

module "security_route" {
  for_each = {
    from_mgmt_to_igw = {
      next_hop_set    = module.security_vpc.igw_as_next_hop_set
      route_table_ids = module.security_subnet_sets["nj-courts-mgmt"].unique_route_table_ids
      to_cidr         = "0.0.0.0/0"
    }
    from_natgw_to_igw = {
      next_hop_set    = module.security_vpc.igw_as_next_hop_set
      route_table_ids = module.security_subnet_sets["nj-courts-natgw"].unique_route_table_ids
      to_cidr         = "0.0.0.0/0"
    }
    from_natgw_to_gwlbe_outbound = {
      next_hop_set    = module.gwlbe_outbound.next_hop_set
      route_table_ids = module.security_subnet_sets["nj-courts-natgw"].unique_route_table_ids
      to_cidr         = var.summary_cidr_behind_tgw
    }
    from_tgw_to_gwlbe_outbound = {
      next_hop_set    = module.gwlbe_outbound.next_hop_set
      route_table_ids = module.security_subnet_sets["tgw_attach"].unique_route_table_ids
      to_cidr         = var.summary_cidr_behind_gwlbe_outbound
    }
    from_gwlbe_outbound_to_natgw = {
      next_hop_set    = module.natgw_set.next_hop_set
      route_table_ids = module.security_subnet_sets["gwlbe_outbound"].unique_route_table_ids
      to_cidr         = var.summary_cidr_behind_gwlbe_outbound
    }
    from_gwlbe_outbound_to_tgw = {
      next_hop_set    = module.security_transit_gateway_attachment.next_hop_set
      route_table_ids = module.security_subnet_sets["gwlbe_outbound"].unique_route_table_ids
      to_cidr         = var.summary_cidr_behind_tgw
    }
    from_tgw_to_gwlbe_eastwest = {
      next_hop_set    = module.gwlbe_eastwest.next_hop_set
      route_table_ids = module.security_subnet_sets["tgw_attach"].unique_route_table_ids
      to_cidr         = var.summary_cidr_behind_tgw
    }
    from_gwlbe_eastwest_to_tgw = {
      next_hop_set    = module.security_transit_gateway_attachment.next_hop_set
      route_table_ids = module.security_subnet_sets["gwlbe_eastwest"].unique_route_table_ids
      to_cidr         = var.summary_cidr_behind_tgw
    }
  }
  source = "./modules/vpc_route"

  route_table_ids = each.value.route_table_ids
  to_cidr         = each.value.to_cidr
  next_hop_set    = each.value.next_hop_set
}

