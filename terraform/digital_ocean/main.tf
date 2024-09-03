/*
data "digitalocean_volume" "minecraft-volume" {
  name   = "volume-nyc3-01"
  region = var.region
}
*/

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

resource "digitalocean_droplet" "www" {
  backups    = true
  image      = "debian-10-x64"
  ipv6       = true
  monitoring = false
  name       = "www"
  //private_networking = false
  region      = "lon1"
  resize_disk = true
  size        = "512mb"
  tags        = []
  volume_ids  = []
}
*/