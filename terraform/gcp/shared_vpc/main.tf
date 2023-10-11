module "vpc" {
  source  = "PaloAltoNetworks/vmseries-modules/google//modules/vpc"
  version = "1.2.6"

  networks = [
    {
      name            = "${var.name_prefix}mgmt"
      subnetwork_name = "${var.name_prefix}mgmt"
      ip_cidr_range   = var.ip_cidr_range_mgmt
      host_project_id = var.host_project_id
      allowed_sources = concat(var.allowed_sources_mgmt, var.allowed_sources_panorama)
    },
    {
      name            = "${var.name_prefix}ingress"
      subnetwork_name = "${var.name_prefix}ingress"
      ip_cidr_range   = var.ip_cidr_range_ingress
      host_project_id = var.host_project_id
      allowed_sources = var.allowed_sources_ingress
    },
    {
      name                            = "${var.name_prefix}egress"
      subnetwork_name                 = "${var.name_prefix}egress"
      ip_cidr_range                   = var.ip_cidr_range_egress
      host_project_id                 = var.host_project_id
      delete_default_routes_on_create = true
      allowed_sources                 = var.allowed_sources_egress
    },
    #    {
    #      name            = "${var.name_prefix}service1"
    #      subnetwork_name = "${var.name_prefix}service1"
    #      ip_cidr_range   = "10.192.65.0/24"
    #      allowed_sources = var.allowed_sources_ingress
    #      project         = var.service_projects_ids.service1
    #      delete_default_routes_on_create = true
    #    },
  ]
}

#resource "google_compute_network_peering" "egress_to_service1" {
#  name                 = "${var.name_prefix}egress-to-service1"
#  network              = module.vpc.networks["${var.name_prefix}egress"].id
#  peer_network         = module.vpc.networks["${var.name_prefix}service1"].id
#  export_custom_routes = true
#  import_custom_routes = false
#}
#
#resource "google_compute_network_peering" "service1_to_egress" {
#  name                 = "${var.name_prefix}service1-to-egress"
#  network              = module.vpc.networks["${var.name_prefix}service1"].id
#  peer_network         = module.vpc.networks["${var.name_prefix}egress"].id
#  export_custom_routes = false
#  import_custom_routes = true
#}

module "vmseries_ingress" {
  for_each = var.vmseries.ingress
  source   = "PaloAltoNetworks/vmseries-modules/google//modules/vmseries"
  version  = "1.2.6"

  name = "${var.name_prefix}${each.key}"
  zone = each.value.zone

  ssh_keys       = var.ssh_keys
  vmseries_image = var.vmseries_common.vmseries_image
  machine_type   = var.vmseries_common.machine_type

  tags = concat(var.vmseries_common.tags, var.vmseries_common_ingress.tags)

  bootstrap_options = merge({
    # vmseries-bootstrap-gce-storagebucket = module.bootstrap.bucket_name
    },
    var.vmseries_common.bootstrap_options,
    var.vmseries_common_ingress.bootstrap_options,
  )

  create_instance_group = true
  named_ports = [
    {
      name = "http"
      port = "80"
    }
  ]

  network_interfaces = [
    {
      subnetwork      = module.vpc.subnetworks["${var.name_prefix}ingress"].self_link
      private_address = each.value.private_ips["ingress"]
    },
    {
      subnetwork       = module.vpc.subnetworks["${var.name_prefix}mgmt"].self_link
      private_address  = each.value.private_ips["mgmt"]
      create_public_ip = false
    },
    {
      subnetwork      = module.vpc.subnetworks["${var.name_prefix}egress"].self_link
      private_address = each.value.private_ips["egress"]
    },
  ]
}

module "vmseries_egress" {
  for_each = var.vmseries.egress
  source   = "PaloAltoNetworks/vmseries-modules/google//modules/vmseries"
  version  = "1.2.6"

  name = "${var.name_prefix}${each.key}"
  zone = each.value.zone

  ssh_keys       = var.ssh_keys
  vmseries_image = var.vmseries_common.vmseries_image
  machine_type   = var.vmseries_common.machine_type

  create_instance_group = true
  tags                  = concat(var.vmseries_common.tags, var.vmseries_common_ingress.tags)

  bootstrap_options = merge({
    # vmseries-bootstrap-gce-storagebucket = module.bootstrap.bucket_name
    },
    var.vmseries_common.bootstrap_options,
    var.vmseries_common_egress.bootstrap_options,
  )

  network_interfaces = [
    {
      subnetwork      = module.vpc.subnetworks["${var.name_prefix}ingress"].self_link
      private_address = each.value.private_ips["ingress"]
    },
    {
      subnetwork       = module.vpc.subnetworks["${var.name_prefix}mgmt"].self_link
      private_address  = each.value.private_ips["mgmt"]
      create_public_ip = false
    },
    {
      subnetwork       = module.vpc.subnetworks["${var.name_prefix}egress"].self_link
      private_address  = each.value.private_ips["egress"]
      create_public_ip = true
    },
  ]
}

module "lb_external" {
  source  = "PaloAltoNetworks/vmseries-modules/google//modules/lb_http_ext_global/"
  version = "1.2.6"


  name                  = "${var.name_prefix}${var.extlb_name}"
  backend_groups        = { for k, v in module.vmseries_ingress : k => v.instance_group_self_link }
  max_rate_per_instance = 10000
}

module "lb_internal" {
  source  = "PaloAltoNetworks/vmseries-modules/google//modules/lb_internal"
  version = "1.2.6"

  name     = "${var.name_prefix}ilb"
  region   = var.region
  backends = { for k, v in module.vmseries_egress : k => v.instance_group_self_link }
  # ip_address = "10.250.64.40"
  subnetwork = module.vpc.subnetworks["${var.name_prefix}egress"].self_link
  network    = "${var.name_prefix}egress"
  all_ports  = true
}


#resource "google_compute_route" "route1" {
#  name       = "default"
#  network    = module.vpc.networks["${var.name_prefix}mgmt"].id
#  dest_range = "0.0.0.0/0"
#  priority   = 1000
#
#  next_hop_vpn_tunnel = google_compute_vpn_tunnel.tunnel1.self_link
#}
