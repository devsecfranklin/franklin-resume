resource "google_filestore_instance" "filestore" {
  provider = google-beta
  name     = "ctfd"
  location = var.zone
  tier     = "BASIC_HDD"

  file_shares {
    capacity_gb = 1024
    name        = "share1"

    nfs_export_options {
      ip_ranges   = ["10.249.0.0/25", "10.12.0.0/16", "10.13.0.0/22"]
      access_mode = "READ_WRITE"
      squash_mode = "NO_ROOT_SQUASH"
    }
  }
  networks {
    network = data.google_compute_network.mgmt-vpc.name
    modes   = ["MODE_IPV4"]
  }
}

resource "kubernetes_persistent_volume_claim" "ctfd" {
  metadata {
    name      = "ctfd"
    namespace = kubernetes_namespace.ctfd.metadata.0.name
  }
  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = "standard"
    resources {
      requests = {
        storage = "100Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.ctfd.metadata.0.name
  }
  depends_on = [
    kubernetes_namespace.ctfd,
    kubernetes_persistent_volume.ctfd,
    google_container_node_pool.primary
  ]
}

resource "kubernetes_persistent_volume" "ctfd" {
  metadata {
    name = "fileserver"
  }
  spec {
    capacity = {
      storage = "1T"
    }
    access_modes       = ["ReadWriteMany"]
    storage_class_name = "standard"
    persistent_volume_source {
      nfs {
        path   = "/share1"
        server = google_filestore_instance.filestore.networks.0.ip_addresses.0
      }
    }
  }
  depends_on = [
    google_container_cluster.primary,
    google_container_node_pool.primary
  ]
}
