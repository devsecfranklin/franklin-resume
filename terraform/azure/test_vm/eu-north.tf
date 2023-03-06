resource "azurerm_virtual_network" "eu_north" {
  name                = coalesce("eu-north", "${var.name_prefix}")
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space_eu_north
  dns_servers         = ["8.8.4.4", "8.8.8.8"]
  tags                = var.tags
}

# Create subnet
resource "azurerm_subnet" "north_app1_terraform_subnet" {
  virtual_network_name = azurerm_virtual_network.eu_north.name
  name                 = coalesce("eu-north-app1", "${var.name_prefix}")
  resource_group_name  = var.resource_group_name
  address_prefixes     = ["10.10.8.128/28"]
  //security_group       = azurerm_network_security_group.lab-franklin.id
}

resource "azurerm_subnet" "north_app2_terraform_subnet" {
  virtual_network_name = azurerm_virtual_network.eu_north.name
  name                 = coalesce("eu-north-app2", "${var.name_prefix}")
  resource_group_name  = var.resource_group_name
  address_prefixes     = ["10.10.8.144/28"]
  //security_group       = azurerm_network_security_group.lab-franklin.id
}

# Create public IPs
resource "azurerm_public_ip" "north_terraform_public_ip" {
  name                = coalesce("eu-north-app1", "${var.name_prefix}")
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

# Create network interface
resource "azurerm_network_interface" "north_terraform_nic" {
  name                = coalesce("eu-north-nic", "${var.name_prefix}")
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "north_nic_configuration"
    subnet_id                     = azurerm_subnet.north_app1_terraform_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.north_terraform_public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "north-nsg-assc" {
  network_interface_id      = azurerm_network_interface.north_terraform_nic.id
  network_security_group_id = azurerm_network_security_group.lab-franklin.id
}

resource "azurerm_linux_virtual_machine" "north_app1_vm" {
  name                  = "north-app1-vm"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.north_terraform_nic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "northOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name                   = "north-app1-vm"
  admin_username                  = "panadmin"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "panadmin"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCu+5vKjTtTWZwlDlm7AlmQdWKujHq7cWnoeJZa/sUGNj+rg8d+SfJZCF+cSuOEFxqJ6wVbX5WSAvB0MNETtncVsC6NvKNSGFsc8vIrIas5cQtyk8frp6SA9aJ/M90p2ekYwPVhqshGCLiRZ1enbm+8uvpGZkWW/g7eQV8HbxFnFCsdf9JZzHcnXWOD8tkRO9r/uuIX31BmVxEG2YE8IPC3Xq18hGglLsi0vOGdBicfOGGc/DRsw6wxXSjXF66nJAxmKZgg4lWzNIe8MkEJthI9cWPsTWcJC3XPpRuKQY6crofZa+atwkymhYJ/MUIJW4172cWLpbA1+4dvSFKSUpyo/Qs+0Zpft8vVvceaDhOsNCpzKk/qINZ3Z+Q/B4I9Ribw83K3FwfAlr6t35Z4j7cCw3VrlJtyVHrwUnVwkCNuw2zcWISfXSnCCFyVgxiJltnqk6CBOUfk6P3qIXqvQqQqp3cB1SiimVtSN5bzITiNnAdySnOUYJIsmMxkPH0Qua8cOQNNs2Ns9zAjgilTZtzG0siJtWmHJrg8+3jMG5mwzOvIgT3DadAx5ao1/+8ak4gBfoqSrLSJXPwW8Myl/I3/uxVkbxb4+jjJwnxKsbGS5LnfVGSvqEFXgtGYfNz79emdIWf3Tbh6Lv9+3Rrt9maCPg3/i5QtWBpaflI2RxurbQ== fdiaz@paloaltonetworks.com"
  }

  #boot_diagnostics {
  #  storage_account_uri = azurerm_storage_account.my_storage_account.primary_blob_endpoint
  #}
}
