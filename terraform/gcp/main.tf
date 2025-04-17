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

/*
data "google_compute_subnetwork" "aus-mgmt-subnetwork" {
  name   = "${var.name_prefix}-aus-mgmt-subnet"
  region = var.openshift-region
}

data "google_compute_subnetwork" "ps-devsecops-mgmt-subnetwork" {
  name   = "ps-devsecops-mgmt"
  region = var.region
}

data "google_compute_subnetwork" "ps-devsecops-untrust-subnetwork" {
  name   = "ps-devsecops-untrust"
  region = var.region
}

data "google_compute_subnetwork" "ps-devsecops-trust-subnetwork" {
  name   = "ps-devsecops-trust"
  region = var.region
}

// Legacy Management network for Panoramas - deprecated
resource "google_compute_network" "vpc" {
  name                    = "${var.name}-mgmt-vpc"
  project                 = var.project_id
  auto_create_subnetworks = "false"
  lifecycle {
    prevent_destroy = true
  }
}
*/
