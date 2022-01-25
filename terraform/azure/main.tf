data "azurerm_resource_group" "savista_rg" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "vnet_hub" {
  name                = var.virtual_network_name
  resource_group_name = data.azurerm_resource_group.savista_rg.name
}

// for panorama connection vnet peering
data "azurerm_virtual_network" "mgmt_vnet" {
  name                = "ssg-vnet-mgmt-southcentralus"
  resource_group_name = data.azurerm_resource_group.savista_rg.name
}

// for panorama connection vnet peering
data "azurerm_virtual_network" "hub_vnet" {
  name                = "ssg-vnethub-prd-southcentralus"
  resource_group_name = "rg-networkinfra-southcentralus"
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

# Create the network components required for the topology.
module "vnet" {
  source = "../../modules/vnet"

  create_virtual_network  = false
  virtual_network_name    = data.azurerm_virtual_network.vnet_hub.name
  location                = data.azurerm_resource_group.savista_rg.location
  resource_group_name     = data.azurerm_resource_group.savista_rg.name
  address_space           = data.azurerm_virtual_network.vnet_hub.address_space
  network_security_groups = var.network_security_groups
  route_tables            = var.route_tables
  subnets                 = var.subnets
  tags                    = var.vnet_tags

  depends_on = [data.azurerm_virtual_network.vnet_hub]
}

# Allow inbound access to Management subnet.
resource "azurerm_network_security_rule" "mgmt" {
  name                        = "vmseries-mgmt-allow-inbound"
  resource_group_name         = data.azurerm_resource_group.savista_rg.name
  network_security_group_name = "nsg-sec-mgmt"
  access                      = "Allow"
  direction                   = "Inbound"
  priority                    = 1000
  protocol                    = "*"
  source_port_range           = "*"
  source_address_prefixes     = var.allow_inbound_mgmt_ips
  destination_address_prefix  = "*"
  destination_port_range      = "*"

  depends_on = [module.vnet]
}

# Create public IPs for the Internet-facing data interfaces so they could talk outbound.
resource "azurerm_public_ip" "public" {
  for_each = var.outbound_vmseries

  name                = "${var.name_prefix}${each.key}-public"
  location            = data.azurerm_resource_group.savista_rg.location
  resource_group_name = data.azurerm_resource_group.savista_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  availability_zone   = var.enable_zones ? "Zone-Redundant" : "No-Zone"
}

# Create public IPs but then replace with static
resource "azurerm_public_ip" "public_gp" {
  for_each = var.gp_vmseries

  name                = "${var.name_prefix}${each.key}-public"
  location            = data.azurerm_resource_group.savista_rg.location
  resource_group_name = data.azurerm_resource_group.savista_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  availability_zone   = var.enable_zones ? "Zone-Redundant" : "No-Zone"
}

resource "azurerm_public_ip" "public_ipsec" {
  for_each = var.ipsec_vmseries

  name                = "${var.name_prefix}${each.key}-public"
  location            = data.azurerm_resource_group.savista_rg.location
  resource_group_name = data.azurerm_resource_group.savista_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  availability_zone   = var.enable_zones ? "Zone-Redundant" : "No-Zone"
}

# The Inbound Load Balancer for handling the traffic from the Internet.
module "inbound_lb" {
  source = "../../modules/loadbalancer"

  name                              = var.inbound_lb_name
  location                          = data.azurerm_resource_group.savista_rg.location
  resource_group_name               = data.azurerm_resource_group.savista_rg.name
  frontend_ips                      = var.frontend_ips
  enable_zones                      = var.enable_zones
  network_security_group_name       = "nsg-sec-public"
  network_security_allow_source_ips = coalescelist(var.allow_inbound_data_ips, var.allow_inbound_mgmt_ips)
}

# The Inbound Global Protect Load Balancer for handling the traffic from the Internet.
module "inbound_gp_lb" {
  source = "../../modules/loadbalancer"

  name                              = var.inbound_gp_lb_name
  location                          = data.azurerm_resource_group.savista_rg.location
  resource_group_name               = data.azurerm_resource_group.savista_rg.name
  frontend_ips                      = var.frontend_gp_ips
  enable_zones                      = var.enable_zones
  network_security_group_name       = "nsg-gp-public"
  network_security_allow_source_ips = coalescelist(var.allow_inbound_gp_data_ips, var.allow_inbound_mgmt_ips)
}

module "inbound_ipsec_lb" {
  source = "../../modules/loadbalancer"

  name                              = var.inbound_ipsec_lb_name
  location                          = data.azurerm_resource_group.savista_rg.location
  resource_group_name               = data.azurerm_resource_group.savista_rg.name
  frontend_ips                      = var.frontend_ipsec_ips
  enable_zones                      = var.enable_zones
  network_security_group_name       = "nsg-ipsec-public"
  network_security_allow_source_ips = coalescelist(var.allow_inbound_ipsec_data_ips, var.allow_inbound_mgmt_ips)
}

# The Outbound Load Balancer for handling the traffic from the private networks.
module "outbound_lb" {
  source = "../../modules/loadbalancer"

  name                = var.outbound_lb_name
  location            = data.azurerm_resource_group.savista_rg.location
  resource_group_name = data.azurerm_resource_group.savista_rg.name
  enable_zones        = var.enable_zones
  frontend_ips = {
    outbound = {
      subnet_id                     = lookup(module.vnet.subnet_ids, "subnet-private", null)
      private_ip_address_allocation = "Static"
      private_ip_address            = var.olb_private_ip
      availability_zone             = var.enable_zones ? null : "No-Zone" # For the regions without AZ support.
      rules = {
        HA_PORTS = {
          port     = 0
          protocol = "All"
        }
      }
    }
  }
}

# The Outbound Load Balancer for handling the traffic from the private networks.
module "outbound_gp_lb" {
  source = "../../modules/loadbalancer"

  name                = var.outbound_gp_lb_name
  location            = data.azurerm_resource_group.savista_rg.location
  resource_group_name = data.azurerm_resource_group.savista_rg.name
  enable_zones        = var.enable_zones
  frontend_ips = {
    outbound = {
      subnet_id                     = lookup(module.vnet.subnet_ids, "subnet-gp-private", null)
      private_ip_address_allocation = "Static"
      private_ip_address            = var.olb_gp_private_ip
      availability_zone             = var.enable_zones ? null : "No-Zone" # For the regions without AZ support.
      rules = {
        HA_PORTS = {
          port     = 0
          protocol = "All"
        }
      }
    }
  }
}

# The Outbound Load Balancer for handling the traffic from the private networks.
module "outbound_ipsec_lb" {
  source = "../../modules/loadbalancer"

  name                = var.outbound_ipsec_lb_name
  location            = data.azurerm_resource_group.savista_rg.location
  resource_group_name = data.azurerm_resource_group.savista_rg.name
  enable_zones        = var.enable_zones
  frontend_ips = {
    outbound = {
      subnet_id                     = lookup(module.vnet.subnet_ids, "subnet-ipsec-private", null)
      private_ip_address_allocation = "Static"
      private_ip_address            = var.olb_ipsec_private_ip
      availability_zone             = var.enable_zones ? null : "No-Zone" # For the regions without AZ support.
      rules = {
        HA_PORTS = {
          port     = 0
          protocol = "All"
        }
      }
    }
  }
}

# The common storage account for VM-Series initialization and the file share for Inbound VM-Series.
module "bootstrap" {
  source = "../../modules/bootstrap"

  location             = data.azurerm_resource_group.savista_rg.location
  resource_group_name  = data.azurerm_resource_group.savista_rg.name
  storage_account_name = var.storage_account_name
  storage_share_name   = var.outbound_storage_share_name
  files                = var.outbound_files
}

module "outbound_vmseries" {
  source = "../../modules/vmseries"

  for_each = var.outbound_vmseries

  location                  = data.azurerm_resource_group.savista_rg.location
  resource_group_name       = data.azurerm_resource_group.savista_rg.name
  name                      = "${var.name_prefix}${each.key}"
  avzone                    = try(each.value.avzone, 1)
  username                  = var.username
  password                  = coalesce(var.password, random_password.this.result)
  img_sku                   = var.outbound_vmseries_sku
  img_version               = var.outbound_vmseries_version
  vm_size                   = var.outbound_vmseries_vm_size
  tags                      = var.outbound_vmseries_tags
  enable_zones              = var.enable_zones
  bootstrap_storage_account = module.bootstrap.storage_account
  bootstrap_share_name      = module.bootstrap.storage_share.name
  interfaces = [
    {
      name                = "${each.key}-mgmt"
      subnet_id           = lookup(module.vnet.subnet_ids, "subnet-mgmt", null)
      create_public_ip    = true
      enable_backend_pool = false
    },
    {
      name                 = "${each.key}-public"
      subnet_id            = lookup(module.vnet.subnet_ids, "subnet-public", null)
      public_ip_address_id = azurerm_public_ip.public[each.key].id
      enable_backend_pool  = false
    },
    {
      name                = "${each.key}-private"
      subnet_id           = lookup(module.vnet.subnet_ids, "subnet-private", null)
      lb_backend_pool_id  = module.outbound_lb.backend_pool_id
      enable_backend_pool = true

      # Optional static private IP
      private_ip_address = try(each.value.trust_private_ip, null)
    },
  ]

  depends_on = [module.bootstrap]
}

module "gp_vmseries" {
  source = "../../modules/vmseries"

  for_each = var.gp_vmseries

  location                  = data.azurerm_resource_group.savista_rg.location
  resource_group_name       = data.azurerm_resource_group.savista_rg.name
  name                      = "${var.name_prefix}${each.key}"
  avzone                    = try(each.value.avzone, 1)
  username                  = var.username
  password                  = coalesce(var.password, random_password.this.result)
  img_sku                   = var.outbound_vmseries_sku
  img_version               = var.outbound_vmseries_version
  vm_size                   = var.outbound_vmseries_vm_size
  tags                      = var.outbound_vmseries_tags
  enable_zones              = var.enable_zones
  bootstrap_storage_account = module.bootstrap.storage_account
  bootstrap_share_name      = module.bootstrap.storage_share.name
  interfaces = [
    {
      name                = "${each.key}-mgmt"
      subnet_id           = lookup(module.vnet.subnet_ids, "subnet-mgmt", null)
      create_public_ip    = true
      enable_backend_pool = false
    },
    {
      name                 = "${each.key}-public"
      subnet_id            = lookup(module.vnet.subnet_ids, "subnet-gp-public", null)
      public_ip_address_id = azurerm_public_ip.public_gp[each.key].id
      enable_backend_pool  = false
    },
    {
      name                = "${each.key}-private"
      subnet_id           = lookup(module.vnet.subnet_ids, "subnet-gp-private", null)
      lb_backend_pool_id  = module.outbound_gp_lb.backend_pool_id
      enable_backend_pool = true

      # Optional static private IP
      private_ip_address = try(each.value.trust_private_ip, null)
    },
  ]

  depends_on = [module.bootstrap]
}

module "ipsec_vmseries" {
  source = "../../modules/vmseries"

  for_each = var.ipsec_vmseries

  location                  = data.azurerm_resource_group.savista_rg.location
  resource_group_name       = data.azurerm_resource_group.savista_rg.name
  name                      = "${var.name_prefix}${each.key}"
  avzone                    = try(each.value.avzone, 1)
  username                  = var.username
  password                  = coalesce(var.password, random_password.this.result)
  img_sku                   = var.outbound_vmseries_sku
  img_version               = var.outbound_vmseries_version
  vm_size                   = var.outbound_vmseries_vm_size
  tags                      = var.outbound_vmseries_tags
  enable_zones              = var.enable_zones
  bootstrap_storage_account = module.bootstrap.storage_account
  bootstrap_share_name      = module.bootstrap.storage_share.name
  interfaces = [
    {
      name                = "${each.key}-mgmt"
      subnet_id           = lookup(module.vnet.subnet_ids, "subnet-mgmt", null)
      create_public_ip    = true
      enable_backend_pool = false
    },
    {
      name                 = "${each.key}-public"
      subnet_id            = lookup(module.vnet.subnet_ids, "subnet-ipsec-public", null)
      public_ip_address_id = azurerm_public_ip.public_ipsec[each.key].id
      enable_backend_pool  = false
    },
    {
      name                = "${each.key}-private"
      subnet_id           = lookup(module.vnet.subnet_ids, "subnet-ipsec-private", null)
      lb_backend_pool_id  = module.outbound_ipsec_lb.backend_pool_id
      enable_backend_pool = true

      # Optional static private IP
      private_ip_address = try(each.value.trust_private_ip, null)
    },
  ]

  depends_on = [module.bootstrap]
}

resource "azurerm_virtual_network_peering" "security-to-mgmt" {
  name                      = "peersecurity2mgmt"
  resource_group_name       = data.azurerm_resource_group.savista_rg.name
  virtual_network_name      = var.virtual_network_name
  remote_virtual_network_id = data.azurerm_virtual_network.mgmt_vnet.id
}

resource "azurerm_virtual_network_peering" "mgmt-to-security" {
  name                      = "peermgmt2security"
  resource_group_name       = data.azurerm_resource_group.savista_rg.name
  virtual_network_name      = data.azurerm_virtual_network.mgmt_vnet.name
  remote_virtual_network_id = module.vnet.virtual_network_id

  depends_on = [azurerm_virtual_network_peering.security-to-mgmt]
}

resource "azurerm_virtual_network_peering" "security-to-hub" {
  name                      = "peersecurity2hub"
  resource_group_name       = data.azurerm_resource_group.savista_rg.name
  virtual_network_name      = var.virtual_network_name
  remote_virtual_network_id = data.azurerm_virtual_network.hub_vnet.id
}

resource "azurerm_virtual_network_peering" "hub-to-security" {
  name                      = "peerhub2security"
  resource_group_name       = "rg-networkinfra-southcentralus"
  virtual_network_name      = data.azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id = module.vnet.virtual_network_id

  depends_on = [azurerm_virtual_network_peering.security-to-hub]
}
