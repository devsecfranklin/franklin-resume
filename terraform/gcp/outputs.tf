/*
output "internal_ip" {
  value = google_compute_instance.openshift.network_interface.0.network_ip
}

output "external_ip" {
  value = google_compute_instance.openshift.network_interface.0.access_config.0.nat_ip
}
*/

output "airlock_internal_ip" {
  value = google_compute_instance.gcp_airlock.network_interface.0.network_ip
}

output "airlock_external_ip" {
  value = google_compute_address.airlock1_static.address
}

/*
output "timecube_internal_ip" {
  value = google_compute_instance.gcp_timecube.network_interface.0.network_ip
}

output "timecube_external_ip" {
  value = google_compute_address.timecube_static.address
}
*/