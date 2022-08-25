
resource "google_compute_network" "lab_franklin_gp" {
  project                 = var.project_id
  name                    = var.vpc_name
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "lab_franklin_gp_subnet" {
  project       = var.project_id
  name          = "lab-franklin-gp-client-subnet"
  ip_cidr_range = "10.10.24.0/24"
  region        = "us-east1"
  network       = google_compute_network.lab_franklin_gp.id
}

resource "google_compute_route" "private_network_internet_route" {
  project          = var.project_id
  name             = "private-network-internet"
  dest_range       = "0.0.0.0/0"
  network          = google_compute_network.lab_franklin_gp.self_link
  next_hop_gateway = "default-internet-gateway"
  priority         = 100
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A FIREWALL RULE TO ALLOW TRAFFIC FROM ALL ADDRESSES
# ---------------------------------------------------------------------------------------------------------------------

/*
resource "google_compute_firewall" "firewall" {
  project = var.project
  name    = "${var.name}-fw"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["5000"]
  }

  # These IP ranges are required for health checks
  source_ranges = ["0.0.0.0/0"]

  # Target tags define the instances to which the rule applies
  target_tags = [var.name]
}
*/

/*
    ****************************************************************
    use the “target_tags” to apply firewall rules to VM instances. If no “target_tags”
    are specified, the firewall rule applies to all instances on the specified VPC network.
    ****************************************************************
*/
# Allow http
resource "google_compute_firewall" "allow-http" {
  name    = "lab-franklin-gp-allow-http"
  project = var.project_id
  network = var.vpc_name
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http"]
}

# allow rdp
resource "google_compute_firewall" "allow-rdp" {
  name    = "lab-franklin-gp-allow-rdp"
  project = var.project_id
  network = var.vpc_name
  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["rdp"]
}

resource "google_compute_firewall" "public_ssh" {
  name    = "public-ssh"
  project = var.project_id
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  //target_tags = ["nginx-instance"] # point this at the desired instance
}
