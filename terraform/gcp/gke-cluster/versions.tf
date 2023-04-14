terraform {
  required_providers {
    null     = "~> 3.2.0"
    random   = "~> 3.5.0"
    external = "~> 2.3.0"
    google = {
      source = "hashicorp/google"
    }
  }
  backend "gcs" {
    bucket = "lab-franklin"
    prefix = "gke-cluster"
  }
}
