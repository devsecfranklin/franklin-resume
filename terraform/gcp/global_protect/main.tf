resource "google_project_service" "compute_service" {
  project                    = var.project_id
  service                    = "compute.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}
