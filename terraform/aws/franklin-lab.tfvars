ssh_key_name = "franklin-key" # create it manually 

region          = "us-east-1"
prefix_name_tag = "ps-franklin-"

global_tags = {
  application = "Palo Alto Networks VM-Series GWLB"
  ps          = "franklin"
}

security_vpc_name = "Franklin-Security-VPC"
security_vpc_cidr = "10.243.146.0/23"

## Subnets 

security_vpc_subnets = {
  # Do not modify value of `set=`, it is an internal identifier referenced by main.tf.
  "10.243.146.0/28"   = { az = "us-east-1a", set = "franklin-mgmt" }
  "10.243.147.0/28"   = { az = "us-east-1b", set = "franklin-mgmt" }
  "10.243.146.32/28"  = { az = "us-east-1a", set = "franklin-data" }
  "10.243.147.32/28"  = { az = "us-east-1b", set = "franklin-data" }
  "10.243.146.64/28"  = { az = "us-east-1a", set = "franklin-tgw-attach" }
  "10.243.147.64/28"  = { az = "us-east-1b", set = "franklin-tgw-attach" }
  "10.243.146.96/28"  = { az = "us-east-1a", set = "franklin-gwlbe-outbound" }
  "10.243.147.96/28"  = { az = "us-east-1b", set = "franklin-gwlbe-outbound" }
  "10.243.146.128/28" = { az = "us-east-1a", set = "franklin-gwlbe-eastwest" }
  "10.243.147.128/28" = { az = "us-east-1b", set = "franklin-gwlbe-eastwest" }
  "10.243.146.160/28" = { az = "us-east-1a", set = "franklin-nj-courts-natgw" }
  "10.243.147.160/28" = { az = "us-east-1b", set = "franklin-nj-courts-natgw" }
}

## Security Groups 

security_vpc_security_groups = {
  franklin-fw-data = {
    name = "franklin-fw-data"
    rules = {
      all-outbound = {
        description = "Permit All traffic outbound"
        type        = "egress", from_port = "0", to_port = "0", protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
      geneve = {
        description = "Permit GENEVE"
        type        = "ingress", from_port = "6081", to_port = "6081", protocol = "udp"
        cidr_blocks = ["10.243.146.32/28", "10.243.147.32/28"]
      }
      health_probe = {
        description = "Permit Port 80 GWLB Health Probe"
        type        = "ingress", from_port = "80", to_port = "80", protocol = "tcp"
        cidr_blocks = ["10.243.146.32/28", "10.243.147.32/28"]
      }

    }
  }
  gwlbe = {
    name = "gwlbe"
    rules = {
      all-outbound = {
        description = "Permit All traffic outbound"
        type        = "egress", from_port = "0", to_port = "0", protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
      ssh2 = {
        description = "Permit traffic from any vpc"
        type        = "ingress", from_port = "0", to_port = "0", protocol = "-1"
        cidr_blocks = ["10.0.0.0/8"]
      }
    }
  }
  franklin-fw-mgmt = {
    name = "franklin-fw-mgmt"
    rules = {
      all-outbound = {
        description = "Permit All traffic outbound"
        type        = "egress", from_port = "0", to_port = "0", protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
      ssh-from-inet = {
        description = "Permit SSH"
        type        = "ingress", from_port = "22", to_port = "22", protocol = "tcp"
        cidr_blocks = ["199.167.52.5/32"] # TODO: update here
      }
      https-from-inet = {
        description = "Permit HTTPS"
        type        = "ingress", from_port = "443", to_port = "443", protocol = "tcp"
        cidr_blocks = ["199.167.52.5/32"] # TODO: update here
      }
      panorama-mgmt = {
        description = "Permit Panorama Management"
        #type        = "ingress", from_port = "3978", to_port = "3978", protocol = "tcp"
        type        = "ingress", from_port = "0", to_port = "0", protocol = "-1"
        cidr_blocks = ["192.168.0.0/24", "34.136.90.64/32", "34.134.31.136/32"] // IP of lab panoramas
      }
      panorama = {
        description = "Permit Panorama Logging"
        type        = "ingress", from_port = "28443", to_port = "28443", protocol = "tcp"
        cidr_blocks = ["192.168.0.0/24", "34.136.90.64/32", "34.134.31.136/32"]
      }
    }
  }
}

### VMSERIES ###

firewalls = [
  {
    name = "franklin-fw-01"
    fw_tags = {
      ps = "fdiaz"
    }
    bootstrap_options = {
      mgmt-interface-swap = "enable"
      plugin-op-commands  = "aws-gwlb-inspect:enable"
      type                = "dhcp-client"
      hostname            = "franklin-fw-01"
      tplname             = "STK-GWLB"
      dgname              = "DG-GWLB"
      panorama-server     = "192.168.0.4"
      panorama-server-2   = ""
      vm-auth-key         = "856438785494506"
      authcodes           = ""
      op-command-modes    = ""
    }
    interfaces = [
      { name = "franklin-vmseries01-data", index = "0" },
      { name = "franklin-vmseries01-mgmt", index = "1" },
    ]
  },
  {
    name = "franklin-fw-02"
    fw_tags = {
      ps = "fdiaz"
    }
    bootstrap_options = {
      mgmt-interface-swap = "enable"
      plugin-op-commands  = "aws-gwlb-inspect:enable"
      type                = "dhcp-client"
      hostname            = "franklin-fw-02"
      tplname             = "STK-GWLB"
      dgname              = "DG-GWLB"
      panorama-server     = "192.168.0.4"
      panorama-server-2   = ""
      vm-auth-key         = "856438785494506"
      authcodes           = ""
      op-command-modes    = ""
    }
    interfaces = [
      { name = "franklin-vmseries02-data", index = "0" },
      { name = "franklin-vmseries02-mgmt", index = "1" },
    ]
  }
]

interfaces = [
  # vmseries01
  {
    name                          = "franklin-vmseries01-data"
    source_dest_check             = false
    subnet_name                   = "franklin-dataa"
    security_group                = "franklin-fw-data"
    private_ip_address_allocation = "dynamic"
  },
  {
    name                          = "franklin-vmseries01-mgmt"
    source_dest_check             = true
    subnet_name                   = "franklin-mgmta"
    security_group                = "franklin-fw-mgmt"
    private_ip_address_allocation = "dynamic"
    eip                           = "franklin-vmseries01-mgmt"
  },
  # vmseries02
  {
    name                          = "franklin-vmseries02-data"
    source_dest_check             = false
    subnet_name                   = "franklin-datab"
    security_group                = "franklin-fw-data"
    private_ip_address_allocation = "dynamic"
  },
  {
    name                          = "franklin-vmseries02-mgmt"
    source_dest_check             = true
    subnet_name                   = "franklin-mgmtb"
    security_group                = "franklin-fw-mgmt"
    private_ip_address_allocation = "dynamic"
    eip                           = "franklin-vmseries02-mgmt"
  },
]

### Security VPC ROUTES ###

summary_cidr_behind_tgw            = "10.0.0.0/8"
summary_cidr_behind_gwlbe_outbound = "0.0.0.0/0"
### Security VPC routes ###

//security_vpc_routes_outbound_source_cidrs = [ # outbound traffic return after inspection
//  "10.0.0.0/8",
//]

//security_vpc_routes_outbound_destin_cidrs = [ # outbound traffic incoming for inspection from TGW
//  "0.0.0.0/0",
//]

//security_vpc_routes_eastwest_cidrs = [ # eastwest traffic incoming for inspection from TGW
//  "10.0.0.0/8",
//]

//security_vpc_mgmt_routes_to_tgw = [
//  "10.255.0.0/16", # Panorama via TGW (must not repeat any security_vpc_routes_eastwest_cidrs)
//]

### NATGW ###

nat_gateway_name = "franklin-natgw"

### GWLB ###

gwlb_name                       = "franklin-security-gwlb"
gwlb_endpoint_set_eastwest_name = "franklin-fw1-gwlb-endpoint"
gwlb_endpoint_set_outbound_name = "franklin-fw2-gwlb-endpoint"

### TGW ###

transit_gateway_name                = "franklin-tgw"
transit_gateway_asn                 = "65200"
security_transit_gateway_attachment = "franklin-security-vpc"
create_tgw                          = true

transit_gateway_route_tables = {
  "franklin-from_security_vpc" = {
    create = true
    name   = "from_security"
  }
  "franklin-from_spoke_vpc" = {
    create = true
    name   = "from_spokes"
  }
}

## Example Application VPC ##

app1_vpc_subnets = {
  "10.243.148.0/28"  = { az = "us-east-1a", set = "app1_alb" }
  "10.243.149.0/28"  = { az = "us-east-1b", set = "app1_alb" }
  "10.243.148.32/28" = { az = "us-east-1a", set = "app1_gwlbe" }
  "10.243.149.32/28" = { az = "us-east-1b", set = "app1_gwlbe" }
  "10.243.148.64/28" = { az = "us-east-1a", set = "app1_web" }
  "10.243.149.64/28" = { az = "us-east-1b", set = "app1_web" }
}
app1_vpc_security_groups = {
  app1_web = {
    name = "app1_web"
    rules = {
      all-outbound = {
        description = "Permit All traffic outbound"
        type        = "egress", from_port = "0", to_port = "0", protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
      ssh-from-inet = {
        description = "Permit SSH"
        type        = "ingress", from_port = "22", to_port = "22", protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] # TODO: update here
      }
      https-from-inet = {
        description = "Permit HTTPS"
        type        = "ingress", from_port = "443", to_port = "443", protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] # TODO: update here
      }
    }
  }
}
