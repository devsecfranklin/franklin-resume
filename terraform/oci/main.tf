resource "oci_core_drg" "this" {
  compartment_id = var.compartment
  freeform_tags  = var.tags
  display_name   = var.drg_name
}

module "hub" {
  source = "./modules/vcn"

  compartment          = var.compartment
  region               = var.region
  tags                 = var.tags
  security_lists       = var.security_lists
  dns_label            = var.dns_label
  create_igw           = true
  cidr_blocks          = var.cidr_blocks
  virtual_network_name = var.vcn_name
  route_tables         = var.route_tables
  subnets              = var.subnets
  use_drg              = true
  drg_id               = oci_core_drg.this.id
}

module "vmseries" {
  source = "./modules/vmseries"

  for_each            = var.firewalls
  compartment         = var.compartment
  name                = each.value.name
  availability_domain = each.value.ad
  ssh_authorized_keys = file(var.ssh_key_file)
  shape               = var.shape
  img_version         = var.img_version
  tags                = var.tags
  interfaces = [
    {
      name             = "${each.key}-mgmt"
      subnet_id        = module.hub.subnet_ids["mgmt"]
      assign_public_ip = true
    },
    {
      name             = "${each.key}-public"
      subnet_id        = module.hub.subnet_ids["untrust"]
      assign_public_ip = true
    },
    {
      name             = "${each.key}-private"
      subnet_id        = module.hub.subnet_ids["trust"]
      assign_public_ip = false
    }
  ]
}
