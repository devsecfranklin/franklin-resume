# Gets the current version of Kubernetes engine
data "google_container_engine_versions" "gke_version" {
  location = var.zone
}

resource "google_container_cluster" "primary" {
  name       = "${var.name}-gke"
  project    = var.project_id
  location   = var.region
  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.gke-subnet.name
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
    master_ipv4_cidr_block = "10.254.0.0/28"
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

resource "google_container_node_pool" "primary_nodes" {
  #name     = "${google_container_cluster.primary.name}-node-pool"
  name     = "ps-east-dev"
  project  = var.project_id
  location = var.region
  cluster  = google_container_cluster.primary.name

  node_count = var.gke_num_nodes
  node_locations = [
    "us-central1-a",
    "us-central1-b",
    "us-central1-c",
    "us-central1-f",
  ]
  autoscaling {
    min_node_count = 1
    max_node_count = 64
  }

  node_config {
    image_type        = "COS_CONTAINERD"
    disk_type         = "pd-ssd"
    disk_size_gb      = 100
    guest_accelerator = []
    local_ssd_count   = 0
    service_account   = "default"
    preemptible       = false

    // https://tfsec.dev/docs/google/GCP012/
    // Use a custom service account for this node pool.  Be sure to grant it
    // a minimal amount of IAM roles and not Project Editor like the default SA.
    //service_account = var.service_account_terraform

    // Use the default/minimal oauth scopes to help restrict the permissions to
    // only those needed for GCR and stackdriver logging/monitoring/tracing needs.
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_write",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    labels = {
      # env = var.name
      env = "dev-node"
      app = "ps-east-dev" // label used for node selection in CI pipelines
    }

    machine_type = var.node_machine_type
    tags         = ["gke-node", "ps-east-gke"]

    metadata = {
      disable-legacy-endpoints = "true"
    }
    taint = []
    shielded_instance_config {
      enable_integrity_monitoring = true
      enable_secure_boot          = false
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }
  # Fix broken nodes automatically and keep them updated with the control plane.
  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

// CN series firewall node pool
// https://docs.paloaltonetworks.com/cn-series/10-2/cn-series-deployment/secure-kubernetes-workloads-with-cn-series/cn-series-prerequisites

resource "google_container_node_pool" "cn-series" {
  name       = "security-nodes"
  project    = var.project_id
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 2
  node_locations = [
    "us-central1-c",
    "us-central1-f",
  ]
  //autoscaling {
  //  min_node_count = 1
  //  max_node_count = 36
  //}
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
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
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
