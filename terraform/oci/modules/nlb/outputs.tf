output "loadbalancer_ip" {
  value = oci_network_load_balancer_network_load_balancer.this.ip_addresses[0].ip_address
}

output "loadbalancer" {
  value = oci_network_load_balancer_network_load_balancer.this
}

output "backend_sets" {
  value = oci_network_load_balancer_backend_set.this
}

output "listeners" {
  value = oci_network_load_balancer_listener.this
}
