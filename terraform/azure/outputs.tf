output "username" {
  description = "Initial administrative username to use for VM-Series."
  value       = var.username
}

output "password" {
  description = "Initial administrative password to use for VM-Series."
  value       = coalesce(var.password, random_password.this.result)
  sensitive   = true
}

output "mgmt_ip_addresses" {
  description = "IP Addresses for VM-Series management (https or ssh)."
  value = merge(
    { for k, v in module.gp_vmseries : k => v.mgmt_ip_address },
    { for k, v in module.outbound_vmseries : k => v.mgmt_ip_address },
    { for k, v in module.ipsec_vmseries : k => v.mgmt_ip_address },
  )
}

output "frontend_ips" {
  description = "IP Addresses of the inbound load balancer."
  value       = module.inbound_lb.frontend_ip_configs
}

output "frontend_gp_ips" {
  description = "IP Addresses of the inbound GP load balancer."
  value       = module.inbound_gp_lb.frontend_ip_configs
}

output "frontend_ipsec_ips" {
  description = "IP Addresses of the inbound IPSec load balancer."
  value       = module.inbound_ipsec_lb.frontend_ip_configs
}
