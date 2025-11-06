# SPDX-FileCopyrightText: ©2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT

resource "digitalocean_droplet" "www" {
  // count = var.exclude_www_instance ? 0 : 1
  name       = "www"
  backups    = true
  image      = "199888143" //doctl compute image list --public --format ID,Distribution,Slug | grep Debian
  ipv6       = false
  monitoring = false

  //private_networking = false
  region      = "lon1"
  resize_disk = true
  size        = "512mb"
  tags        = []
  volume_ids  = []
  ssh_keys = [
    data.digitalocean_ssh_key.terraform.id
  ]

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      image,
      ipv6
    ]
  }
}

/*
resource "digitalocean_droplet" "minecraft20" {
  backups    = true
  image      = "56427524"
  ipv6       = true
  monitoring = false
  name       = "minecraft20"
  //private_networking = false
  region      = var.region
  resize_disk = true
  size        = "s-4vcpu-8gb"
  tags = [
    "forge",
    "minecraft",
  ]
  volume_ids = [
    "d343d3ac-a687-11eb-9a5b-0a58ac146bd9",
  ]
}

*/
