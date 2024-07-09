resource "google_compute_disk" "development" {
  name = "lab-franklin-dev"
  type = "pd-standard"
  zone = "us-central1-a"
  size = "50"

  lifecycle {
    prevent_destroy = true
  }

}

