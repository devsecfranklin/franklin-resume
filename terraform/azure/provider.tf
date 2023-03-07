terraform {
  required_version = ">= 1.0, < 2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.46.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
  /* Comment out the back end, do a tf init, uncomment and migrate state */
  backend "azurerm" {
    resource_group_name  = "lab-franklin"
    storage_account_name = "labfraaztest123"
    container_name       = "tfstatelabinfra"
    key                  = "terraform-test.tfstate"
  }
}
