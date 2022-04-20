module "elb" {
  source = "./modules/nlb"

  compartment                    = var.compartment
  policy                         = "FIVE_TUPLE" // WARNING: You can define policy as "ROUND_ROBIN" and deployment won't fail. But it will be in "critical" state all the time, hard to debug
  name                           = var.elb_name
  private                        = false
  subnet_id                      = module.hub.subnet_ids["untrust"]
  health_checker_port            = var.elb_health_checker_port
  listeners                      = var.elb_listeners
  is_preserve_source_destination = var.elb_preserve_source_destination
}

locals {
  elb_backend_ips = {
    this1 = {
      address = module.vmseries["left"].nic1_ip_address
      id      = module.vmseries["left"].id
    }
    this2 = {
      address = module.vmseries["right"].nic1_ip_address
      id      = module.vmseries["right"].id
    }
  }

  elb_load_balancer_backends = flatten([
    for ipkey, ip in local.elb_backend_ips : [
      for bsetkey, bset in module.elb.backend_sets : {
        backend_name     = ipkey
        backend_address  = ip.address
        backend_set_name = bset.name
        backend_set_port = module.elb.listeners[bsetkey].port
    }]
  ])
}

// Attach firewalls to eLB
resource "oci_network_load_balancer_backend" "elb" {
  for_each = { for v in local.elb_load_balancer_backends : "${v.backend_set_name}=${v.backend_name}" => v }

  backend_set_name         = each.value.backend_set_name
  network_load_balancer_id = module.elb.loadbalancer.id
  ip_address               = each.value.backend_address
  port                     = each.value.backend_set_port
}
