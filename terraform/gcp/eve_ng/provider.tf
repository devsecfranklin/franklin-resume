terraform {
  required_providers {
    //null     = "~> 3.1.0"
    random   = "~> 3.4.0"
    external = "~> 2.2.0"
  }
  backend "gcs" {
    bucket = "pso-automation-dev"
    prefix = "eve-ng"
    //credentials = "$GOOGLE_APPLICATION_CREDENTIALS"
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
