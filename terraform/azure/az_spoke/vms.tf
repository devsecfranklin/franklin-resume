# INTERNAL HOST

resource "azurerm_network_interface" "east_vm_nic" {
  name                = "${var.prefix}-east-vm-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "nic-condig"
    subnet_id                     = tolist(azurerm_virtual_network.east_vnet.subnet)[0].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "eastVM" {
  name                  = "${var.prefix}-east-vm"
  location              = var.location
  resource_group_name   = azurerm_resource_group.this.name
  network_interface_ids = [azurerm_network_interface.east_vm_nic.id]
  vm_size               = "Standard_DS1_v2"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Bitnami"
    offer     = "wordpress"
    sku       = "4-4"
    version   = "latest"
  }
  storage_os_disk {
    name = "${var.prefix}-eastvm-osdisk"
    # caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${var.prefix}-west-vm"
    admin_username = "panadmin"
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = file("${var.ssh_key_path}")
      path     = "/home/panadmin/.ssh/authorized_keys"
    }
  }
  plan {
    name      = "4-4"
    product   = "wordpress"
    publisher = "bitnami"
  }
}

# west HOST
# resource "azurerm_public_ip" "west_pip" {
#   name                = "${var.prefix}-west-pip"
#   resource_group_name = azurerm_resource_group.this.name
#   location            = var.location
#   allocation_method   = "Dynamic"
# }

resource "azurerm_network_interface" "west_vm_nic" {
  name                = "${var.prefix}-west-vm-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "nic-config"
    subnet_id                     = tolist(azurerm_virtual_network.west_vnet.subnet)[0].id
    private_ip_address_allocation = "Dynamic"
    # public_ip_address_id          = azurerm_public_ip.west_pip.id
  }
}

resource "azurerm_virtual_machine" "westVM" {
  name                  = "${var.prefix}-west-vm"
  location              = var.location
  resource_group_name   = azurerm_resource_group.this.name
  network_interface_ids = [azurerm_network_interface.west_vm_nic.id]
  vm_size               = "Standard_DS1_v2"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "20.04.202201310"
  }
  storage_os_disk {
    name = "${var.prefix}-westvm-osdisk"
    # caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${var.prefix}-west-vm"
    admin_username = "panadmin"
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = file("${var.ssh_key_path}")
      path     = "/home/panadmin/.ssh/authorized_keys"
    }
  }
}
