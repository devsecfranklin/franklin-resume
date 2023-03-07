data "terraform_remote_state" "tfstate-bucket" {
  backend = "gcs"
  config = {
    bucket = "lab-franklin-terraform"
    prefix = "terraform/state"
  }
}

data "google_compute_network" "mgmt-vpc" {
  name = "${var.name_prefix}-mgmt-vpc"
}

data "google_compute_subnetwork" "my-subnetwork" {
  name   = "${var.name_prefix}-mgmt-subnet"
  region = var.region
}

// Legacy Management network for Panoramas - deprecated
resource "google_compute_network" "vpc" {
  name                    = "${var.name}-mgmt-vpc"
  project                 = var.project_id
  auto_create_subnetworks = "false"
}
