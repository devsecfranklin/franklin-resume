// GCP backend storage bucket for Terraform
resource "google_storage_bucket" "terraform_state" {
  project  = var.project_id
  name     = "lab-franklin"
  location = var.region

  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_compute_network" "vpc" {
  name                    = "${var.name}-vpc"
  project                 = var.project_id
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "network_subnet" {
  name                     = "${var.name}-subnet"
  project                  = var.project_id
  region                   = var.region
  network                  = google_compute_network.vpc.name
  ip_cidr_range            = "10.12.0.0/24"
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "cluster_network" {
  name                     = "${var.name}-cluster-network"
  project                  = var.project_id
  region                   = var.region
  network                  = google_compute_network.vpc.name
  ip_cidr_range            = "10.128.0.0/14"
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "machine_network" {
  name                     = "${var.name}-machine-network"
  project                  = var.project_id
  region                   = var.region
  network                  = google_compute_network.vpc.name
  ip_cidr_range            = "10.0.0.0/16"
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "service_network" {
  name                     = "${var.name}-service-network"
  project                  = var.project_id
  region                   = var.region
  network                  = google_compute_network.vpc.name
  ip_cidr_range            = "172.30.0.0/16"
  private_ip_google_access = true
}

resource "google_compute_firewall" "lab-ingress" {
  name        = "lab-franklin-openshift"
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
    "34.142.40.117/32",
    "68.38.137.81/32",  # Franklin lab
    "34.134.31.136/32", # ps-devsecops-panorama-three-10-0-4 
    "34.136.90.64/32",  # ps-devsecops-panorama-two-10-0-4
    "34.66.44.164/32",  # gke cluster
    "35.185.72.81/32"   # gcp test fw
  ]
}


data "template_file" "linux-metadata" {
  template = <<EOF
sudo apt-get update;
sudo apt-get upgrade -y;
sudo apt-get autoremove -y;
EOF
}

resource "google_compute_instance" "openshift" {
  name         = "openshift-franklin"
  machine_type = "n2-standard-16"
  zone         = var.zone
  hostname     = "openshift.gcp.bitsmasher.net"
  tags         = ["ssh", "http"]
  boot_disk {
    initialize_params {
      image = var.ubuntu_2004_sku
      size  = "600"
      type  = "pd-ssd"
    }
  }
  network_interface {
    network    = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.network_subnet.name
    //network_ip         = "10.10.11.2"
    subnetwork_project = "gcp-gcs-pso"
    access_config {
      network_tier = "PREMIUM"
    }
  }
  // Local SSD disk
  //scratch_disk {
  //  interface = "SCSI"
  // }
  metadata = {
    ssh-keys = "ubuntu:${var.ssh_key}"
  }
  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }
  scheduling {
    automatic_restart   = true
    min_node_cpus       = 0
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }
  labels = {
    runstatus                = "nostop"
    nostop_reason            = "testing_customer_deployment"
    nostop_expected_end_date = "july-2023"
  }
  metadata_startup_script = data.template_file.linux-metadata.rendered
}
