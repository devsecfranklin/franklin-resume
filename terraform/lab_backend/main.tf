// import existing storage account like so: 
// terraform import azurerm_storage_account.tfstate /subscriptions/d47f1af8-9795-4e86-bbce-da72cfd0f8ec/resourceGroups/franklin-lab/providers/Microsoft.Storage/storageAccounts/custxxyz
resource "azurerm_storage_account" "tfstate" {
  name                     = "custxxyz"
  resource_group_name      = "franklin-lab"
  location                 = "East US"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

// 1. Create the storage container for az_transit_common
//
// 3. import the container like so:
//terraform import azurerm_storage_container.tfstate https://custxxyz.blob.core.windows.net/tfstatecommon
resource "azurerm_storage_container" "tfstate_common" {
  name                  = "tfstatecommon"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

// 1. Create the storage container for az_spoke
//
// 3. import the container like so:
//terraform import azurerm_storage_container.tfstate https://custxxyz.blob.core.windows.net/tfstatespoke
resource "azurerm_storage_container" "tfstate_spoke" {
  name                  = "tfstatespoke"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}
