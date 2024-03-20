output "panorama_1_url" {
  description = "Panorama instance URL."
  value       = "https://${module.panorama_1.mgmt_ip_address}"
}

output "panorama_2_url" {
  description = "Panorama instance URL."
  value       = "https://${module.panorama_2.mgmt_ip_address}"
}

output "panorama_admin_password" {
  description = "Panorama administrator's initial password."
  value       = random_password.this.result
  sensitive   = true
}

output "username" {
  description = "Panorama administrator's initial username."
  value       = var.username
}
