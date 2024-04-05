data "azurerm_resource_group" "lab_franklin" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "hub" {
  name                = "${var.name_prefix}${var.virtual_network_name}"
  resource_group_name = var.resource_group_name
  address_space       = var.address_space_fw
  location            = var.location
}

resource "azurerm_subnet" "inside" {
  name                 = "PaloTrustSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["172.21.5.64/26"]
}

resource "azurerm_subnet" "outside" {
  name                 = "PaloUntrustSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["172.21.5.128/26"]
}

resource "azurerm_network_security_group" "mgmt" {
  name                = "nsg-lab-fra-hub-mgmt"
  location            = data.azurerm_resource_group.lab_franklin.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "mgmt" {
  name                        = "AllowMgmt"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["22", "443"]
  source_address_prefixes     = ["130.41.158.168"]
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.mgmt.name
}
resource "azurerm_route_table" "mgmt" {
  name                = "rt-lab-fra-hub-mgmt"
  location            = data.azurerm_resource_group.lab_franklin.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_route" "mgmt" {
  name                = "route-lab-fra-hub-mgmt"
  resource_group_name = var.resource_group_name
  route_table_name    = azurerm_route_table.mgmt.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "Internet"
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

locals {
  fw_password = var.password == null ? random_password.this.result : var.password
}

resource "azurerm_subnet" "mgmt" {
  name                 = var.mgmt_subnet
  virtual_network_name = azurerm_virtual_network.hub.name
  resource_group_name  = var.resource_group_name
  address_prefixes     = ["172.21.5.192/28"]
}

resource "azurerm_network_security_group" "inside" {
  name                = "PaloTrustNSG"
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.lab_franklin.location
}

resource "azurerm_network_security_rule" "AllowSpokeOutbound" {
  name                        = "AllowSpokeOutbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefixes     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.inside.name
}

resource "azurerm_network_security_rule" "AllowHealthProbe" {
  name                         = "AllowHealthProbe"
  priority                     = 200
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "80"
  source_address_prefix        = "*"
  destination_address_prefixes = ["168.63.129.16/32"]
  resource_group_name          = var.resource_group_name
  network_security_group_name  = azurerm_network_security_group.inside.name
}

resource "azurerm_route_table" "inside" {
  name                          = "PaloTrustSubnet"
  location                      = data.azurerm_resource_group.lab_franklin.location
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = false

  route {
    name           = "defaultToOnPrem"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualNetworkGateway"
  }

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "inside" {
  subnet_id                 = azurerm_subnet.inside.id
  network_security_group_id = azurerm_network_security_group.inside.id
}

resource "azurerm_subnet_route_table_association" "inside" {
  subnet_id      = azurerm_subnet.inside.id
  route_table_id = azurerm_route_table.inside.id
}

# The Outbound Load Balancer for handling the traffic from the private networks.
module "inside_lb" {
  source  = "PaloAltoNetworks/vmseries-modules/azurerm//modules/loadbalancer"
  version = "1.2.4"

  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.lab_franklin.location
  name                = "${var.name_prefix}${var.inside_lb_name}"
  probe_name          = "${var.name_prefix}${var.inside_lb_name}-probe"
  backend_name        = "${var.name_prefix}${var.inside_lb_name}-backend"
  enable_zones        = var.enable_zones
  avzones             = var.avzones
  frontend_ips = {
    internal_fe = {
      subnet_id                     = azurerm_subnet.inside.id
      private_ip_address_allocation = "Static" // Dynamic or Static
      private_ip_address            = var.inside_lb_ip
      zones                         = var.enable_zones ? var.avzones : null # For the regions without AZ support.
      rules = {
        HA_PORTS = {
          port     = 0
          protocol = "All"
        }
      }
    }
  }
}

# The Inbound Load Balancer ( External ) for handling the traffic to the private networks.
module "external_lb" {
  source  = "PaloAltoNetworks/vmseries-modules/azurerm//modules/loadbalancer"
  version = "1.2.4"

  name                              = "${var.name_prefix}palo-elb"
  resource_group_name               = var.resource_group_name
  location                          = data.azurerm_resource_group.lab_franklin.location
  probe_name                        = "${var.name_prefix}palo-elb-probe"
  probe_port                        = 80
  enable_zones                      = var.enable_zones
  avzones                           = var.avzones
  network_security_allow_source_ips = ["0.0.0.0/0"]
  frontend_ips = {
    lab-franklin-lb-pip1 = {
      create_public_ip = true
      in_rules = {
        HTTPS = {
          port                = 443
          protocol            = "Tcp"
          session_persistence = "SourceIPProtocol"
        },
        MyApp = {
          port                = 4444
          protocol            = "Tcp"
          session_persistence = "SourceIPProtocol"
        }
      }
      out_rules = {
        "outbound_tcp" = {
          protocol                 = "Tcp"
          allocated_outbound_ports = 2048
          enable_tcp_reset         = true
          idle_timeout_in_minutes  = 10
        }
      }
    }

  }
  backend_name = "external-lb-backend"
}

module "vmseries" {
  source = "PaloAltoNetworks/vmseries-modules/azurerm//modules/vmseries"

  for_each            = var.vmseries
  location            = data.azurerm_resource_group.lab_franklin.location
  resource_group_name = var.resource_group_name
  name                = each.key
  avzone              = try(each.value.avzone, 1)
  username            = var.username
  password            = local.fw_password
  img_version         = var.vmseries_version
  img_sku             = var.vmseries_sku
  vm_size             = var.vmseries_vm_size
  tags                = var.tags
  enable_zones        = var.enable_zones
  bootstrap_options   = var.vmseries_bootstrap_options
  interfaces = [
    {
      name                = "${each.key}-mgmt"
      subnet_id           = azurerm_subnet.mgmt.id
      create_public_ip    = true
      enable_backend_pool = false
      private_ip_address  = try(each.value.mgmt_private_ip, null)
    },
    {
      name                = "${each.key}-outside"
      subnet_id           = azurerm_subnet.outside.id
      create_public_ip    = false
      enable_backend_pool = true
      lb_backend_pool_id  = module.external_lb.backend_pool_id
      private_ip_address  = try(each.value.outside_private_ip, null)
    },
    {
      name                = "${each.key}-inside"
      subnet_id           = azurerm_subnet.inside.id
      lb_backend_pool_id  = module.inside_lb.backend_pool_id
      create_public_ip    = false
      enable_backend_pool = true
      private_ip_address  = try(each.value.inside_private_ip, null)
    },
  ]
}
