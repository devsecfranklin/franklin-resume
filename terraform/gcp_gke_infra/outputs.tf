/*
output "ssh_command" {
  value = { for k, v in module.vmseries.nic1_ips : k => "ssh admin@${v}" }
}
*/

output "networks" {
  value = { for k, v in module.vpc.subnetworks : k => try(v, null) }
}

output "instance_groups" {
  value = { for k, v in module.vmseries.instance_groups : k => try(v, null) }
}