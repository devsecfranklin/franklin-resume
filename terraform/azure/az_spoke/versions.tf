terraform {
  required_version = ">= 0.13, < 2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "franklin-lab"
    storage_account_name = "custxxyz"
    container_name       = "tfstatespoke"
    key                  = "terraform-vm.tfstate"
  }
}

provider "azurerm" {
  features {}
}
