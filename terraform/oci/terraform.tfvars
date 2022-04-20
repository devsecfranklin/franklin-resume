# Remember to either export TF_VAR_compartment or define comparment here
compartment = "ocid1.compartment.oc1..aaaaaaaar3hqbsbcrmlwy7sf3gi6vqyhcgoxw3plvi36odsxy5zrw63troaq"

region      = "us-ashburn-1"
tags        = { "Managed-by" : "Terraform" }
dns_label   = "franklin"
drg_name    = "franklin-ash-drg"
vcn_name    = "franklin-hub"
cidr_blocks = ["10.114.0.0/22"] # Ashburn
img_version = "10.0.4"
//shape                           = "VM.Standard2.8"
ssh_key_file                    = "~/.ssh/id_rsa_work.pub" // public key
elb_name                        = "franklin-elb"
ilb_name                        = "franklin-ilb"
elb_preserve_source_destination = false // might want to set to true
ilb_preserve_source_destination = false // might want to set to true
ilb_health_checker_port         = 22
elb_health_checker_port         = 22

elb_listeners = {
  SSH = {
    port     = 22
    protocol = "TCP"
  }
  HTTP = {
    port     = 80
    protocol = "TCP"
  }
} // elb_listeners

ilb_listeners = {
  SSH = {
    port     = 22
    protocol = "TCP"
  }
  HTTP = {
    port     = 80
    protocol = "TCP"
  }
} // ilb_listeners

firewalls = {
  "left" = { # <= do not change this label
    ad   = "AzxO:US-ASHBURN-AD-2"
    name = "left"
  }
  "right" = { # <= do not change this label
    ad   = "AzxO:US-ASHBURN-AD-3"
    name = "right"
  }
} // firewalls


subnets = {
  "mgmt" = { # <= do not change this label
    cidr_block    = "10.114.0.0/24"
    security_list = "allow_all_security_list"
    route_table   = "mgmt"
  },
  "trust" = { # <= do not change this label
    cidr_block    = "10.114.2.0/24"
    security_list = "allow_all_security_list"
    route_table   = "trust"
    private       = true
  },
  "untrust" = { # <= do not change this label
    cidr_block    = "10.114.1.0/24"
    security_list = "allow_all_security_list"
    route_table   = "untrust"
  },
} // subnets

route_tables = {
  "mgmt" = { # <= must match the "route_table" entry in the "subnets" map
    routes = {
      "default" = {
        cidr_block    = "0.0.0.0/0"
        next_hop_type = "igw"
      },
    }
  },
  "trust" = { # <= must match the "route_table" entry in the "subnets" map
    routes = {
      "default" = {
        cidr_block    = "0.0.0.0/0"
        next_hop_type = "drg"
      },
    }
  },
  "untrust" = { # <= must match the "route_table" entry in the "subnets" map
    routes = {
      "default" = {
        cidr_block    = "0.0.0.0/0"
        next_hop_type = "igw"
      },
    }
  }
} // route_tables

security_lists = {
  "allow_all_security_list" = { # <= must match the "security_list" entry in the "subnets" map
    ingress_rules = {
      "AllowSSH" = {
        protocol         = 6 // TCP
        destination_port = "22"
        source           = "0.0.0.0/0"
        stateless        = false
      },
      "AllowHTTPS" = {
        protocol         = 6 // TCP
        destination_port = "443"
        source           = "0.0.0.0/0"
        stateless        = false
      },
      "AllowICMP" = {
        protocol = 1 // ICMP
        source   = "0.0.0.0/0"
      }

    },
    egress_rules = {
      "AllowTCP" = {
        protocol         = 6 // TCP
        destination_port = "*"
        destination      = "0.0.0.0/0"
      },
      "AllowICMP" = {
        protocol    = 1 // ICMP
        destination = "0.0.0.0/0"
      }
    }
  },
} // security_lists
