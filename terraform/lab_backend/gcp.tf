// GCP backend storage bucket for Terraform
resource "google_storage_bucket" "terraform_state" {
  project  = var.project_id
  name     = "franklin-gcp-terraform"
  location = var.region

  force_destroy               = true
  uniform_bucket_level_access = true
}

// Management network for Panoramas
resource "google_compute_network" "vpc" {
  name                    = "${var.name}-mgmt-vpc"
  project                 = var.project_id
  auto_create_subnetworks = "false"
}

/* who can talk to Panorama? 

  Still using the old VPC name for now. Change to use above VPC
*/
resource "google_compute_firewall" "lab-ingress" {
  name        = "franklin-lab-ingress"
  project     = var.project_id
  network     = "ps-devsecops-mgmt" # google_compute_network.vpc.name
  description = "Default rule restrict ingress traffic"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "443", "3978", "8443", "28769"]
  }

  direction = "INGRESS"
  source_ranges = [
    "10.199.0.0/21",     # Azure common subnet
    "68.38.137.81/32",   # Franklin lab
    "34.134.31.136/32",  # ps-devsecops-panorama-three-10-0-4 
    "34.136.90.64/32",   # ps-devsecops-panorama-two-10-0-4
    "52.151.200.84/32",  # Azure lab firewall number one
    "52.151.200.150/32", # Azure lab firewall number two
    "52.151.200.153/32", # azure MTA 3
    "52.151.200.97/32",  # azure MTA 4
    "34.66.44.164/32",   # gke cluster
    "35.185.72.81/32",   # gcp test fw
    "137.83.195.1/32"    # Palo Corp Global Protect
  ]
}
