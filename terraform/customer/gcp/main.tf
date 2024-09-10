resource "google_compute_subnetwork" "subnet-with-logging" {
  name          = "log-test-subnetwork"
  ip_cidr_range = "10.2.0.0/21" // 10.2.2.0 - 10.2.15.255
  region        = "us-central1"
  network       = google_compute_network.vpc_network.id

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_network" "vpc_network" {
  project = "gcp-gcs-pso"
  name    = "sandbox-vpc"
  //auto_create_subnetworks = true
  //mtu                     = 1460
}
