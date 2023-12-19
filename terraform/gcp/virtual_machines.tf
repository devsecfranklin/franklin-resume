// add airlock host here

data "template_file" "linux-metadata" {
  template = <<EOF
sudo apt-get update; 
sudo apt-get install -y neofetch automake gawk git rsyslog;
EOF
}

/* ********* Airlock **********

This one resolves as ctf.dead10c5.org

*/

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
