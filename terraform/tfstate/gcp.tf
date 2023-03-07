// GCP backend storage bucket for Terraform
resource "google_storage_bucket" "terraform_state" {
  project  = var.project_id
  name     = "lab-franklin-terraform"
  location = var.region

  force_destroy               = true
  uniform_bucket_level_access = true
}

// lab-franklin vpc
resource "google_compute_network" "mgmt-vpc" {
  name                    = "${var.name}-mgmt-vpc"
  project                 = var.project_id
  auto_create_subnetworks = "false"
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_subnetwork" "mgmt-subnet" {
  name          = "${var.name}-mgmt-subnet"
  ip_cidr_range = "10.252.0.0/25"
  region        = var.region
  network       = google_compute_network.mgmt-vpc.id

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  lifecycle {
    prevent_destroy = true
  }
}

// have to move this to a region that allows larger machines
resource "google_compute_subnetwork" "aus_network_subnet" {
  name                     = "${var.name}-aus-mgmt-subnet"
  project                  = var.project_id
  region                   = var.openshift-region
  network                  = google_compute_network.mgmt-vpc.id
  ip_cidr_range            = "10.252.128.0/25"
  private_ip_google_access = true
  lifecycle {
    prevent_destroy = true
  }
}
