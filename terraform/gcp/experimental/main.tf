# Gets the current version of Kubernetes engine
data "google_container_engine_versions" "gke_version" { location = var.zone }

/*
resource "google_container_cluster" "primary" {
  name               = var.name
  project            = var.project_id
  location           = var.region
  network            = "ps-devsecops-trust"
  subnetwork         = "ps-devsecops-trust"
  min_master_version = data.google_container_engine_versions.gke_version.latest_master_version
  node_locations = [
    "us-central1-a",
    "us-central1-b",
    "us-central1-c"
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
    master_ipv4_cidr_block = "10.253.0.0/28"
  }

  master_auth {
    username = var.gke_username
    password = var.gke_password

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  # You can ONLY add /32 here or it will trigger security event
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "68.38.137.81/32"
      display_name = "franklin-lab"
    }
    cidr_blocks {
      cidr_block   = "213.189.47.210/32"
      display_name = "kuba-office"
    }
    cidr_blocks {
      cidr_block   = "84.207.227.14/32"
      display_name = "kuba-globalprotect"
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
      minimum       = 10
      maximum       = 100
    }
    resource_limits {
      resource_type = "cpu"
      minimum       = 1
      maximum       = 10
    }

    auto_provisioning_defaults {
      service_account = var.service_account_terraform
      oauth_scopes = [
        "https://www.googleapis.com/auth/cloud-platform"
      ]
    }
  }
}

resource "google_container_node_pool" "node-pool-one" {
  name     = "${google_container_cluster.primary.name}-node-pool-one"
  project  = var.project_id
  location = var.region
  cluster  = google_container_cluster.primary.name

  node_count = var.gke_num_nodes

  autoscaling {
    min_node_count = 2
    max_node_count = 15
  }

  node_config {
    // COS or COS_containerd are ideal here.
    image_type = "COS"
    #using pd-ssd's is recommended for pods that do any scratch disk operations.
    disk_type = "pd-ssd"

    // https://tfsec.dev/docs/google/GCP012/
    // Use a custom service account for this node pool.  Be sure to grant it
    // a minimal amount of IAM roles and not Project Editor like the default SA.
    //service_account = var.service_account_terraform

    // Use the default/minimal oauth scopes to help restrict the permissions to
    // only those needed for GCR and stackdriver logging/monitoring/tracing needs.
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    labels = {
      env = var.name
      app = "ps-devsecops-ci-build" // label used for node selection in CI pipelines
    }

    preemptible  = false
    machine_type = var.node_machine_type
    tags         = ["gke-node", "${var.name}-alpha"]

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  # Fix broken nodes automatically and keep them updated with the control plane.
  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

resource "google_container_node_pool" "node-pool-marcellus-wallace" {
  name     = "${google_container_cluster.primary.name}-node-pool-marcellus-wallace"
  project  = var.project_id
  location = var.region
  cluster  = google_container_cluster.primary.name

  node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 2
  }

  node_locations = [
    "us-central1-c",
  ]

  node_config {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = var.service_account_terraform
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    guest_accelerator {
      type  = "nvidia-tesla-k80"
      count = 1
    }
  }

  # Fix broken nodes automatically and keep them updated with the control plane.
  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

*/
