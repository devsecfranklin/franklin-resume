resource "google_compute_network" "vpc" {
  name                    = "${var.name}-vpc"
  project                 = var.project_id
  auto_create_subnetworks = "false"
}

resource "google_compute_route" "egress_internet" {
  name             = "${var.name}-egress-internet"
  project          = var.project_id
  dest_range       = "0.0.0.0/0"
  network          = google_compute_network.vpc.name
  next_hop_gateway = "default-internet-gateway"
}

resource "google_compute_router" "router" {
  name    = "${var.name}-router"
  project = var.project_id
  region  = var.region
  network = google_compute_network.vpc.name
}

resource "google_compute_subnetwork" "gke-subnet" {
  name                     = "${var.name}-gke-subnet"
  project                  = var.project_id
  region                   = var.region
  network                  = google_compute_network.vpc.name
  ip_cidr_range            = "10.11.0.0/24"
  private_ip_google_access = true

  /* A named secondary range is mandatory for a private cluster

  While using a secondary IP range is recommended in order to to separate
  cluster master and pod IPs, when using a network in the same project as
  your GKE cluster you can specify a blank range name to draw alias IPs
  from your subnetwork's primary IP range. If using a shared VPC network
  (a network from another GCP project) using an explicit secondary range is
  required.
  */
  secondary_ip_range = [
    {
      ip_cidr_range = "10.171.0.0/16"
      range_name    = "gke-ps-devsecops-gke-pods-d45be269"
    },
    {
      ip_cidr_range = "10.172.0.0/22"
      range_name    = "gke-ps-devsecops-gke-services-d45be269"
    },


  ]
}

resource "google_compute_router_nat" "nat_router" {
  name                               = "${var.name}-nat-router"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.gke-subnet.name
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

// firewall changes require compute security admin role
resource "google_compute_firewall" "allow-egress" {
  name        = "${var.name}-allow-egress"
  project     = var.project_id
  network     = google_compute_network.vpc.name
  description = "Default rule allow egress traffic"

  allow {
    protocol = "all"
  }

  direction          = "EGRESS"
  destination_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow-corp" {
  name        = "${var.name}-allow-corp"
  project     = var.project_id
  network     = google_compute_network.vpc.name
  description = "Default rule restrict ingress traffic"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "443", "3978", "8443", "28769"]
  }

  direction = "INGRESS"
  source_ranges = [
    "34.103.71.242/32", # Corporate
    "54.215.48.190/32", # Denver - DS 
    "156.146.51.68/32", # Palmer Lake
    "68.38.137.81/32",  # Franklin lab
    "34.134.31.136/32", # ps-devsecops-panorama-three-10-0-4 
    "34.136.90.64/32",  # ps-devsecops-panorama-two-10-0-4 
    "34.66.44.164/32"   # gke cluster
  ]
}

resource "google_compute_firewall" "ps-devsecops-allow-tekton-webhook" {
  name        = "${var.name}-allow-tekton-webhook"
  project     = var.project_id
  network     = google_compute_network.vpc.name
  description = "Allow Tekton webhook ingress traffic"

  allow {
    protocol = "tcp"
    ports    = ["443", "8008", "8080", "8443", "9090", "9443"]
  }
  allow {
    protocol = "udp"
  }

  direction = "INGRESS"
  source_ranges = [
    "10.254.0.0/16" # Cloud function can send traffic to VPC
  ]
}

/*
module "address" {
  source       = "terraform-google-modules/address/google"
  version      = "3.1.2"
  project_id   = var.project_id
  region       = var.region
  address_type = "EXTERNAL"
  names = [
    "tekton-static-ip"
  ]
}
*/
