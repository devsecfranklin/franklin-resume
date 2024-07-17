provider "azurerm" {
  features {}
  skip_provider_registration = "true"
  subscription_id            = var.subscription
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
