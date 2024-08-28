# Configure Terraform
terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.53.0"
    }
  }
}

# Configure the Azure Active Directory Provider
provider "azuread" {
  tenant_id = "66b66353-3b76-4e41-9dc3-fee328bd400e" // az account list | grep tenantId
}

# Retrieve domain information
data "azuread_domains" "AzureGCSPS" {
  only_initial = true
}

# Create an application
resource "azuread_application" "lab-franklin" {
  display_name = "lab-franklin"
}

# Create a service principal
resource "azuread_service_principal" "az_svc_princ" {
  client_id    = azuread_application.lab-franklin.client_id
  use_existing = true
}

# Create a user
resource "azuread_user" "franklin" {
  user_principal_name = "franklin@${data.azuread_domains.AzureGCSPS.domains.0.domain_name}"
  display_name        = "franklin"
  password            = "clownShoes99"
}
