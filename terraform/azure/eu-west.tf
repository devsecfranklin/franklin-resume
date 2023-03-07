resource "azurerm_virtual_network" "eu_west" {
  name                = coalesce("eu-west", "${var.name_prefix}")
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space_eu_west
  dns_servers         = ["8.8.4.4", "8.8.8.8"]

  subnet {
    name           = coalesce("eu-west-app1", "${var.name_prefix}")
    address_prefix = "10.10.8.0/28"
    security_group = azurerm_network_security_group.lab-franklin.id
  }

  subnet {
    name           = coalesce("eu-west-app2", "${var.name_prefix}")
    address_prefix = "10.10.8.16/28"
    security_group = azurerm_network_security_group.lab-franklin.id
  }

  tags = var.tags
}

# Create subnet
resource "azurerm_subnet" "west_app1_terraform_subnet" {
  virtual_network_name = azurerm_virtual_network.eu_west.name
  name                 = coalesce("eu-west-app1", "${var.name_prefix}")
  resource_group_name  = var.resource_group_name
  address_prefixes     = ["10.10.8.0/28"]
  //security_group       = azurerm_network_security_group.lab-franklin.id
}

resource "azurerm_subnet" "west_app2_terraform_subnet" {
  virtual_network_name = azurerm_virtual_network.eu_west.name
  name                 = coalesce("eu-west-app2", "${var.name_prefix}")
  resource_group_name  = var.resource_group_name
  address_prefixes     = ["10.10.8.16/28"]
  //security_group       = azurerm_network_security_group.lab-franklin.id
}

# Create public IPs
resource "azurerm_public_ip" "west_terraform_public_ip" {
  name                = coalesce("eu-west-app1", "${var.name_prefix}")
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "west_terraform_nic" {
  name                = coalesce("eu-west-nic", "${var.name_prefix}")
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "west_nic_configuration"
    subnet_id                     = azurerm_subnet.west_app1_terraform_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.west_terraform_public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "west-nsg-assc" {
  network_interface_id      = azurerm_network_interface.west_terraform_nic.id
  network_security_group_id = azurerm_network_security_group.lab-franklin.id
}

/*


resource "azurerm_linux_virtual_machine" "my_terraform_vm" {
  name                  = "myVM"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.my_terraform_nic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name                   = "myvm"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.example_ssh.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.my_storage_account.primary_blob_endpoint
  }
}

*/
