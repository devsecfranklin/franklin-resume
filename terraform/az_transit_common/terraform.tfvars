name_prefix = "franklin"

resource_group_name = "franklin-rg01"
location            = "West US2"
enable_zones        = false

virtual_network_name = "franklin-vnet01"
address_space        = ["10.199.0.0/21"]

network_security_groups = {
  "nsg-mgmt"    = {}
  "nsg-trust"   = {}
  "nsg-untrust" = {}
}

allow_inbound_mgmt_ips = [
  "34.134.31.136", # Put your own public IP address here FOR MGMT ACCESS
  "34.136.90.64",
  "68.38.137.81"
]

olb_private_ip = "10.199.2.100"

route_tables = {
  "nsg-trust" = {
    routes = {
      "fw_int_lb" = {
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.199.2.100"
      }
      "untrust_blackhole" = {
        address_prefix = "10.199.1.0/24"
        next_hop_type  = "None"
      }
      "mgmt_blackhole" = {
        address_prefix = "10.199.0.0/24"
        next_hop_type  = "None"
      }
    }
  }
  "untrust_rt" = {
    routes = {
      "trust_blackhole" = {
        address_prefix = "10.199.2.0/24"
        next_hop_type  = "None"
      }
      "mgmt_blackhole" = {
        address_prefix = "10.199.0.0/24"
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
    }
  }
}

subnets = {
  "mgmt" = {
    address_prefixes       = ["10.199.0.0/24"]
    network_security_group = "nsg-mgmt"
  }
  "trust" = {
    address_prefixes       = ["10.199.2.0/24"]
    network_security_group = "nsg-trust"
    route_table            = "nsg-trust"
  }
  "untrust" = {
    address_prefixes       = ["10.199.1.0/24"]
    network_security_group = "nsg-untrust"
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
    trust_private_ip   = "10.199.2.4"
    untrust_private_ip = "10.199.1.4"
    mgmt_private_ip    = "10.199.0.4"
  }
  "paloaltovm-002" = {
    trust_private_ip   = "10.199.2.5"
    untrust_private_ip = "10.199.1.5"
    mgmt_private_ip    = "10.199.0.5"
  }
}

common_vmseries_version = "10.1.4"
common_vmseries_vm_size = "Standard_DS4_v2"
//common_vmseries_sku     = "byol"
//storage_account_name = "franklintfstate" # this is unique in all of Azure
storage_share_name = "bootstrapshare"

files = {
  "files/authcodes"    = "license/authcodes" # authcode is required only with common_vmseries_sku = "byol"
  "files/init-cfg.txt" = "config/init-cfg.txt"
}

tags = {
  application = "Palo Alto Networks VM-Series"
  managed_by  = "terraform 1.x"
  owner       = "franklin"
}
