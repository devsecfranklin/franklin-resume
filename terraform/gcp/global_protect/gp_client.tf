resource "google_compute_network" "gp_vpc_network" {
  name = "lab-franklin-gp-client-vpc"
}

resource "google_compute_subnetwork" "gp_subnetwork_east" {
  name          = "lab-franklin-gp-client-subnet"
  ip_cidr_range = "10.252.4.0/24"
  region        = "us-east1"
  network       = google_compute_network.gp_vpc_network.name
}


/* 
    ****************************************************************
    Create GP Client VMs
    ****************************************************************

resource "google_compute_instance" "vm_instance_public" {
  name         = "${lower(var.company)}-${lower(var.app_name)}-${var.environment}-vm${random_id.instance_id.hex}"
  machine_type = var.windows_instance_type
  zone         = var.gcp_zone
  hostname     = "${var.app_name}-vm${random_id.instance_id.hex}.${var.app_domain}"
  tags         = ["rdp", "http"]

  boot_disk {
    initialize_params {
      image = var.windows_2022_sku
    }
  }

  metadata = {
    sysprep-specialize-script-ps1 = data.template_file.windows-metadata.rendered
  }

  network_interface {
    network    = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.network_subnet.name
    access_config {}
  }
}

*/
