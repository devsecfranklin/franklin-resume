location            = "South Central US"
resource_group_name = "rg-ssg-palo-scus"
vnet_name           = "ssg-vnet-gp-southcentralus"
enable_zones        = true
address_space = [
  "10.11.40.0/27",
  "10.11.40.32/27",
  "10.11.40.64/27",
  "10.11.41.0/27",
  "10.11.41.32/27",
"10.11.41.64/27"]

network_security_groups = {
  "nsg-gp-mgmt" = {
    location = "South Central US"
    rules = {
      "AllOutbound" = {
        priority                   = 100
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      "AllowHttps" = {
        priority                   = 200
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "10.0.0.0/8"
        destination_address_prefix = "*"
      },
    }
  }
  "nsg-gp-private" = {
    // this should point to citrix
    location = "South Central US"
    rules = {
      "AllPvtOutbound" = {
        priority                   = 100
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      "AllowPvtHttps" = {
        priority                   = 200
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
    }
  }
  "nsg-gp-public" = {
    location = "South Central US"
    rules = {
      "AllPubOutbound" = {
        priority                   = 100
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      "AllowPubHttps" = {
        priority                   = 200
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
    }
  }
}

allow_inbound_mgmt_ips = [
  "68.38.137.81/32", # Put your own public IP address here
  "10.11.43.224/27", # Panorama mgmt access
  "71.38.129.88/32", # jason L.
  "10.11.40.64/27",
]

route_tables = {
  private_route_table = {
    routes = {
      default = {
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.11.43.240"
      }
    }
  },
  mgmt_route_table = {
    routes = {
      default = {
        address_prefix = "0.0.0.0/0"
        next_hop_type  = "Internet"
      }
    }
  }
}

subnets = {
  "subnet-mgmt" = {
    address_prefixes       = ["10.11.40.64/27"]
    network_security_group = "nsg-gp-mgmt"
    route_table            = "mgmt_route_table"
  }
  "subnet-private" = {
    address_prefixes       = ["10.11.40.32/27"]
    network_security_group = "nsg-gp-private"
    route_table            = "private_route_table"
  }
  "subnet-public" = {
    address_prefixes       = ["10.11.40.0/27"]
    network_security_group = "nsg-gp-public"
  }
}

gp_vmseries = {
  "palo-fw-global-protect-01" = { avzone = 1 }
  "palo-fw-global-protect-02" = { avzone = 2 }
}

common_vmseries_version = "10.0.6"
common_vmseries_sku     = "bundle2"
//storage_account_name    = "pantfstorage"
storage_share_name = "ibbootstrapshare"

files = {
  "files/authcodes"    = "license/authcodes" # authcode is required only with common_vmseries_sku = "byol"
  "files/init-cfg.txt" = "config/init-cfg.txt"
}

tags = {
  Application_Name  = "palo_global_protect",
  Application_Owner = "Alan Schmid"
}

