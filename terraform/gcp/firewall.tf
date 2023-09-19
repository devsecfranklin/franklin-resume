resource "google_compute_firewall" "lab-franklin-ingress" {
  name        = "${var.name_prefix}-ingress"
  project     = var.project_id
  network     = data.google_compute_network.mgmt-vpc.name
  description = "Default rule restrict ingress traffic"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "443", "2049", "3978", "5000", "8443", "28270", "28443", "28769"]
  }

  allow {
    protocol = "udp"
    ports    = ["53"]
  }

  direction     = "INGRESS"
  source_ranges = var.access_list
}

resource "google_compute_firewall" "lab-ingress" {
  name        = "franklin-lab-ingress"
  project     = var.project_id
  network     = "ps-devsecops-mgmt" # google_compute_network.vpc.name
  description = "Default rule restrict ingress traffic"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "443", "2049", "3978", "5000", "8443", "28270", "28443", "28769"]
  }

  allow {
    protocol = "udp"
    ports    = ["53"]
  }

  direction     = "INGRESS"
  source_ranges = var.access_list
}

// firewall changes require compute security admin role
resource "google_compute_firewall" "allow-egress" {
  name        = "${var.name_prefix}-egress"
  project     = var.project_id
  network     = data.google_compute_network.mgmt-vpc.name
  description = "Default rule allow egress traffic"

  allow {
    protocol = "all"
  }

  direction          = "EGRESS"
  destination_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "all-pods-and-master-ipv4-cidrs" {
  name        = "${var.name_prefix}-all-pods"
  project     = var.project_id
  network     = data.google_compute_network.mgmt-vpc.name
  description = "a firewall rule that allows Pod-to-Pod and Pod-to-API server communication"

  allow {
    protocol = "all"
  }

  direction     = "INGRESS"
  source_ranges = ["10.0.0.0/8", "172.16.2.0/28"]
}

resource "google_compute_firewall" "ctfd-on-airlock" {
  name        = "${var.name_prefix}-ctfd-airlock"
  project     = var.project_id
  network     = data.google_compute_network.mgmt-vpc.name
  description = "a firewall rule that allows ingress on CTFd instance"

  allow {
    protocol = "tcp"
    ports    = ["80", "8000"] # port 80 is for certbot, 8000 is for CTFd
  }

  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
}
