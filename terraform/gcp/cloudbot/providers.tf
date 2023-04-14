terraform {
  required_version = ">= 1.0.3"

  required_providers {
    null     = "~> 3.2.0"
    random   = "~> 3.5.0"
    external = "~> 2.3.0"
    google = {
      source  = "hashicorp/google"
      version = ">= 4.40"
    }
  }
  backend "gcs" {
    bucket = "ps-devsecops"
    prefix = "dev-tf-cloudbot"
    //credentials = "$GOOGLE_APPLICATION_CREDENTIALS"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone // provider level zone option, but needed in this case for oauth
  //impersonate_service_account = var.service_account_terraform
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}
