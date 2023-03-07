// GCP backend storage bucket for Terraform
resource "google_storage_bucket" "terraform_state" {
  project  = var.project_id
  name     = "franklin-gcp-terraform"
  location = var.region

  force_destroy               = true
  uniform_bucket_level_access = true
}
