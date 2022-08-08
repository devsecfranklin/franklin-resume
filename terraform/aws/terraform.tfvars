region = "us-west-2"
name   = "security" #change me

#security_vpc_name     = "AWS-Security-VPC"
#security_vpc_cidr     = "10.161.80.0/22" #change me
secondary_cidr_blocks = []               #change me (optional)

#domain_name         = "refint.global"
#domain_name_servers = ["8.8.8.8"]
#ntp_servers         = ["216.239.35.8"]

gwlb_name                       = "security-gwlb-01"           #change me
gwlb_endpoint_set_eastwest_name = "security-eastwest-endpoint" #change me
gwlb_endpoint_set_outbound_name = "security-outbound-endpoint" #change me

transit_gateway_name = "lab-franklin-tgw" #change me
transit_gateway_asn  = "65200"
transit_gateway_route_tables = {
  "from_security_vpc" = {
    create = true
    name   = "FROM-SECURITY-TGW-RT"
  }
  "from_spoke_vpc" = {
    create = true
    name   = "FROM-SPOKES-TGW-RT"
  }
}

security_vpc_tgw_attachment_name = "tgw-attachment" #change me

security_vpc_subnets = { #change me
  # Do not modify value of `set=`, it is an internal identifier referenced by main.tf.
  "10.161.80.0/28"   = { az = "us-west-2a", set = "security-mgmt" }
  "10.161.80.16/28"  = { az = "us-west-2b", set = "security-mgmt" }
  "10.161.80.48/28"  = { az = "us-west-2a", set = "security-data" }
  "10.161.80.64/28"  = { az = "us-west-2b", set = "security-data" }
  "10.161.80.80/28"  = { az = "us-west-2a", set = "security-transit" }
  "10.161.80.96/28"  = { az = "us-west-2b", set = "security-transit" }
  "10.161.80.112/28" = { az = "us-west-2a", set = "security-gwlbe-outbound" }
  "10.161.80.128/28" = { az = "us-west-2b", set = "security-gwlbe-outbound" }
  "10.161.80.144/28" = { az = "us-west-2a", set = "security-gwlb" }
  "10.161.80.160/28" = { az = "us-west-2b", set = "security-gwlb" }
  "10.161.80.176/28" = { az = "us-west-2a", set = "security-gwlbe-eastwest" }
  "10.161.80.192/28" = { az = "us-west-2b", set = "security-gwlbe-eastwest" }
}

security_subnet_mgmt_name           = "security-mgmt"
security_subnet_data_name           = "security-data"
security_subnet_transit_name        = "security-transit"
security_subnet_gwlbe_outbound_name = "security-gwlbe-outbound"
security_subnet_gwlb_name           = "security-gwlb"
security_subnet_gwlbe_eastwest_name = "security-gwlbe-eastwest"
#security_subnet_natgw_name          = "security-natgw"

security_vpc_security_groups = {
  vmseries_data = {
    name = "security-data"
    rules = {
      all_outbound = {
        description = "Permit All traffic outbound"
        type        = "egress", from_port = "0", to_port = "0", protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
      geneve = {
        description = "Permit GENEVE to GWLB subnets"
        type        = "ingress", from_port = "6081", to_port = "6081", protocol = "udp"
        cidr_blocks = ["10.161.80.144/28", "10.161.80.160/28"]
      }
      health_probe = {
        description = "Permit Port 80 Health Probe to GWLB subnets"
        type        = "ingress", from_port = "80", to_port = "80", protocol = "tcp"
        cidr_blocks = ["10.161.80.144/28", "10.161.80.160/28"]
      }
    }
  }
  vmseries_mgmt = {
    name = "security-mgmt"
    rules = {
      ###### EGRESS #######
      all_outbound = {
        description = "Permit All traffic outbound"
        type        = "egress", from_port = "0", to_port = "0", protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
      ##### INGRESS ######
      https = {
        description = "Permit HTTPS"
        type        = "ingress", from_port = "443", to_port = "443", protocol = "tcp"
        cidr_blocks = ["10.0.0.0/8", "34.99.247.241/32"] # TODO: update here
      }
      ssh = {
        description = "Permit SSH"
        type        = "ingress", from_port = "22", to_port = "22", protocol = "tcp"
        cidr_blocks = ["10.0.0.0/8", "34.99.247.241/32"] # TODO: update here
      }
      icmp = {
        description = "Permit ICMP"
        type        = "ingress", from_port = "-1", to_port = "-1", protocol = "icmp"
        cidr_blocks = ["10.0.0.0/8"]
      }
    }
  }
}

### VMSERIES ###
vmseries_version = "10.1.6"
instance_type    = "m5.xlarge" # VM-300

create_ssh_key = false
ssh_key_name   = "vmseries_key_enel" #change me
vmseries = {
  vmseries01 = { az = "us-west-2a" } #change me
  vmseries02 = { az = "us-west-2b" } #change me
}

vmseries_common = {
  bootstrap_options = {
    mgmt-interface-swap = "enable",
    type                = "type=dhcp-client",
    panorama-server     = "10.15.0.8", #change me
    #panorama-server-2           = "10.10.10.11",   #change me
    tplname                     = "stack-security-test",
    dgname                      = "security-test",
    vm-auth-key                 = "951587877568221", #change me
    authcodes                   = "I3966646",
    op-command-modes            = "jumbo-frame",
    plugin-op-commands          = "panorama-licensing-mode-on,aws-gwlb-inspect:enable",
    dns-primary                 = "8.8.8.8", #change me
    dns-secondary               = "8.8.4.4", #change me
    dhcp-accept-server-hostname = "yes",
    dhcp-accept-server-domain   = "yes",
  }
}

east_west_subinterface = "ethernet1/1.10"
outbound_subinterface  = "ethernet1/1.20" #not used according to the TRD

### Security VPC routes ###

security_vpc_routes_outbound_source_cidrs = [ # outbound traffic return after inspection
  "10.0.0.0/8",
]

security_vpc_routes_outbound_destin_cidrs = [ # outbound traffic incoming for inspection from TGW
  "0.0.0.0/0",
]

security_vpc_routes_eastwest_cidrs = [ # eastwest traffic incoming for inspection from TGW
  "10.0.0.0/8",
]

security_vpc_mgmt_routes_to_tgw = [
  "10.15.0.0/24", # Panorama via TGW (must not repeat any security_vpc_routes_eastwest_cidrs)
]

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