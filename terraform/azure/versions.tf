terraform {
  required_version = ">= 0.13, < 2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.95.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-ssg-palo-scus"
    storage_account_name = "franklinx123"
    container_name       = "rg-ssg-palo-scus-tfstate"
    key                  = "terraform-vm.tfstate"
  }
}

provider "azurerm" {
  features {}
}
