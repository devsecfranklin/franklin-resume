/*
resource "google_compute_subnetwork" "openshift_cluster_network" {
  name                     = "${var.name_prefix}-openshift-cluster-network"
  project                  = var.project_id
  region                   = var.openshift-region
  network                  = data.google_compute_network.mgmt-vpc.name
  ip_cidr_range            = "10.128.0.0/14"
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "openshift_machine_network" {
  name                     = "${var.name_prefix}-openshift-machine-network"
  project                  = var.project_id
  region                   = var.openshift-region
  network                  = data.google_compute_network.mgmt-vpc.name
  ip_cidr_range            = "10.0.0.0/16"
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "openshift_service_network" {
  name                     = "${var.name_prefix}-openshift-service-network"
  project                  = var.project_id
  region                   = var.openshift-region
  network                  = data.google_compute_network.mgmt-vpc.name
  ip_cidr_range            = "172.30.0.0/16"
  private_ip_google_access = true
}

data "template_file" "linux-metadata" {
  template = <<EOF
sudo apt-get update;
sudo apt-get upgrade -y;
sudo apt-get autoremove -y;
EOF
}

resource "google_compute_address" "internal_ip" {
  count        = 1
  name         = "${var.name_prefix}-openshift-int-ip-${count.index}"
  project      = var.project_id
  subnetwork   = data.google_compute_subnetwork.aus-mgmt-subnetwork.id
  address_type = "INTERNAL"
  region       = var.openshift-region
  purpose      = "GCE_ENDPOINT"
}

resource "google_compute_instance" "openshift" {
  name         = "lab-franklin-openshift"
  machine_type = "n2-standard-8"
  zone         = var.openshift-zone
  hostname     = "openshift.gcp.bitsmasher.net"
  tags         = ["ssh", "http"]
  boot_disk {
    initialize_params {
      image = var.ubuntu_2004_sku
      size  = "500"
      type  = "pd-ssd"
    }
  }
  network_interface {
    //If you choose custom values of network_interface. You can't mention both network and subnetwork
    //network    = data.google_compute_network.mgmt-vpc.name
    network_ip         = google_compute_address.internal_ip[0].self_link
    subnetwork         = data.google_compute_subnetwork.aus-mgmt-subnetwork.self_link
    subnetwork_project = var.project_id
    access_config {
      network_tier = "PREMIUM"
      //network_tier = "STANDARD"
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
*/