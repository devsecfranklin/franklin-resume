// terraform import azurerm_resource_group.franklin_lab /subscriptions/d47f1af8-9795-4e86-bbce-da72cfd0f8ec/resourceGroups/franklin-lab
resource "azurerm_resource_group" "franklin_lab" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}


// import existing storage account like so:
// terraform import azurerm_storage_account.tfstate /subscriptions/d47f1af8-9795-4e86-bbce-da72cfd0f8ec/resourceGroups/franklin-lab/providers/Microsoft.Storage/storageAccounts/franklin-tfstate
resource "azurerm_storage_account" "tfstate" {
  name                     = "franklintfstate"
  resource_group_name      = azurerm_resource_group.franklin_lab.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

// import the container like so:
//terraform import azurerm_storage_container.tfstate https://franklintfstate.blob.core.windows.net/tfstatecommon
resource "azurerm_storage_container" "tfstate_common" {
  name                  = "tfstatecommon"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

// Create the storage container for az_spoke
// You can import the container like so:
//terraform import azurerm_storage_container.tfstate https://franklintfstate.blob.core.windows.net/tfstatespoke
resource "azurerm_storage_container" "tfstate_spoke" {
  name                  = "tfstatespoke"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}
