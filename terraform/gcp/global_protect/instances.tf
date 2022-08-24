# Terraform plugin for creating random ids
resource "random_id" "instance_id" {
  byte_length = 4
}

# Bootstrapping Script
data "template_file" "windows-metadata" {
  template = <<EOF
# Install IIS
Install-WindowsFeature -name Web-Server -IncludeManagementTools;
EOF
}

/*
    ****************************************************************
    Create GP Client VMs
    ****************************************************************
*/

resource "google_compute_instance" "vm_instance_public" {
  name         = "lab-franklin-windows"
  project      = var.project_id
  machine_type = var.windows_instance_type
  zone         = var.gcp_zone
  //hostname     = "lab-franklin-windows"
  tags = ["rdp", "http"]

  boot_disk {
    initialize_params {
      image = var.windows_2022_sku
    }
  }

  metadata = {
    sysprep-specialize-script-ps1 = data.template_file.windows-metadata.rendered
  }

  network_interface {
    network    = var.vpc_name
    subnetwork = google_compute_subnetwork.lab_franklin_gp_subnet.id
    access_config {}
  }
}

/*
resource "google_compute_instance" "vm_instance" {
  name         = "nginx-instance"
  machine_type = "f1-micro"

  tags = ["nginx-instance"]

  boot_disk {
    initialize_params {
      image = "centos-7-v20210420"
    }
  }

  metadata_startup_script = <<EOT
curl -fsSL https://get.docker.com -o get-docker.sh && 
sudo sh get-docker.sh && 
sudo service docker start && 
docker run -p 8080:80 -d nginxdemos/hello
EOT

  network_interface {
    network = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.private_network.self_link

    access_config {
      network_tier = "STANDARD"
    }
  }
}
*/

/*
resource "google_compute_address" "this" {
  for_each = { for k, v in var.rules : k => v if !can(v.ip_address) }

  name         = each.key
  address_type = "EXTERNAL"
  region       = var.region
  project      = var.project
}
*/