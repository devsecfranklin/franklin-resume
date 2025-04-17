data "template_file" "linux-metadata" {
  template = <<EOF
sudo apt-get update;
sudo apt-get install -y neofetch automake gawk git rsyslog nginx direnv pass;
cd /tmp && wget https://go.dev/dl/go1.23.3.linux-amd64.tar.gz;
if [ -d "/usr/local/go" ]; then sudo rm -rf /usr/local/go;fi && sudo tar -C /usr/local -xzf go1.23.3.linux-amd64.tar.gz;
/usr/local/go/bin/go install github.com/aquasecurity/tfsec/cmd/tfsec@latest
EOF
}

resource "google_compute_address" "airlock1_static" {
  name = "${var.name_prefix}-ipv4-address"
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_instance" "gcp_airlock" {
  name         = "${var.name_prefix}-airlock1"
  machine_type = var.linux_instance_type
  zone         = var.zone
  //hostname     = "airlock1" #must be FQDN
  tags = var.tags
  boot_disk {
    initialize_params {
      image = var.debian_11_sku
    }
  }
  metadata_startup_script = data.template_file.linux-metadata.rendered
  network_interface {
    network    = data.google_compute_network.mgmt-vpc.name
    subnetwork = data.google_compute_subnetwork.mgmt-subnetwork.name
    access_config {
      nat_ip = google_compute_address.airlock1_static.address
    }
  }
  network_interface {
    network    = "ps-devsecops-mgmt"
    subnetwork = "ps-devsecops-mgmt"
  }
  attached_disk {
    device_name = "${var.name_prefix}-dev"
    mode        = "READ_WRITE"
    source      = "https://www.googleapis.com/compute/v1/projects/gcp-gcs-pso/zones/us-central1-a/disks/lab-franklin-dev"
  }
}

// *********** timecube ************ //

/*
resource "google_compute_address" "timecube_static" {
  name = "${var.name_prefix}-tc-ipv4-address"
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_instance" "gcp_timecube" {
  name         = "${var.name_prefix}-timecube"
  machine_type = var.linux_instance_type
  zone         = var.zone
  //hostname     = "timecube" #must be FQDN
  tags = var.tags
  boot_disk {
    initialize_params {
      image = var.debian_11_sku
    }
  }
  metadata_startup_script = data.template_file.linux-metadata.rendered
  network_interface {
    network    = data.google_compute_network.mgmt-vpc.name
    subnetwork = data.google_compute_subnetwork.mgmt-subnetwork.name
    access_config {
      nat_ip = google_compute_address.timecube_static.address
    }
  }
}
*/
