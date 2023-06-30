locals {
  eastwest = [for k, v in module.gwlbe_eastwest.endpoints : format("aws-gwlb-associate-vpce:%s@%s", v.id, var.east_west_subinterface)]
}

module "vmseries" {
  for_each = var.vmseries
  source   = "PaloAltoNetworks/vmseries-modules/aws//modules/vmseries"
  version  = "0.4.2"

  name             = "${var.name_prefix}${each.key}"
  vmseries_version = var.vmseries_version
  instance_type    = var.instance_type

  interfaces = {
    data = {
      device_index       = 0
      security_group_ids = [module.security_vpc.security_group_ids["vmseries_data"]]
      source_dest_check  = false
      subnet_id          = module.security_subnet_sets[var.security_subnet_data_name].subnets[each.value.az].id
      create_public_ip   = false
    },
    mgmt = {
      device_index       = 1
      security_group_ids = [module.security_vpc.security_group_ids["vmseries_mgmt"]]
      source_dest_check  = false
      subnet_id          = module.security_subnet_sets[var.security_subnet_mgmt_name].subnets[each.value.az].id
      create_public_ip   = true
    }
  }

  bootstrap_options = join(";", compact(concat(
    [for k, v in var.vmseries_common.bootstrap_options : "${k}=${v}"],
    [for _, v in local.eastwest : "${v}"]
  )))

  ssh_key_name = var.ssh_key_name
  tags         = var.global_tags
}

resource "aws_key_pair" "this" {
  count = var.create_ssh_key ? 1 : 0

  key_name   = var.ssh_key_name
  public_key = file(var.ssh_public_key_file)
  tags       = var.global_tags
}
