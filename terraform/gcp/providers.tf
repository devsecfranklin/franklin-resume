terraform {
  backend "gcs" {
    bucket = "lab-franklin-terraform"
    prefix = "terraform/state"
    //credentials = "credentials.json"
  }
}
//provider "template" {} # deprecated
data "google_client_config" "current" {}
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
  //impersonate_service_account = var.service_account_terraform
}
provider "google-beta" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
  //credentials = "credentials.json"
}
provider "kubernetes" {
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.current.access_token
}
provider "helm" {
  kubernetes {
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
    host                   = "https://${google_container_cluster.primary.endpoint}"
    token                  = data.google_client_config.current.access_token
  }
}