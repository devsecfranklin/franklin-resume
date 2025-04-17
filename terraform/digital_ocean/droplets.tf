# SPDX-FileCopyrightText: © 2022-2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

resource "digitalocean_droplet" "games" {
  name    = "games"
  image   = "debian-12-x64"
  backups = true
  size    = "4gb"
  ssh_keys = [
    data.digitalocean_ssh_key.terraform.id
  ]
  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = file(var.pvt_key)
    timeout     = "2m"
  }
  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      # install nginx
      "sudo apt-get update",
      "sudo apt-get -y install nginx"
    ]
  }
}

resource "digitalocean_droplet" "www" {
  name       = "www"
  backups    = true
  image      = "69440038" //doctl compute image list --public --format ID,Distribution,Slug | grep Debian
  ipv6       = true
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
