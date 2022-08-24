# Create a Resource Group.
resource "azurerm_resource_group" "this" {
  name     = "${var.prefix}-test-rg"
  location = var.location
}

# import the VMseries vnet 
data "azurerm_virtual_network" "vmseries_vnet" {
  name                = var.vmseries_vnet
  resource_group_name = var.vmseries_rg
}