terraform {
  required_providers {
    null     = "~> 3.2.0"
    random   = "~> 3.4.0"
    external = "~> 2.2.0"
    google = {
      source = "hashicorp/google"
    }
  }
  backend "gcs" {
    bucket = "lab-franklin"
    prefix = "gke-cluster"
  }
}
