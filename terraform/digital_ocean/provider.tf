terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.48.2"
    }
  }
  required_version = ">= 0.14"
}

provider "digitalocean" {
  token = var.do_token
}
