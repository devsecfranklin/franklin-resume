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
    storage_account_name = "custxabc"
    container_name       = "tfstatemarvell"
    key                  = "terraform-vm.tfstate"
  }
}

provider "azurerm" {
  features {}
}

//2. import the storage account like so: 
// terraform import azurerm_storage_account.tfstate /subscriptions/d47f1af8-9795-4e86-bbce-da72cfd0f8ec/resourceGroups/franklin-lab/providers/Microsoft.Storage/storageAccounts/custx321
resource "azurerm_storage_account" "tfstate" {
  name                     = "custxabc"
  resource_group_name      = "franklin-lab"
  location                 = "East US"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

// 1. Create the storage container
//
// 3. import the container like so:
//terraform import azurerm_storage_container.tfstate https://custx321.blob.core.windows.net/tfstatemarvell
resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstatemarvell"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}
