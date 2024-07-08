terraform {
  required_version = ">= 1.0, < 2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.111.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "lab-franklin"
    storage_account_name = "labfraaztest123"
    container_name       = "tfstatelabinfra"
    key                  = "terraform-test.tfstate"
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = "true"
  # subscription_id            = var.subscription
}
