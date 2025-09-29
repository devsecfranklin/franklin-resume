// GCP backend storage bucket for Terraform
resource "google_storage_bucket" "terraform_state" {
  project  = var.project_id
  name     = "lab-franklin-terraform"
  location = var.region

  force_destroy               = true
  uniform_bucket_level_access = true
}

// GCP backend storage bucket for gke-terraform
resource "google_storage_bucket" "gke_terraform_state" {
  project  = var.project_id
  name     = "lab-franklin"
  location = var.region

  /* This only deletes objects when the bucket is destroyed,
     not when setting this parameter to true. Once this parameter
     is set to true, there must be a successful terraform apply
     run before a destroy is required to update this value in the
     resource state. Without a successful terraform apply after
     this parameter is set, this flag will have no effect. */
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

  #stack_type       =  "IPV4_IPV6"
  stack_type = "IPV4_ONLY"
  # ipv6_access_type = "INTERNAL"

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }

  lifecycle {
    prevent_destroy = true
  }
}