// GCP backend storage bucket for Terraform
resource "google_storage_bucket" "terraform_state" {
  project  = var.project_id
  name     = "${var.name}-gcp-terraform"
  location = var.region

  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_dns_managed_zone" "openshift" {
  name     = "demo-openshift"
  dns_name = "demo-openshift.com."
}

resource "google_dns_record_set" "openshift" {
  managed_zone = google_dns_managed_zone.openshift.name

  name = "www.${google_dns_managed_zone.openshift.dns_name}"
  type = "NS"
  rrdatas = [
    "ns-cloud-b1.googledomains.com.",
    "ns-cloud-b2.googledomains.com.",
    "ns-cloud-b3.googledomains.com.",
    "ns-cloud-b4.googledomains.com."]
  ttl = 300
}

