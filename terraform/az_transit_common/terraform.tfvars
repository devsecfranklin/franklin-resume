name_prefix = "marvell"

resource_group_name = "RG01-GRID"
location            = "West US2"
enable_zones        = false

virtual_network_name = "c1us-fwvmseries-vnet01"

network_security_groups = {
  "nsg-mgmt"    = {}
  "nsg-trust"   = {}
  "nsg-untrust" = {}
  "nsg-gateway" = {}
}

allow_inbound_mgmt_ips = [
  "134.238.135.137", # Put your own public IP address here
  "134.238.135.14",
  "68.38.137.81"
  #"10.255.0.0/24",   # Example Panorama access
]

olb_private_ip = "10.199.1.100"

route_tables = {
  "trust_rt" = {
    routes = {
      "fw_int_lb" = {
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.199.1.100"
      }
      "untrust_blackhole" = {
        address_prefix = "10.199.2.0/24"
        next_hop_type  = "None"
      }
      "mgmt_blackhole" = {
        address_prefix = "10.199.0.0/24"
        next_hop_type  = "None"
      }
      "gateway_blackhole" = {
        address_prefix = "10.199.3.0/24"
        next_hop_type  = "None"
      }
    }
  }
  "untrust_rt" = {
    routes = {
      "trust_blackhole" = {
        address_prefix = "10.199.1.0/24"
        next_hop_type  = "None"
      }
      "mgmt_blackhole" = {
        address_prefix = "10.199.0.0/24"
        next_hop_type  = "None"
      }
      "gateway_blackhole" = {
        address_prefix = "10.199.3.0/24"
        next_hop_type  = "None"
      }
    }
  }
  "mgmt_rt" = {
    routes = {
      "trust_blackhole" = {
        address_prefix = "10.199.1.0/24"
        next_hop_type  = "None"
      }
      "untrust_blackhole" = {
        address_prefix = "10.199.2.0/24"
        next_hop_type  = "None"
      }
      "gateway_blackhole" = {
        address_prefix = "10.199.3.0/24"
        next_hop_type  = "None"
      }
    }
  }
  "gateway_rt" = {
    routes = {
      "fw_int_lb" = {
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.199.1.100"
      }
      "untrust_blackhole" = {
        address_prefix = "10.199.2.0/24"
        next_hop_type  = "None"
      }
      "mgmt_blackhole" = {
        address_prefix = "10.199.0.0/24"
        next_hop_type  = "None"
      }
    }
  }
}

subnets = {
  "mgmt" = {
    network_security_group = "nsg-mgmt"
    # route_table            = "mgmt_rt"
  }
  "trust" = {
    network_security_group = "nsg-trust"
    route_table            = "trust_rt"
  }
  "untrust" = {
    network_security_group = "nsg-untrust"
    # route_table            = "untrust_rt"
  }
  "gateway" = {
    network_security_group = "nsg-gateway"
    route_table            = "gateway_rt"
  }
}

frontend_ips = {
  "some_app_01" = {
    create_public_ip = true
    rules = {
      "balanceHttps" = {
        protocol = "Tcp"
        port     = 443
      }
    }
  }
  "some_app_02" = {
    create_public_ip = true
    rules = {
      "balanceHttps" = {
        protocol = "Tcp"
        port     = 443
      }
    }
  }
}

vmseries = {
  "paloaltovm-001" = {
    trust_private_ip   = "10.199.1.4"
    untrust_private_ip = "10.199.2.4"
    mgmt_private_ip    = "10.199.0.4"
  }
  "paloaltovm-002" = {
    trust_private_ip   = "10.199.1.5"
    untrust_private_ip = "10.199.2.5"
    mgmt_private_ip    = "10.199.0.5"
  }
}

common_vmseries_version = "10.1.4"
common_vmseries_vm_size = "Standard_DS4_v2"
common_vmseries_sku     = "byol"
storage_account_name    = "marvelltfstorage" # this is unique in all of Azure
storage_share_name      = "bootstrapshare"

files = {
  "files/authcodes"    = "license/authcodes" # authcode is required only with common_vmseries_sku = "byol"
  "files/init-cfg.txt" = "config/init-cfg.txt"
}

tags = {}
