provider "azurerm" {
  features {}
}

variable "location" {
  description = "The Azure region to use."
  default     = "West US"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Resource Group to create. If not provided, it will be auto-generated."
  default     = "lab-franklin"
  type        = string
}

variable "tags" {
  description = "Map of tags to be associated with the virtual machines, their interfaces and public IP addresses."
  default     = {}
  type        = map(string)
}

# terraform import azurerm_resource_group.lab_franklin /subscriptions/d47f1af8-9795-4e86-bbce-da72cfd0f8ec/resourceGroups/lab-franklin
resource "azurerm_resource_group" "lab_franklin" {
  name     = var.resource_group_name # coalesce(var.resource_group_name, "${var.name_prefix}")
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "labfraaztest123"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.tags
}

//************************ dont add anything new to these, prepare for deletion *********//


// import existing storage account like so:
// 
resource "azurerm_storage_account" "tfstate_old" {
  name                     = "franklintfstate"
  resource_group_name      = "franklin-lab"
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

// import the container like so:
// terraform import azurerm_storage_container.tfstate_common /subscriptions/d47f1af8-9795-4e86-bbce-da72cfd0f8ec/resourceGroups/lab-franklin/providers/Microsoft.Storage/storageAccounts/labfraaztest123/blobServices/default/containers/tfstatelabinfra
resource "azurerm_storage_container" "tfstate_common" {
  name                  = "tfstatecommon"
  storage_account_name  = azurerm_storage_account.tfstate_old.name
  container_access_type = "private"
}
