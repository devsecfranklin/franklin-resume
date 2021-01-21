provider "google" {
  project = "project_name"
  region  = "us-central1"
  zone    = "us-central1-a"
}

provider "google-beta" {
  project = "my-resume-71445"
  region  = "us-central1"
  zone    = "us-central1-a"
}

resource "google_cloud_run_service" "service" {
  #name     = var.name
  name     = "franklin-resume"
  #location = var.location
  location = "dev"
  provider = google-beta

  metadata {
    #namespace = var.project
    namespace = "my-resume-71445"
  }

  template {
    spec {
      containers {
        image = "${var.image}@${var.digest}"
        resources {
          limits = {
            cpu    = "1000m"
            memory = "1024Mi"
          }
        }
      }
    }
  }
}