output "username" {
  description = "Initial administrative username to use for VM-Series."
  value       = var.username
}
output "password" {
  description = "Initial administrative password to use for VM-Series."
  value       = local.fw_password
  sensitive   = true
}
# output "mgmt_ip_addresses_inbound_fw" {
#   description = "IP Addresses for VM-Series management (https or ssh)."
#   value       = { for k, v in module.vmseries : k => v.mgmt_ip_address }
# }