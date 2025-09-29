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

data "google_compute_subnetwork" "mgmt-subnetwork" {
  name   = "${var.name_prefix}-mgmt-subnet"
  region = var.region
}