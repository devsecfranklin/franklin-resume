resource "google_cloud_run_service" "default" {
  name     = "${prefix}-resume"
  location = var.region


  template {
    spec {
      containers {
        image = "ghcr.io/devsecfranklin/franklin-resume"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}
