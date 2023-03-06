# import /subscriptions/d47f1af8-9795-4e86-bbce-da72cfd0f8ec/resourceGroups/lab-franklin
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

# id=https://labfraaztest123.blob.core.windows.net/tfstatelabinfra]
resource "azurerm_storage_container" "tfstate_common" {
  name                  = "tfstatelabinfra"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}


resource "azurerm_network_security_group" "lab-franklin" {
  name                = coalesce("nsg", "${var.name_prefix}")
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
