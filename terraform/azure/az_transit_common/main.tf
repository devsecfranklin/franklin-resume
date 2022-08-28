# Create the Resource Group.
resource "azurerm_resource_group" "this" {
  name     = coalesce(var.resource_group_name, "${var.name_prefix}")
  location = var.location
  tags     = var.tags
}

# Generate a random password.
resource "random_password" "this" {
  length           = 16
  min_lower        = 16 - 4
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  special          = true
  override_special = "_%@"
}

# Create the network required for the topology.
module "vnet" {
  source = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules//modules/vnet?ref=v0.4.0"

  virtual_network_name    = var.virtual_network_name
  location                = var.location
  resource_group_name     = azurerm_resource_group.this.name
  address_space           = var.address_space
  network_security_groups = var.network_security_groups
  route_tables            = var.route_tables
  subnets                 = var.subnets
  tags                    = var.tags
}

# Allow inbound access to Management subnet.
resource "azurerm_network_security_rule" "mgmt" {
  name                        = "vmseries-mgmt-allow-inbound"
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.this["nsg-mgmt"].name
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
  for_each = var.vmseries

  name                = "${var.name_prefix}${each.key}-public"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
  availability_zone   = var.enable_zones ? "Zone-Redundant" : "No-Zone"
}

# The Inbound Load Balancer for handling the traffic from the Internet.
module "inbound_lb" {
  source = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules//modules/loadbalancer?ref=v0.4.0"

  name                              = var.inbound_lb_name
  location                          = var.location
  resource_group_name               = azurerm_resource_group.this.name
  frontend_ips                      = var.frontend_ips
  enable_zones                      = var.enable_zones
  network_security_group_name       = "nsg-untrust"
  network_security_allow_source_ips = coalescelist(var.allow_inbound_data_ips, var.allow_inbound_mgmt_ips)
}

# The Outbound Load Balancer for handling the traffic from the private networks.
module "outbound_lb" {
  source = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules//modules/loadbalancer?ref=v0.4.0"

  name                = var.outbound_lb_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  enable_zones        = var.enable_zones
  frontend_ips = {
    outbound = {
      subnet_id                     = lookup(module.vnet.subnet_ids, "trust", null)
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

# The storage account for VM-Series initialization.
module "bootstrap" {
  source = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules//modules/bootstrap?ref=v0.4.0"

  location             = var.location
  resource_group_name  = azurerm_resource_group.this.name
  storage_account_name = var.storage_account_name
  storage_share_name   = var.storage_share_name
  files                = var.files
}

resource "azurerm_availability_set" "this" {
  name                = "${var.name_prefix}-fw-as"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  tags = var.tags
}

module "common_vmseries" {
  source = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules//modules/vmseries?ref=v0.4.0"

  for_each = var.vmseries

  location                  = var.location
  resource_group_name       = azurerm_resource_group.this.name
  name                      = each.key
  avzone                    = try(each.value.avzone, 1)
  username                  = var.username
  password                  = coalesce(var.password, random_password.this.result)
  img_version               = var.common_vmseries_version
  img_sku                   = var.common_vmseries_sku
  vm_size                   = var.common_vmseries_vm_size
  tags                      = var.tags
  enable_zones              = var.enable_zones
  avset_id                  = azurerm_availability_set.this.id
  bootstrap_storage_account = module.bootstrap.storage_account
  bootstrap_share_name      = module.bootstrap.storage_share.name
  # bootstrap_options = join(",",
  #   [
  #     "storage-account=${module.bootstrap.storage_account.name}",
  #     "access-key=${module.bootstrap.storage_account.primary_access_key}",
  #     "file-share=${module.bootstrap.storage_share.name}",
  #     "share-directory=None"
  # ])
  interfaces = [
    {
      name = "${each.key}-mgmt"
      #subnet_id = azurerm_subnet.this["mgmt"].id
      subnet_id           = lookup(module.vnet.subnet_ids, "mgmt", null)
      create_public_ip    = true
      enable_backend_pool = false
      private_ip_address  = try(each.value.mgmt_private_ip, null)
    },
    {
      name = "${each.key}-untrust"
      #subnet_id = azurerm_subnet.this["untrust"].id
      subnet_id            = lookup(module.vnet.subnet_ids, "untrust", null)
      public_ip_address_id = azurerm_public_ip.public[each.key].id
      lb_backend_pool_id   = module.inbound_lb.backend_pool_id
      enable_backend_pool  = true
      private_ip_address   = try(each.value.untrust_private_ip, null)
    },
    {
      name      = "${each.key}-trust"
      subnet_id = lookup(module.vnet.subnet_ids, "trust", null)
      #subnet_id           = azurerm_subnet.this["trust"].id
      lb_backend_pool_id  = module.outbound_lb.backend_pool_id
      enable_backend_pool = true

      # Optional static private IP
      private_ip_address = try(each.value.trust_private_ip, null)
    },
  ]

  # diagnostics_storage_uri = module.bootstrap.storage_account.primary_blob_endpoint

  depends_on = [module.bootstrap]
}

resource "azurerm_network_security_group" "this" {
  for_each = var.network_security_groups

  name                = each.key
  location            = try(each.value.location, var.location)
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}

locals {
  nsg_rules = flatten([
    for nsg_name, nsg in var.network_security_groups : [
      for rule_name, rule in lookup(nsg, "rules", {}) : {
        nsg_name = nsg_name
        name     = rule_name
        rule     = rule
      }
    ]
  ])
}

resource "azurerm_network_security_rule" "this" {
  for_each = {
    for nsg in local.nsg_rules : "${nsg.nsg_name}-${nsg.name}" => nsg
  }

  name                         = each.value.name
  resource_group_name          = azurerm_resource_group.this.name
  network_security_group_name  = azurerm_network_security_group.this[each.value.nsg_name].name
  priority                     = each.value.rule.priority
  direction                    = each.value.rule.direction
  access                       = each.value.rule.access
  protocol                     = each.value.rule.protocol
  source_port_range            = each.value.rule.source_port_range
  destination_port_range       = each.value.rule.destination_port_range
  source_address_prefix        = lookup(each.value.rule, "source_address_prefix", null)
  source_address_prefixes      = lookup(each.value.rule, "source_address_prefixes", null)
  destination_address_prefix   = lookup(each.value.rule, "destination_address_prefix", null)
  destination_address_prefixes = lookup(each.value.rule, "destination_address_prefixes", null)
}

resource "azurerm_route_table" "this" {
  for_each = var.route_tables

  name                = each.key
  location            = try(each.value.location, var.location)
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}

locals {
  route = flatten([
    for route_table_name, route_table in var.route_tables : [
      for route_name, route in route_table.routes : {
        route_table_name = route_table_name
        name             = route_name
        route            = route
      }
    ]
  ])
}

/*
resource "azurerm_route" "this" {
  for_each = {
    for route in local.route : "${route.route_table_name}-${route.name}" => route
  }

  name                   = each.value.name
  resource_group_name    = azurerm_resource_group.this.name
  route_table_name       = azurerm_route_table.this[each.value.route_table_name].name
  address_prefix         = each.value.route.address_prefix
  next_hop_type          = each.value.route.next_hop_type
  next_hop_in_ip_address = try(each.value.route.next_hop_in_ip_address, null)
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = { for k, v in var.subnets : k => v if lookup(v, "network_security_group", "") != "" }

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.value.network_security_group].id
}

resource "azurerm_subnet_route_table_association" "this" {
  for_each = { for k, v in var.subnets : k => v if lookup(v, "route_table", "") != "" }

  subnet_id      = azurerm_subnet.this[each.key].id
  route_table_id = azurerm_route_table.this[each.value.route_table].id
}
*/
