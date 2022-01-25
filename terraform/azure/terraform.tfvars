location             = "South Central US"
resource_group_name  = "rg-franklin"
virtual_network_name = "vnet-franklin"
enable_zones         = true

network_security_groups = {
  "nsg-sec-mgmt" = {
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
  "nsg-sec-private" = {
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
  "nsg-sec-public" = {
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
  "nsg-gp-private" = {
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
  "nsg-ipsec-private" = {
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
  "nsg-ipsec-public" = {
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
  "10.11.43.244/32", # panorama 2
  "10.11.43.245/32"  # panorama 1
]

route_tables = {
  mgmt_route_table = {
    routes = {
      panorama = {
        address_prefix = "10.11.43.240/28"
        next_hop_type  = "VnetLocal"
      }
    }
  },
  nthrive = {
    routes = {
      nthrive_supernet_ldc_1 = {
        address_prefix = "10.110.0.0/16"
        next_hop_type  = "VnetLocal"
      },
      nthrive_supernet_ldc_2 = {
        address_prefix = "10.120.0.0/16"
        next_hop_type  = "VnetLocal"
      },
      nthrive_supernet_ldc_3 = {
        address_prefix = "10.40.0.0/13"
        next_hop_type  = "VnetLocal"
      },
      nthrive_supernet_adc = {
        address_prefix = "10.56.0.0/16"
        next_hop_type  = "VnetLocal"
      },
      nthrive_supernet_phx_1 = {
        address_prefix = "192.168.151.0/24"
        next_hop_type  = "VnetLocal"
      },
      nthrive_supernet_phx_2 = {
        address_prefix = "192.168.152.0/24"
        next_hop_type  = "VnetLocal"
      },
      nthrive_supernet_ldc_4 = {
        address_prefix = "192.168.212.0/22"
        next_hop_type  = "VnetLocal"
      },
      nthrive_supernet_phx_3 = {
        address_prefix = "192.168.213.0/24"
        next_hop_type  = "VnetLocal"
      },
      nthrive_supernet_1 = {
        address_prefix = "10.198.0.0/21"
        next_hop_type  = "VnetLocal"
      },
      nthrive_supernet_2 = {
        address_prefix = "10.198.9.0/24"
        next_hop_type  = "VnetLocal"
      },
      nthrive_supernet_2 = {
        address_prefix = "10.198.10.0/24"
        next_hop_type  = "VnetLocal"
      },
      savista_azure_supernet = {
        address_prefix = "10.11.0.0/16"
        next_hop_type  = "VnetLocal"
      },
    }
  },
}

/*
  private_route_table = {
    routes = {
      default = {
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.11.40.38" //olb_private_ip = "10.11.40.38"
      }
    }
  }
  private_gp_route_table = {
    routes = {
      default = {
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.11.40.136" //olb_gp_private_ip = "10.11.40.136"
      }
    }
  }
  private_ipsec_route_table = {
    routes = {
      default = {
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.11.40.197" //olb_ipsec_private_ip = "10.11.40.197"
      }
    }
  }
}
*/

subnets = {
  "subnet-mgmt" = {
    address_prefixes       = ["10.11.40.64/27"]
    network_security_group = "nsg-sec-mgmt"
    route_table            = "mgmt_route_table"
  }
  "subnet-private" = {
    address_prefixes       = ["10.11.40.32/27"]
    network_security_group = "nsg-sec-private"

  }
  "subnet-public" = {
    address_prefixes       = ["10.11.40.0/27"]
    network_security_group = "nsg-sec-public"
  }
  "subnet-gp-private" = {
    address_prefixes       = ["10.11.40.128/27"]
    network_security_group = "nsg-sec-private"

  }
  "subnet-gp-public" = {
    address_prefixes       = ["10.11.40.96/27"]
    network_security_group = "nsg-sec-public"
  }
  "subnet-ipsec-private" = {
    address_prefixes       = ["10.11.40.192/27"]
    network_security_group = "nsg-sec-private"

  }
  "subnet-ipsec-public" = {
    address_prefixes       = ["10.11.40.160/27"]
    network_security_group = "nsg-sec-public"
  }
}

frontend_ips = {
  "frontend01" = {
    create_public_ip = true
    rules = {
      "monitor" = {
        protocol = "Tcp"
        port     = 443
      }
    }
  }
}

frontend_gp_ips = {
  "gp-existing" = {
    create_public_ip         = false
    public_ip_name           = "gateway"
    public_ip_resource_group = "rg-franklin"
    rules = {
      "monitor" = {
        protocol = "Tcp"
        port     = 443
      }
    }
  }
}

frontend_ipsec_ips = {
  "frontend-ipsec" = {
    create_public_ip = true
    rules = {
      "monitor" = {
        protocol = "Tcp"
        port     = 443
      }
    }
  }
}

outbound_vmseries_sku     = "bundle2"
outbound_vmseries_version = "10.0.6"
#outbound_vmseries_vm_size   = "Standard_D4_v2" # uncomment for 500 series, defaulted to 300
outbound_storage_share_name = "bootstrapshare"
olb_private_ip              = "10.11.40.38"
outbound_vmseries = {
  "palo-fw-common-01" = { avzone = 1 }
  "palo-fw-common-02" = { avzone = 2 }
}

olb_gp_private_ip = "10.11.40.136"
gp_vmseries = {
  "palo-fw-gp-01" = { avzone = 1 }
  "palo-fw-gp-02" = { avzone = 2 }
}

olb_ipsec_private_ip = "10.11.40.197"
ipsec_vmseries = {
  "palo-fw-ipsec-01" = { avzone = 1 }
  "palo-fw-ipsec-02" = { avzone = 2 }
}
outbound_files = {
  "files/init-cfg.txt" = "config/init-cfg.txt"
}

tags = {
  Application_Name  = "palo_security",
}

//allow_inbound_data_ips
//allow_inbound_data_ips
//allow_inbound_ipsec_data_ips
