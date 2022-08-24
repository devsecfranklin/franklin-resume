output "west_vm_ip" {
  value = azurerm_network_interface.west_vm_nic.private_ip_address
}
output "east_vm_ip" {
  value = azurerm_network_interface.east_vm_nic.private_ip_address
}

/*
output "admin_password" {
  value = 
}
*/
