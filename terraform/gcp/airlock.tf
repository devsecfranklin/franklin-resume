// add airlock host here

data "template_file" "linux-metadata" {
  template = <<EOF
sudo apt-get update; 
sudo apt-get install -y apache2;
sudo systemctl start apache2;
sudo systemctl enable apache2;
EOF
}

resource "google_compute_instance" "gcp_airlock" {
  name         = "airlock1"
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
    access_config {}
  }
}
