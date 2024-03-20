/*
resource "azurerm_resource_group" "pso-automation" {
  name     = var.resource_group_name
  location = var.location
  tags     = {}
}
*/
data "azurerm_resource_group" "pso-automation" {
  name = var.resource_group_name
}


module "vnet" {
  source = "Azure/vnet/azurerm"

  resource_group_name = data.azurerm_resource_group.pso-automation.name
  vnet_name           = var.vnet_name
  address_space       = var.address_space
  subnet_prefixes     = var.subnet_prefixes
  subnet_names        = var.subnet_names
  tags                = var.tags

  depends_on = [data.azurerm_resource_group.pso-automation]
}

module "nsg" {
  source = "Azure/network-security-group/azurerm"

  resource_group_name     = data.azurerm_resource_group.pso-automation.name
  location                = data.azurerm_resource_group.pso-automation.location
  security_group_name     = var.security_group_name
  source_address_prefixes = keys(var.management_ips)
  tags                    = var.tags
  predefined_rules = [
    //{ name = "SSH" },
    { name = "HTTPS" },
  ]
}

resource "azurerm_subnet_network_security_group_association" "public" {
  network_security_group_id = module.nsg.network_security_group_id
  subnet_id                 = module.vnet.vnet_subnets[0]
}

# Generate a random password.
resource "random_password" "this" {
  length           = 16
  min_lower        = 16 - 4
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  override_special = "_%@"
}

# While this example does not require a bootstrap file share,
# we will use the module just to get a storage blob.
# The blob will hold boot diagnostics of our virtual machine.
module "bootstrap" {
  source = "./modules/bootstrap"

  resource_group_name  = data.azurerm_resource_group.pso-automation.name
  location             = data.azurerm_resource_group.pso-automation.location
  storage_account_name = var.storage_account_name
}

module "panorama_1" {
  source = "./modules/panorama"

  panorama_name       = var.primary_panorama_name
  resource_group_name = data.azurerm_resource_group.pso-automation.name
  location            = data.azurerm_resource_group.pso-automation.location
  avzone              = var.p1_avzone
  enable_zones        = var.enable_zones
  custom_image_id     = var.custom_image_id
  panorama_sku        = var.panorama_sku
  panorama_size       = var.panorama_size
  panorama_version    = var.panorama_version
  tags                = var.tags

  interface = [ // Only one interface in Panorama VM is supported
    {
      name               = "mgmt-panorama-primary"
      subnet_id          = module.vnet.vnet_subnets[0]
      private_ip_address = var.primary_panorama_private_ip_address
      public_ip          = true
      public_ip_name     = var.primary_panorama_name
    }
  ]

  logging_disks = {
    disk_name_1 = {
      size : "2048"
      lun : "1"
    }
    disk_name_2 = {
      size : "2048"
      lun : "2"
    }
  }

  username                    = var.username
  password                    = random_password.this.result
  boot_diagnostic_storage_uri = module.bootstrap.storage_account.primary_blob_endpoint
}

module "panorama_2" {
  source = "./modules/panorama"

  panorama_name       = var.secondary_panorama_name
  resource_group_name = data.azurerm_resource_group.pso-automation.name
  location            = data.azurerm_resource_group.pso-automation.location
  avzone              = var.p2_avzone
  enable_zones        = var.enable_zones
  custom_image_id     = var.custom_image_id
  panorama_sku        = var.panorama_sku
  panorama_size       = var.panorama_size
  panorama_version    = var.panorama_version
  tags                = var.tags

  interface = [ // Only one interface in Panorama VM is supported
    {
      name               = "mgmt-panorama-secondary"
      subnet_id          = module.vnet.vnet_subnets[0]
      private_ip_address = var.secondary_panorama_private_ip_address
      public_ip          = true
      public_ip_name     = var.secondary_panorama_name
    }
  ]

  logging_disks = {
    disk_name_1 = {
      size : "2048"
      lun : "1"
    }
    disk_name_2 = {
      size : "2048"
      lun : "2"
    }
  }

  username                    = var.username
  password                    = random_password.this.result
  boot_diagnostic_storage_uri = module.bootstrap.storage_account.primary_blob_endpoint
}
