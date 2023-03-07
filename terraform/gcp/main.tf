
// Management network for Panoramas
resource "google_compute_network" "vpc" {
  name                    = "${var.name}-mgmt-vpc"
  project                 = var.project_id
  auto_create_subnetworks = "false"
}
