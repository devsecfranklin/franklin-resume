terraform {
  required_version = ">= 0.13, < 2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.44.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "franklin-lab"
    storage_account_name = "franklinx321"       # create manually in az portal
    container_name       = "az-transit-tfstate" # create manually in az portal
    key                  = "terraform-vm.tfstate"
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "franklinx321"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "az-transit-tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}
