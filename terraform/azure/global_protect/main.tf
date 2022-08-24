data "azurerm_resource_group" "savista_rg" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "mgmt_vnet" {
  name                = "ssg-vnet-mgmt-southcentralus"
  resource_group_name = data.azurerm_resource_group.savista_rg.name
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

module "vnet" {
  source = "../../modules/vnet"

  virtual_network_name    = var.vnet_name
  location                = var.location
  resource_group_name     = data.azurerm_resource_group.savista_rg.name
  address_space           = var.address_space
  network_security_groups = var.network_security_groups
  route_tables            = var.route_tables
  subnets                 = var.subnets
  tags                    = var.tags
}

# Allow inbound access to Management subnet.
resource "azurerm_network_security_rule" "mgmt" {
  name                        = "vmseries-mgmt-allow-inbound"
  resource_group_name         = data.azurerm_resource_group.savista_rg.name
  network_security_group_name = "nsg-gp-mgmt"
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
  for_each = var.gp_vmseries

  name                = "${var.name_prefix}${each.key}-public"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.savista_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  availability_zone   = var.enable_zones ? "Zone-Redundant" : "No-Zone"
}

module "bootstrap" {
  source = "../../modules/bootstrap"

  location             = var.location
  resource_group_name  = data.azurerm_resource_group.savista_rg.name
  storage_account_name = var.storage_account_name
  storage_share_name   = var.storage_share_name
  files                = var.files
}

module "gp_vmseries" {
  source = "../../modules/vmseries"

  for_each = var.gp_vmseries

  location                  = var.location
  resource_group_name       = data.azurerm_resource_group.savista_rg.name
  name                      = "${var.name_prefix}${each.key}"
  avzone                    = try(each.value.avzone, 1)
  username                  = var.username
  password                  = coalesce(var.password, random_password.this.result)
  img_version               = var.common_vmseries_version
  img_sku                   = var.common_vmseries_sku
  vm_size                   = var.common_vmseries_vm_size
  tags                      = var.tags
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
      //lb_backend_pool_id   = module.inbound_lb.backend_pool_id
      enable_backend_pool = false
    },
    {
      name      = "${each.key}-private"
      subnet_id = lookup(module.vnet.subnet_ids, "subnet-private", null)
      //lb_backend_pool_id  = module.outbound_lb.backend_pool_id
      enable_backend_pool = false

      # Optional static private IP
      private_ip_address = try(each.value.trust_private_ip, null)
    },
  ]

  depends_on = [module.bootstrap]
}

resource "azurerm_lb" "global-protect-lb" {
  name                = "gp-gateway"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.savista_rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "gp-gw-pub-ip"
    public_ip_address_id = "/subscriptions/5b2ef0fb-a2bf-48e8-aafa-cf78b7b5092f/resourceGroups/rg-ssg-palo-scus/providers/Microsoft.Network/publicIPAddresses/gateway"
  }
}

resource "azurerm_lb_rule" "gp-client-inbound" {
  resource_group_name            = data.azurerm_resource_group.savista_rg.name
  loadbalancer_id                = azurerm_lb.global-protect-lb.id
  name                           = "https-from-clients"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "gp-gw-pub-ip"
}

resource "azurerm_lb_backend_address_pool" "gp_backend_pool" {
  loadbalancer_id = azurerm_lb.global-protect-lb.id
  name            = "gp-backend"
}

resource "azurerm_virtual_network_peering" "gp-to-mgmt" {
  name                      = "peergp2mgmt"
  resource_group_name       = data.azurerm_resource_group.savista_rg.name
  virtual_network_name      = var.vnet_name
  remote_virtual_network_id = data.azurerm_virtual_network.mgmt_vnet.id
}

resource "azurerm_virtual_network_peering" "mgmt-to-gp" {
  name                      = "peermgmt2gp"
  resource_group_name       = data.azurerm_resource_group.savista_rg.name
  virtual_network_name      = data.azurerm_virtual_network.mgmt_vnet.name
  remote_virtual_network_id = module.vnet.virtual_network_id

  depends_on = [azurerm_virtual_network_peering.gp-to-mgmt]
}
