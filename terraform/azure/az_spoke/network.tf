# ### NETWORK PART ###

resource "azurerm_virtual_network" "east_vnet" {
  name                = "${var.prefix}-east-vms"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = var.east_vnet.cdir

  subnet {
    name           = "eastVMs"
    address_prefix = var.east_vnet.eastVMs_cdir
  }
  subnet {
    name           = "AzureBastionSubnet"
    address_prefix = var.east_vnet.bastion_cdir
  }
}

resource "azurerm_virtual_network" "west_vnet" {
  name                = "${var.prefix}-west-vms"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = var.west_vnet.cdir

  subnet {
    name           = "westVMs"
    address_prefix = var.west_vnet.westVMs_cdir
  }
  subnet {
    name           = "AzureBastionSubnet"
    address_prefix = var.west_vnet.bastion_cdir
  }
}

# route tables
resource "azurerm_route_table" "this" {
  name                = "${var.prefix}-vmseries-rt"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  route {
    name                   = "vmseries"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.vmseries_private_olb
  }
}

resource "azurerm_subnet_route_table_association" "rt_east" {
  subnet_id      = tolist(azurerm_virtual_network.east_vnet.subnet)[0].id
  route_table_id = azurerm_route_table.this.id
}

resource "azurerm_subnet_route_table_association" "rt_west" {
  subnet_id      = tolist(azurerm_virtual_network.west_vnet.subnet)[0].id
  route_table_id = azurerm_route_table.this.id
}

# peer VMSERIES network to east
resource "azurerm_virtual_network_peering" "east2vmseries" {
  name                      = "east-vmseries"
  resource_group_name       = azurerm_resource_group.this.name
  virtual_network_name      = azurerm_virtual_network.east_vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.vmseries_vnet.id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "vmseries2east" {
  name                      = "vmseries-east"
  resource_group_name       = var.vmseries_rg
  virtual_network_name      = var.vmseries_vnet
  remote_virtual_network_id = azurerm_virtual_network.east_vnet.id
  allow_forwarded_traffic   = true
}

# peer VMSERIES network 2 west
resource "azurerm_virtual_network_peering" "gw2vmseries" {
  name                      = "west-vmseries"
  resource_group_name       = azurerm_resource_group.this.name
  virtual_network_name      = azurerm_virtual_network.west_vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.vmseries_vnet.id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "vmseries2gw" {
  name                      = "vmseries-west"
  resource_group_name       = var.vmseries_rg
  virtual_network_name      = var.vmseries_vnet
  remote_virtual_network_id = azurerm_virtual_network.west_vnet.id
  allow_forwarded_traffic   = true
}

resource "azurerm_network_security_group" "franklin" {
  name                = "franklinTestSecurityGroup1"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "68.38.137.81/32"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_subnet_network_security_group_association" "rt_east" {
  subnet_id                 = tolist(azurerm_virtual_network.east_vnet.subnet)[0].id
  network_security_group_id = azurerm_network_security_group.franklin.id
}

resource "azurerm_subnet_network_security_group_association" "rt_west" {
  subnet_id                 = tolist(azurerm_virtual_network.west_vnet.subnet)[0].id
  network_security_group_id = azurerm_network_security_group.franklin.id
}
