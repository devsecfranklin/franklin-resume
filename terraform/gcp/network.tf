resource "google_compute_firewall" "allow-corp" {
  name        = "ti-ai-ingress"
  project     = "gcp-gcs-pso"
  network     = "ti-ai-mgt"
  description = "Default rule restrict ingress traffic"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "443", "3978", "8080", "8443", "28769"]
  }

  direction = "INGRESS"
  source_ranges = [
    "192.160.0.0/24", # mgmt subnet, for panorama HA, etc.
    #"192.160.1.0/24",    # untrust subnet, for panorama HA, etc.
    #"192.160.2.0/24",    # trust subnet, for panorama HA, etc.
    "68.38.137.81/32",  # Franklin lab
    "34.134.31.136/32", # ps-devsecops-panorama-three-10-0-4
    "34.136.90.64/32",  # ps-devsecops-panorama-two-10-0-4
    "34.66.55.164/32"   # gke cluster
  ]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "allow-ping-from-known-ranges" {
  name        = "ti-ai-allow-ping-from-known-ranges"
  project     = "gcp-gcs-pso"
  network     = "ti-ai-mgt"
  description = "Allow panorama and fw to use ICMP (need for HA)"

  direction = "INGRESS"
  priority  = 1000

  source_ranges = [
    "192.168.0.0/24",
  ]

  allow {
    protocol = "icmp"
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "allow-mgmt-traffic" {
  name        = "ti-ai-allow-mgmt-traffic"
  project     = "gcp-gcs-pso"
  network     = "ti-ai-mgt"
  description = "Allow panorama and fw to use certain TCP ports (need for HA)"

  direction = "INGRESS"
  priority  = 1000

  source_ranges = [
    "192.168.0.0/24",
  ]

  allow {
    protocol = "tcp"
    ports    = ["22", "443", "3978", "8080", "8443", "28769"]
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

