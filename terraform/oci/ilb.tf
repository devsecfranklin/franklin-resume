module "ilb" {
  source = "./modules/nlb"

  compartment                    = var.compartment
  policy                         = "FIVE_TUPLE" // WARNING: You can define policy as "ROUND_ROBIN" and deployment won't fail. But it will be in "critical" state all the time, hard to debug
  name                           = var.ilb_name
  private                        = true
  subnet_id                      = module.hub.subnet_ids["trust"]
  health_checker_port            = var.ilb_health_checker_port
  listeners                      = var.ilb_listeners
  is_preserve_source_destination = var.ilb_preserve_source_destination
}

locals {
  ilb_backend_ips = {
    this1 = {
      address = module.vmseries["left"].nic2_ip_address
      id      = module.vmseries["left"].id
    }
    this2 = {
      address = module.vmseries["right"].nic2_ip_address
      id      = module.vmseries["right"].id
    }
  }

  ilb_load_balancer_backends = flatten([
    for ipkey, ip in local.ilb_backend_ips : [
      for bsetkey, bset in module.ilb.backend_sets : {
        backend_name     = ipkey
        backend_address  = ip.address
        backend_set_name = bset.name
        backend_set_port = module.ilb.listeners[bsetkey].port
    }]
  ])
}

// Attach firewalls to iLB
resource "oci_network_load_balancer_backend" "ilb" {
  for_each = { for v in local.ilb_load_balancer_backends : "${v.backend_set_name}=${v.backend_name}" => v }

  backend_set_name         = each.value.backend_set_name
  network_load_balancer_id = module.ilb.loadbalancer.id
  ip_address               = each.value.backend_address
  port                     = each.value.backend_set_port
}
