resource "google_compute_firewall" "vmseries_mgmt" {
  name    = "${var.name_prefix}vmseries-mgmt"
  network = module.vpc.networks["${var.name_prefix}mgmt"].self_link

  allow {
    protocol = "tcp"
    ports    = [22, 443]
  }

  source_ranges = var.allowed_sources_mgmt
  target_tags   = ["vmseries"]
}

resource "google_compute_firewall" "vmseries_mgmt_panorama" {
  name    = "${var.name_prefix}vmseries-mgmt-panorama"
  network = module.vpc.networks["${var.name_prefix}mgmt"].self_link

  allow {
    protocol = "all"
  }

  source_ranges = var.allowed_sources_panorama
  target_tags   = ["vmseries"]
}

resource "google_compute_firewall" "vmseries_egress" {
  name    = "${var.name_prefix}vmseries-egress"
  network = module.vpc.networks["${var.name_prefix}egress"].self_link

  allow {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["vmseries"]
}

resource "google_compute_firewall" "vmseries_ingress_inbound" {
  name    = "${var.name_prefix}vmseries-ingress-inbound"
  network = module.vpc.networks["${var.name_prefix}ingress"].self_link

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["vmseries-inbound"]
}

/*
resource "google_compute_firewall" "service1_inbound" {
  name    = "${var.name_prefix}service1-inbound"
  network = module.vpc.networks["${var.name_prefix}service1"].self_link

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
}
*/
