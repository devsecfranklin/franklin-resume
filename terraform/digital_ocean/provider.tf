# SPDX-FileCopyrightText: ©2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT

terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.75.0"
    }
  }
  required_version = ">= 0.14"
}

// leave token commented out to pull ENV value from BASH
provider "digitalocean" {
  //token = var.do_token
}

data "digitalocean_ssh_key" "terraform" {
  name = "franklin"
}
