data "template_file" "linux-metadata" {
  template = <<EOF
sudo apt-get update;
sudo apt-get install -y qemu-kvm;
sudo apt-get upgrade -y;
sudo apt-get autoremove -y;
sudo snap install microstack --beta;
sudo microstack init --auto --control;
EOF
}

resource "google_compute_instance" "openstack" {
  name         = "openstack-franklin"
  machine_type = "n1-standard-32"
  zone         = var.zone
  hostname     = "openstack.gcp.bitsmasher.net"
  tags         = ["ssh", "http"]
  boot_disk {
    initialize_params {
      image = var.ubuntu_2004_sku
      size  = "600"
      type  = "pd-ssd"
    }
  }
  network_interface {
    network            = "https://www.googleapis.com/compute/v1/projects/gcp-gcs-pso/global/networks/ps-devsecops-mgmt"                 # google_compute_network.vpc.name
    subnetwork         = "https://www.googleapis.com/compute/v1/projects/gcp-gcs-pso/regions/us-central1/subnetworks/ps-devsecops-mgmt" # google_compute_subnetwork.network_subnet.name
    network_ip         = "192.168.0.6"
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
  metadata_startup_script = data.template_file.linux-metadata.rendered
}
