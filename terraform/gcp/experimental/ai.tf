data "google_tpu_tensorflow_versions" "available" {
}

resource "google_tpu_node" "tpu" {
  name = "test-tpu"
  zone = "us-central1-a"

  accelerator_type   = "v3-8"
  tensorflow_version = data.google_tpu_tensorflow_versions.available.versions[0]
  cidr_block         = "10.2.0.0/29"
}

/*
resource "google_project_service" "machine_learning" {
  project                    = var.project_id
  service                    = "ml.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}

resource "google_ml_engine_model" "default" {
  name        = "url-classifier"
  description = "franklin-test-model"
  regions     = ["us-central1"]
}
*/

/*
resource "google_project_service" "ai_platform" {
  project                    = var.project_id
  service                    = "aiplatform.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}

resource "google_project_service" "jupyter_notebooks" {
  project                    = var.project_id
  service                    = "notebooks.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}

resource "google_notebooks_instance" "instance" {
  name         = "notebooks-instance"
  location     = "us-central1-a"
  machine_type = "n1-standard-1" // can't be e2 because of accelerator

  install_gpu_driver = true
  accelerator_config {
    type       = "NVIDIA_TESLA_T4"
    core_count = 1
  }
  vm_image {
    project      = "deeplearning-platform-release"
    image_family = "tf-latest-gpu"
  }
}
*/
