# SPDX-FileCopyrightText: ©2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT

resource "digitalocean_droplet" "www" {
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