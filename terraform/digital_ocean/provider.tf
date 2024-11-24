terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.44.1"
    }
  }
  required_version = ">= 0.14"
}

provider "digitalocean" {
  token = var.do_token
}
