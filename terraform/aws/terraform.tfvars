ssh_key_name = "franklin-key"

prefix_name_tag  = "nj-courts-"
fw_instance_type = "m5.xlarge"
fw_license_type  = "byol"
fw_version       = "10.0.7" # Can be empty.

global_tags = {
  application = "Palo Alto Networks VM-Series GWLB"
}

security_vpc_name = "Network-Security-VPC"
security_vpc_cidr = "10.243.146.0/23"

## Subnets 

security_vpc_subnets = {
  # Do not modify value of `set=`, it is an internal identifier referenced by main.tf.
  "10.243.146.0/28"   = { az = "us-east-1a", set = "nj-courts-mgmt" }
  "10.243.147.0/28"   = { az = "us-east-1b", set = "nj-courts-mgmt" }
  "10.243.146.32/28"  = { az = "us-east-1a", set = "nj-courts-data" }
  "10.243.147.32/28"  = { az = "us-east-1b", set = "nj-courts-data" }
  "10.243.146.64/28"  = { az = "us-east-1a", set = "tgw_attach" }
  "10.243.147.64/28"  = { az = "us-east-1b", set = "tgw_attach" }
  "10.243.146.96/28"  = { az = "us-east-1a", set = "gwlbe_outbound" }
  "10.243.147.96/28"  = { az = "us-east-1b", set = "gwlbe_outbound" }
  "10.243.146.128/28" = { az = "us-east-1a", set = "gwlbe_eastwest" }
  "10.243.147.128/28" = { az = "us-east-1b", set = "gwlbe_eastwest" }
  "10.243.146.160/28" = { az = "us-east-1a", set = "nj-courts-natgw" }
  "10.243.147.160/28" = { az = "us-east-1b", set = "nj-courts-natgw" }
}

## Security Groups 

security_vpc_security_groups = {
  nj-courts-fw-data = {
    name = "nj-courts-fw-data"
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
  nj-courts-fw-mgmt = {
    name = "nj-courts-fw-mgmt"
    rules = {
      all-outbound = {
        description = "Permit All traffic outbound"
        type        = "egress", from_port = "0", to_port = "0", protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
      allow-from-mgmt = {
        description = "Permit traffic from the mgmt subnets to themselves/each other"
        type        = "ingress", from_port = "0", to_port = "0", protocol = "-1"
        cidr_blocks = ["10.243.146.0/28", "10.243.147.0/28"]
      }
      ssh-from-inet = {
        description = "Permit SSH"
        type        = "ingress", from_port = "22", to_port = "22", protocol = "tcp"
        cidr_blocks = ["199.167.52.5/32", "68.38.137.81/32", "208.184.7.6/32"] # TODO: update here
      }
      https-from-inet = {
        description = "Permit HTTPS"
        type        = "ingress", from_port = "443", to_port = "443", protocol = "tcp"
        cidr_blocks = ["199.167.52.5/32", "68.38.137.81/32", "208.184.7.6/32"] # TODO: update here
      }
      panorama-mgmt = {
        description = "Permit Panorama Management"
        #type        = "ingress", from_port = "3978", to_port = "3978", protocol = "tcp"
        type        = "ingress", from_port = "0", to_port = "0", protocol = "-1"
        cidr_blocks = ["10.243.92.13/32"] // IP of Panoramas, comma separated list
      }
      panorama = {
        description = "Permit Panorama Logging"
        type        = "ingress", from_port = "28443", to_port = "28443", protocol = "tcp"
        cidr_blocks = ["10.243.92.13/32"] // IP of Panoramas, comma separated list
      }
    }
  }
}

### VMSERIES ###

firewalls = [
  {
    name    = "nj-courts-fw-01"
    fw_tags = {}
    bootstrap_options = {
      mgmt-interface-swap = "enable"
      plugin-op-commands  = "aws-gwlb-inspect:enable"
      type                = "dhcp-client"
      hostname            = "nj-courts-fw-01"
      tplname             = "STK-GWLB"
      dgname              = "DG-GWLB"
      panorama-server     = "10.243.92.13"
      panorama-server-2   = ""
      vm-auth-key         = "856438785494506"
      authcodes           = ""
      op-command-modes    = ""
    }
    interfaces = [
      { name = "nj-courts-vmseries01-data", index = "0" },
      { name = "nj-courts-vmseries01-mgmt", index = "1" },
    ]
  },
  {
    name    = "nj-courts-fw-02"
    fw_tags = {}
    bootstrap_options = {
      mgmt-interface-swap = "enable"
      plugin-op-commands  = "aws-gwlb-inspect:enable"
      type                = "dhcp-client"
      hostname            = "nj-courts-fw-02"
      tplname             = "STK-GWLB"
      dgname              = "DG-GWLB"
      panorama-server     = "10.243.92.13"
      panorama-server-2   = ""
      vm-auth-key         = "856438785494506"
      authcodes           = ""
      op-command-modes    = "" # can we add endpoint ID and interfaces? 
    }
    interfaces = [
      { name = "nj-courts-vmseries02-data", index = "0" },
      { name = "nj-courts-vmseries02-mgmt", index = "1" },
    ]
  }
]

interfaces = [
  # vmseries01
  {
    name                          = "nj-courts-vmseries01-data"
    source_dest_check             = false
    subnet_name                   = "nj-courts-dataa"
    security_group                = "nj-courts-fw-data"
    private_ip_address_allocation = "dynamic"
  },
  {
    name                          = "nj-courts-vmseries01-mgmt"
    source_dest_check             = true
    subnet_name                   = "nj-courts-mgmta"
    security_group                = "nj-courts-fw-mgmt"
    private_ip_address_allocation = "dynamic"
    eip                           = "nj-courts-vmseries01-mgmt"
  },
  # vmseries02
  {
    name                          = "nj-courts-vmseries02-data"
    source_dest_check             = false
    subnet_name                   = "nj-courts-datab"
    security_group                = "nj-courts-fw-data"
    private_ip_address_allocation = "dynamic"
  },
  {
    name                          = "nj-courts-vmseries02-mgmt"
    source_dest_check             = true
    subnet_name                   = "nj-courts-mgmtb"
    security_group                = "nj-courts-fw-mgmt"
    private_ip_address_allocation = "dynamic"
    eip                           = "nj-courts-vmseries02-mgmt"
  },
]

### Security VPC ROUTES ###

summary_cidr_behind_tgw            = "10.0.0.0/8"
summary_cidr_behind_gwlbe_outbound = "0.0.0.0/0"

### TGW ###

transit_gateway_name                = "nj-courts"
transit_gateway_asn                 = "65200"
security_transit_gateway_attachment = "franklin-security-vpc"
create_tgw                          = true

transit_gateway_route_tables = {
  "from_security_vpc" = {
    create = true
    name   = "from_security"
  }
  "from_spoke_vpc" = {
    create = true
    name   = "from_spokes"
  }
}

## Example Application VPC ##

app1_vpc_subnets = {
  "10.243.148.0/28" = { az = "us-east-1a", set = "app1_alb" }
  //"10.243.149.0/28"  = { az = "us-east-1b", set = "app1_alb" }
  "10.243.148.32/28" = { az = "us-east-1a", set = "app1_gwlbe" }
  //"10.243.149.32/28" = { az = "us-east-1b", set = "app1_gwlbe" }
  "10.243.148.64/28" = { az = "us-east-1a", set = "app1_web" }
  //"10.243.149.64/28" = { az = "us-east-1b", set = "app1_web" }
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
        cidr_blocks = ["199.167.52.5/32", "68.38.137.81/32", "208.184.7.6/32"] # TODO: update here
      }
      http-from-inet = {
        description = "Permit HTTP"
        type        = "ingress", from_port = "80", to_port = "80", protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0", "208.184.7.6/32"] # allow HTTP traffic into app vpc from anywhere (hello world site) 
      }
      https-from-inet = {
        description = "Permit HTTPS"
        type        = "ingress", from_port = "443", to_port = "443", protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0", "208.184.7.6/32"] # allow traffic in to app vpc from anywhere 
      }
    }
  }
}
