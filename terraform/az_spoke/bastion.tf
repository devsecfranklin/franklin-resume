resource "azurerm_public_ip" "westBastionPIP" {
  name                = "${var.prefix}-west-bastion-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "west_bastion" {
  name                = "${var.prefix}-west-bastion"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                 = "bastion-ip-config"
    subnet_id            = tolist(azurerm_virtual_network.west_vnet.subnet)[1].id
    public_ip_address_id = azurerm_public_ip.westBastionPIP.id
  }
}

resource "azurerm_public_ip" "eastBastionPIP" {
  name                = "${var.prefix}-east-bastion-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "east_bastion" {
  name                = "${var.prefix}-east-bastion"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                 = "bastion-ip-config"
    subnet_id            = tolist(azurerm_virtual_network.east_vnet.subnet)[1].id
    public_ip_address_id = azurerm_public_ip.eastBastionPIP.id
  }
}
