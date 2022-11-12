resource "google_project_service" "cloud_function" {
  project                    = var.project_id
  service                    = "cloudfunctions.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}

resource "google_project_service" "secretmanager" {
  provider                   = google-beta
  service                    = "secretmanager.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}


data "archive_file" "cloudfunction" {
  type        = "zip"
  source_dir  = "../../../src"
  output_path = "${var.cloud_function_repo}/_build/${var.function_name}.zip"
}

resource "google_storage_bucket" "function_artifacts" {
  project  = var.project_id
  name     = var.function_name
  location = "US"

  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "cloudbot_zip" {
  name   = "${var.function_name}-${timestamp()}.zip" // the filename has to be unique or it won't re-upload after first time
  bucket = google_storage_bucket.function_artifacts.name
  source = "_build/${var.function_name}.zip"
}

resource "google_cloudfunctions_function" "function" {
  project = var.project_id
  name    = var.function_name
  region  = var.region

  #available_memory_mb   = 1024
  trigger_http = true
  entry_point  = "main"
  runtime      = "python39"
  description  = "Cloudbot function"
  timeout      = 120

  service_account_email = var.service_account_email # https://cloud.google.com/functions/docs/concepts/exec#timeout
  vpc_connector         = var.connector_id          # use this w/private panorama IP if internal
  #vpc_connector_egress_settings = "ALL_TRAFFIC" # comment this out to keep it internal

  source_archive_bucket = google_storage_bucket.function_artifacts.name
  source_archive_object = google_storage_bucket_object.cloudbot_zip.name

  depends_on = [
    google_project_service.cloud_function,
  ]

  labels = {
    env = var.function_name
    app = "cloudbot-franklin"
  }
}
