terraform {
  required_providers {
    null     = "~> 3.2.0"
    random   = "~> 3.7.0"
    external = "~> 2.3.0"
    google = {
      source = "hashicorp/google"
    }
  }
  backend "gcs" {
    bucket = "ps-devsecops"
    prefix = "openstack-tf"
    //credentials = "$GOOGLE_APPLICATION_CREDENTIALS"
  }
  //required_version = "~> 1.0"
}
