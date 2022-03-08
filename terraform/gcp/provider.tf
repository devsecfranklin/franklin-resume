terraform {
  required_providers {
    //null     = "~> 3.1.0"
    random   = "~> 3.1.0"
    external = "~> 2.2.0"
  }
  backend "gcs" {
    bucket = "pso-automation-dev"
    prefix = "dev-tf"
    //credentials = "$GOOGLE_APPLICATION_CREDENTIALS"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  //impersonate_service_account = var.service_account_terraform
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

/*
 * To learn how to schedule deployments and services using the provider, 
 * go here: https://learn.hashicorp.com/tutorials/terraform/kubernetes-provider
 */

/*
provider "kubernetes" {
  //load_config_file = "false"

  host     = google_container_cluster.primary.endpoint
  username = var.gke_username
  password = var.gke_password

  client_certificate     = google_container_cluster.primary.master_auth.0.client_certificate
  client_key             = google_container_cluster.primary.master_auth.0.client_key
  cluster_ca_certificate = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
*/
