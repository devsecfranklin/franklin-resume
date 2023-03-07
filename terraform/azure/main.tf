# import /subscriptions/d47f1af8-9795-4e86-bbce-da72cfd0f8ec/resourceGroups/lab-franklin
resource "azurerm_resource_group" "lab_franklin" {
  name     = var.resource_group_name # coalesce(var.resource_group_name, "${var.name_prefix}")
  location = var.location
  tags     = var.tags
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

