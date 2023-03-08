data "google_container_engine_versions" "gke_version" {
  location = var.zone
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
      ip_cidr_range = "10.250.0.0/23"
      range_name    = "${var.name_prefix}-gke-pods-d45be269"
    },
    {
      ip_cidr_range = "10.248.0.0/23"
      range_name    = "${var.name_prefix}-gke-pods-d45ce269"
    },
  ]
}

resource "google_container_cluster" "primary" {
  name       = "${var.name_prefix}-gke"
  project    = var.project_id
  location   = var.region
  network    = data.google_compute_network.mgmt-vpc.name
  subnetwork = "${var.name_prefix}-gke-subnet"
  // min_master_version = data.google_container_engine_versions.gke_version.latest_master_version
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

  # https://github.com/hashicorp/terraform-provider-google/issues/5154
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "/16"
    services_ipv4_cidr_block = "/22"
  }

  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    # This range must not overlap with any other ranges in use within 
    # the cluster's network, and it must be a /28 subnet. 
    master_ipv4_cidr_block = "10.254.0.16/28"
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
    // Enable network policy (Calico) as an addon.
    network_policy_config {
      disabled = false
    }
    http_load_balancing {
      disabled = false
    }
    // Provide the ability to scale pod replicas based on real-time metrics
    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  cluster_autoscaling {
    enabled = true
    resource_limits {
      resource_type = "memory"
      minimum       = 2
      maximum       = 64
    }
    resource_limits {
      resource_type = "cpu"
      minimum       = 2
      maximum       = 16
    }
    auto_provisioning_defaults {
      service_account = var.service_account_terraform
      oauth_scopes = [
        "https://www.googleapis.com/auth/cloud-platform"
      ]
    }
  }

  release_channel {
    channel = "REGULAR" # [UNSPECIFIED RAPID REGULAR STABLE]
  }
}

