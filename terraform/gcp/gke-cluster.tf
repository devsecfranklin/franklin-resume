data "google_container_engine_versions" "gke_version" {
  location = var.zone
}

resource "google_compute_router" "router" {
  name    = "${var.name_prefix}-router"
  project = var.project_id
  region  = var.region
  network = data.google_compute_network.mgmt-vpc.name
}

module "cloud-nat" {
  source                             = "terraform-google-modules/cloud-nat/google"
  version                            = "~> 3.0"
  project_id                         = var.project_id
  region                             = var.region
  router                             = google_compute_router.router.name
  name                               = "nat-config"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_subnetwork" "gke-subnet" {
  name                     = "${var.name_prefix}-gke-subnet"
  project                  = var.project_id
  region                   = var.region
  network                  = data.google_compute_network.mgmt-vpc.name
  ip_cidr_range            = "10.249.0.0/25"
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
      ip_cidr_range = "10.12.0.0/16"
      range_name    = "gke-lab-franklin-gke-pods-f23f12d3"
    },
    {
      ip_cidr_range = "10.13.0.0/22"
      range_name    = "gke-lab-franklin-gke-services-f23f12d3"
    },

  ]
}

resource "google_container_cluster" "primary" {
  name               = "${var.name_prefix}-gke"
  project            = var.project_id
  location           = var.region
  network            = data.google_compute_network.mgmt-vpc.name
  subnetwork         = "${var.name_prefix}-gke-subnet"
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
  networking_mode    = "VPC_NATIVE"

  // min_master_version = data.google_container_engine_versions.gke_version.latest_master_version

  // optional, creates a zonal cluster
  node_locations = [
    "us-central1-a",
    "us-central1-b",
    "us-central1-c",
    "us-central1-f"
  ]

  remove_default_node_pool    = true
  initial_node_count          = 1
  enable_shielded_nodes       = true
  enable_intranode_visibility = true

  workload_identity_config {
    workload_pool = "gcp-gcs-pso.svc.id.goog"
  }

  # https://github.com/hashicorp/terraform-provider-google/issues/5154
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "/16"
    services_ipv4_cidr_block = "/22"
  }

  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true // only use private nodes, no public IP on nodes
    # This range must not overlap with any other ranges in use within 
    # the cluster's network, and it must be a /28 subnet. 
    master_ipv4_cidr_block = "10.254.0.16/28" // CIDR range for control plane since it is managed by google
  }

  master_auth {
    //username = var.gke_username
    //password = var.gke_password

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  # You can ONLY add /32 here or it will trigger security event
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "34.103.71.242/32"
      display_name = "corporate-net1"
    }
    cidr_blocks {
      cidr_block   = "68.38.137.81/32"
      display_name = "franklin-lab"
    }
    cidr_blocks {
      cidr_block   = "54.215.48.190/32"
      display_name = "denver-ds"
    }
    cidr_blocks {
      cidr_block   = "34.134.31.136/32"
      display_name = "panorama-three"
    }
    cidr_blocks {
      cidr_block   = "34.136.90.64/32"
      display_name = "panorama-two"
    }
    cidr_blocks {
      cidr_block   = "156.146.51.68/32"
      display_name = "franklin-denver"
    }
  }

  network_policy {
    # In GKE this also enables the ip masquerade agent
    # https://cloud.google.com/kubernetes-engine/docs/how-to/ip-masquerade-agent
    enabled  = true
    provider = "CALICO"
  }

  addons_config {
    network_policy_config {
      disabled = false // Enable network policy (Calico) as an addon.
    }
    http_load_balancing {
      disabled = true // we are using nginx ingress, not needed
    }
    horizontal_pod_autoscaling {
      disabled = false // Provide the ability to scale pod replicas based on real-time metrics
    }
  }

  cluster_autoscaling {
    enabled = true
    auto_provisioning_defaults {
      service_account = var.service_account_terraform
      oauth_scopes = [
        "https://www.googleapis.com/auth/cloud-platform"
      ]
    }
    resource_limits {
      maximum       = 64
      minimum       = 2
      resource_type = "memory"
    }
    resource_limits {
      maximum       = 16
      minimum       = 2
      resource_type = "cpu"
    }
  }

  release_channel {
    channel = "REGULAR" # [UNSPECIFIED RAPID REGULAR STABLE]
  }
}

resource "google_container_node_pool" "cn-series" {
  name       = "security-nodes"
  project    = var.project_id
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 1
  node_locations = [
    "us-central1-c",
    "us-central1-f",
  ]
  autoscaling {
    min_node_count = 1
    max_node_count = 2
  }
  node_config {
    image_type = "COS_CONTAINERD"
    #using pd-ssd's is recommended for pods that do any scratch disk operations.
    disk_type         = "pd-ssd"
    disk_size_gb      = 100
    guest_accelerator = []
    local_ssd_count   = 0
    service_account   = "default"
    preemptible       = false
    machine_type      = "n1-standard-8"
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/devstorage.read_write",
      "https://www.googleapis.com/auth/compute",
    ]
    labels = {
      env      = "cn-series-stateful"
      paloalto = "ps-east-cn-series"
    }
    metadata = {
      disable-legacy-endpoints = "true"
    }
    tags = [
      "gke-node",
      "ps-east-gke",
      "lab-franklin"
    ]
    taint = []
    shielded_instance_config {
      enable_integrity_monitoring = true
      enable_secure_boot          = false
    }
    # Enable_gke_metadata_server is not supported on clusters that do not have Workload Identity enabled
    #workload_metadata_config {
    #  mode = "GKE_METADATA"
    #}
  }
  upgrade_settings {
    max_surge       = 20
    max_unavailable = 0
  }
  # Fix broken nodes automatically and keep them updated with the control plane.
  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

resource "google_container_node_pool" "production" {
  name       = "${var.name_prefix}-development"
  project    = var.project_id
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 1
  node_locations = [
    "us-central1-a",
    "us-central1-b",
    "us-central1-c",
    "us-central1-f",
  ]
  autoscaling {
    min_node_count = 2
    max_node_count = 64
  }
  node_config {
    image_type = "COS_CONTAINERD"
    #using pd-ssd's is recommended for pods that do any scratch disk operations.
    disk_type         = "pd-ssd"
    disk_size_gb      = 100
    guest_accelerator = []
    local_ssd_count   = 0
    service_account   = "default"
    preemptible       = false
    machine_type      = "n1-standard-8"
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/devstorage.read_write",
      "https://www.googleapis.com/auth/compute",
    ]
    labels = {
      env = "dev-node"
      lab = "franklin"
    }
    metadata = {
      disable-legacy-endpoints = "true"
    }
    tags = [
      "gke-node",
      "lab-franklin"
    ]
    taint = []
    shielded_instance_config {
      enable_integrity_monitoring = true
      enable_secure_boot          = false
    }
    # Enable_gke_metadata_server is not supported on clusters that do not have Workload Identity enabled
    #workload_metadata_config {
    #  mode = "GKE_METADATA"
    #}
  }
  upgrade_settings {
    max_surge       = 20
    max_unavailable = 0
  }
  # Fix broken nodes automatically and keep them updated with the control plane.
  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
