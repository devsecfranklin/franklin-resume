terraform {
  required_version = ">= 0.13, < 2.0"
  required_providers {
    random   = "~> 3.5.0"
    external = "~> 2.3.0"
  }
  backend "gcs" {
    bucket = "lab-franklin-terraform"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  //impersonate_service_account = var.service_account_terraform
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

provider "template" {}
