resource "google_compute_firewall" "allow-corp" {
  name        = "ti-ai-ingress"
  project     = "gcp-gcs-pso"
  network     = "ti-ai-mgt"
  description = "Default rule restrict ingress traffic"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "443", "3978", "8080", "8443", "28769"]
  }

  direction = "INGRESS"
  source_ranges = [
    "192.160.0.0/24",   # mgmt subnet, for panorama HA, etc.
    "199.167.52.5/32",  # Franklin Corporate
    "68.38.137.81/32",  # Franklin lab
    "34.134.31.136/32", # ps-devsecops-panorama-three-10-0-4
    "34.136.90.64/32",  # ps-devsecops-panorama-two-10-0-4
    "34.66.55.164/32"   # gke cluster
  ]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "allow-ping-from-known-ranges" {
  name        = "ti-ai-allow-ping-from-known-ranges"
  project     = "gcp-gcs-pso"
  network     = "ti-ai-mgt"
  description = "Allow panorama and fw to use ICMP (need for HA)"

  direction = "INGRESS"
  priority  = 1000

  source_ranges = [
    "192.168.0.0/24",
    "199.167.52.5/32", # Franklin Corporate
  ]

  allow {
    protocol = "icmp"
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "allow-mgmt-traffic" {
  name        = "ti-ai-allow-mgmt-traffic"
  project     = "gcp-gcs-pso"
  network     = "ti-ai-mgt"
  description = "Allow panorama and fw to use certain TCP ports (need for HA)"

  direction = "INGRESS"
  priority  = 1000

  source_ranges = [
    "192.168.0.0/24",
    "199.167.52.5/32", # Franklin Corporate
  ]

  allow {
    protocol = "tcp"
    ports    = ["22", "443", "3978", "8080", "8443", "28769"]
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

module "internal_lb" {
  source = "github.com/gruntwork-io/terraform-google-load-balancer.git//modules/internal-load-balancer?ref=v0.5.0"

  name    = var.name
  region  = var.region
  project = var.project_id

  backends = [
    {
      description = "Instance group for internal-load-balancer test"
      group       = module.vmseries.instance_groups["ti-ai-fw01"].self_link
    },
  ]

  # This setting will enable internal DNS for the load balancer
  service_label = var.name

  network    = module.vpc.networks["ti-ai-dmz"].self_link
  subnetwork = module.vpc.subnetworks["ti-ai-dmz"].self_link

  health_check_port = 5000
  http_health_check = false
  target_tags       = [var.name]
  source_tags       = [var.name]
  ports             = ["5000"]

  //custom_labels = var.custom_labels
}

# ------------------------------------------------------------------------------
# CREATE THE PROXY INSTANCE
# ------------------------------------------------------------------------------

resource "google_compute_instance" "proxy" {
  project      = var.project_id
  name         = "${var.name}-proxy-instance"
  machine_type = "f1-micro"
  zone         = var.zone

  # We're tagging the instance with the tag specified in the firewall rule
  tags = []

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  # Make sure we have the proxy flask application running
  metadata_startup_script = data.template_file.proxy_startup_script.rendered

  # Launch the instance in the public subnetwork
  # For details, see https://github.com/gruntwork-io/terraform-google-network/tree/master/modules/vpc-network#access-tier
  network_interface {
    network    = module.vpc.networks["ti-ai-dmz"].self_link
    subnetwork = module.vpc.subnetworks["ti-ai-dmz"].self_link

    access_config {
      // Ephemeral IP
    }
  }
}

data "template_file" "proxy_startup_script" {
  template = file("${path.module}/startup_script.sh")

  # Pass in the internal DNS name and private IP address of the LB
  vars = {
    ilb_address = module.internal_lb.load_balancer_domain_name
    ilb_ip      = module.internal_lb.load_balancer_ip_address
  }
}
