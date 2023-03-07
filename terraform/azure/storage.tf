//terraform import azurerm_storage_container.tfstate https://franklintfstate.blob.core.windows.net/tfstatespoke
resource "azurerm_storage_container" "tfstate_spoke" {
  name                  = "tfstatespoke"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}
