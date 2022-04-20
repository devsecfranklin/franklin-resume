# Load Balancer
resource "oci_network_load_balancer_network_load_balancer" "this" {
  compartment_id                 = var.compartment
  display_name                   = var.name
  subnet_id                      = var.subnet_id
  freeform_tags                  = var.tags
  is_private                     = var.private
  is_preserve_source_destination = var.is_preserve_source_destination
  # network_security_group_ids = var.load_balancer_network_security_group_ids // TODO

  // Currently only one reserved IP is supported per Network Load Balancer
  // so this dynamic block doesn't make much sense
  // but we hope it will support multiple IP addresses soon
  dynamic "reserved_ips" {
    for_each = var.reserved_ips
    content {
      id = reserved_ips.value.id
    }
  }
}

# Backend
resource "oci_network_load_balancer_backend_set" "this" {
  for_each                 = var.listeners
  name                     = "${var.name}-${each.key}-backend-set"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.this.id
  policy                   = var.policy

  health_checker {
    protocol           = var.health_checker_protocol
    port               = var.health_checker_port
    interval_in_millis = var.health_checker_interval
    # retries = var.backend_set_health_checker_retries // TODO
  }
}

# Listener
resource "oci_network_load_balancer_listener" "this" {
  for_each = var.listeners

  name                     = each.key
  default_backend_set_name = oci_network_load_balancer_backend_set.this[each.key].name
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.this.id
  port                     = each.value.port
  protocol                 = try(each.value.protocol, "TCP")
}
