terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.34.0"
    }
  }
  backend "gcs" {
    bucket = "lab-franklin-terraform"
    prefix = "cloud-function/state"
    //credentials = "credentials.json"
  }
}
