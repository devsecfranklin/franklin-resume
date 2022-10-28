# https://github.com/kubernetes/kubernetes/issues/79739
resource "google_compute_firewall" "allow-tekton-webhook" {
  name        = "${var.name}-allow-tekton-webhook"
  project     = var.project_id
  network     = google_compute_network.vpc.name
  description = "Allow Tekton webhook ingress traffic"

  allow {
    protocol = "tcp"
    ports = [
      "443",
      "8008", # http-profiling
      "8080", # probes
      "8443", # https-webhook
      "9090", # http-metrics
      "9443"  # GitHub webhook
    ]
  }
  allow {
    protocol = "udp"
  }

  direction = "INGRESS"
  # make these match the secondary ip range in main.tf
  # kubectl get endpoints -n tekton-pipelines
  # kubectl describe endpoints tekton-pipelines-webhook -n tekton-pipelines
  source_ranges = [
    "10.188.0.0/16",
    "10.189.0.0/22"
  ]
}

module "tekton" {
  source = "github.com/devsecfranklin/terraform-kubernetes-tekton"

  name = var.name // pass name of cluster to module

  depends_on = [
    google_container_node_pool.dev_nodes
  ]
}
