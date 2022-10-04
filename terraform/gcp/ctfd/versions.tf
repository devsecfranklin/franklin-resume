terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
  backend "gcs" {
    bucket = "ps-devsecops"
    prefix = "ctfd-tf-state"
  }
}
