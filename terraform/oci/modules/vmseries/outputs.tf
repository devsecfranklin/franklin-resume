output "id" {
  description = "Identifier of the deployed VM-Series firewall."
  value       = oci_core_instance.this.id
}

output "mgmt_ip_address" {
  description = "VM-Series management IP address. It is a public IP address if available. Otherwise a private IP address."
  value       = coalesce(oci_core_instance.this.public_ip, oci_core_instance.this.private_ip)
}

output "nic1_ip_address" { value = try(oci_core_vnic_attachment.int1[var.interfaces[1].name].create_vnic_details[0].private_ip, null) }
output "nic2_ip_address" { value = try(oci_core_vnic_attachment.int2[var.interfaces[2].name].create_vnic_details[0].private_ip, null) }
output "nic3_ip_address" { value = try(oci_core_vnic_attachment.int3[var.interfaces[3].name].create_vnic_details[0].private_ip, null) }
output "nic4_ip_address" { value = try(oci_core_vnic_attachment.int4[var.interfaces[4].name].create_vnic_details[0].private_ip, null) }
output "nic5_ip_address" { value = try(oci_core_vnic_attachment.int5[var.interfaces[5].name].create_vnic_details[0].private_ip, null) }