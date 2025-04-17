# terraform import azurerm_resource_group.lab_franklin /subscriptions/d47f1af8-9795-4e86-bbce-da72cfd0f8ec/resourceGroups/lab-franklin
resource "azurerm_resource_group" "lab_franklin" {
  name     = var.resource_group_name # coalesce(var.resource_group_name, "${var.name_prefix}")
  location = var.az_location
  tags     = var.tags
  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "labfraaztest123"
  resource_group_name      = var.resource_group_name
  location                 = var.az_location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.tags
}

resource "azurerm_storage_container" "tfstate_labinfra" {
  name                  = "tfstatelabinfra"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}
