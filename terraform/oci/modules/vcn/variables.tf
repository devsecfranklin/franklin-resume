variable "compartment" {}

variable "region" {
  description = "Region of the resources that will be deployed."
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to all of the created resources."
  type        = map(any)
  default     = {}
}

variable "virtual_network_name" {
  description = "The name of the VCN to create."
  type        = string
  default     = null
}

variable "create_vcn" {
  description = "Set to true if you want to create VCN"
  type        = bool
  default     = true
}

variable "vcn_id" {
  description = "The OCID of the VCN to use (used when create_vcn==false)."
  type        = string
  default     = null
}

variable "cidr_blocks" {
  description = "The address space used by the virtual network. You can supply more than one cidr blocks."
  type        = list(string)
}

variable "create_igw" {
  description = "Set to true if you want to create Internet Gateway"
  type        = bool
  default     = false
}

variable "internet_gateway_name" {
  description = "The name of the IGW to create. If not set, the name will be auto generated."
  type        = string
  default     = null
}

variable "dns_label" {
  description = <<-EOF
  (Optional) A DNS label for the VCN, used in conjunction with the VNIC's hostname and subnet's DNS label to form a fully qualified domain name (FQDN) for each 
  VNIC within this subnet (for example, instance1.subnet123.vcn1.oraclevcn.com). Not required to be unique, but it's a best practice to set unique DNS labels 
  for VCNs in your tenancy. Must be an alphanumeric string that begins with a letter. The value cannot be changed.
  You must set this value if you want instances to be able to use hostnames to resolve other instances in the VCN. Otherwise the Internet and VCN Resolver will not work.
  For more information, see [DNS in Your Virtual Cloud Network](https://docs.cloud.oracle.com/iaas/Content/Network/Concepts/dns.htm).
  EOF
  type        = string
  default     = null
}

variable "security_lists" {
  description = <<-EOF
  A map of Security Lists objects to create. The key of each entry acts as the Security List name.
  List of arguments available to define a Security List:
  - `ingress_rules`: A list of objects representing a Security List. The key of each entry acts as the name of the rule.
      List of arguments available to define Rules:
      - `protocol` : Network protocol this rule applies to. Possible values include 1 (ICMP), 6 (TCP), 17 (UDP).
      - `destination_port` : Destination Port. Integer or `*` to match any. Valid only for protocol set to 6 or 17.
      - `destination` : Destination IP range.
      - `stateless` : Set to "true" if ther rule should be stateless
  - `egress_rules`: A list of objects representing a Security List. The key of each entry acts as the name of the rule.
      List of arguments available to define Rules:
      - `protocol` : Network protocol this rule applies to. Possible values include 1 (ICMP), 6 (TCP), 17 (UDP).
      - `destination_port` : Destination Port. Integer or `*` to match any. Valid only for protocol set to 6 or 17.
      - `source` : Source IP range.
      - `stateless` : Set to "true" if ther rule should be stateless

  Example:
  ```
  {
  "management_security_list" = {
    ingress_rules = {
      "AllowSSH" = {
        protocol         = 6 // TCP
        destination_port = "22"
        source           = "0.0.0.0/0"
        stateless        = false
      },
      "AllowICMP" = {
        protocol = 1 // ICMP
        source   = "0.0.0.0/0"
      }

    },
    egress_rules = {
      "AllOutbound" = {
        protocol         = 6 // TCP
        destination_port = "*"
        destination      = "0.0.0.0/0"
      }
    }
  }
}
  ```
  EOF
}

variable "route_tables" {
  description = <<-EOF
  A map of objects describing a Route Table. The key of each entry acts as the Route Table name.
  
  Example:
  ```
  {
    "management_route_table" = {
    routes = {
      "default" = {
        cidr_block    = "0.0.0.0/0"
        next_hop_type = "igw"
      },
    }
  },
  "private_route_table" = {
    routes = {
      "default" = {
        cidr_block    = "0.0.0.0/0"
        next_hop_type = "igw"
      },
      "to_drg" = {
        cidr_block    = "192.168.0.0/16"
        next_hop_type = "drg"
      },      
    }
  },
  "public_route_table" = {
    routes = {}
  },
}
  ```
  EOF
}

variable "subnets" {
  description = <<-EOF
  A map of subnet objects to create within a VCN. The object `key` acts as the subnet name.
  List of arguments available to define a subnet:
  - `cidr_block` : The address prefix to use for the subnet.
  - `security_list` : The Security List ID which should be associated with the subnet.
  - `route_table` : The Route Table ID which should be associated with the subnet.
  - `private` :  Mark subnet as private, ensure that instances in the subnet have no internet access, even if the VCN has a working internet gateway.
  - `dns_label`: (Optional) A DNS label for the subnet, used in conjunction with the VNIC's hostname and VCN's DNS label to form a fully qualified domain name (FQDN) for each VNIC within this subnet.

  Example:
  ```
  {
  "management" = {
    cidr_block    = "172.19.1.0/24"
    security_list = "security_list_2"
    route_table   = "route_table_1"
    },
  "private" = {
    cidr_block    = "172.19.2.0/24"
    security_list = "private_security_list"
    route_table   = "private_route_table"
    private       = true
    dns_label     = "private"
    },
  "public" = {
    cidr_block    = "172.19.3.0/24"
    security_list = "security_list_2"
    route_table   = "route_table_3"
    }
  }
  ```
  EOF
}

variable "peerings" {
  description = <<-EOF
  A map of objects describing Peerings. The key of each entry acts as the Peering name.
  List of arguments available to define a peering:
  - `cidr_block` : The address prefix of a remote network.
  - `route_table` : The Route Table name to which peering entry will be added.
  - `peer_id` (Optional) : ID of a Peering on a remote side. Specifying a peer_id creates a connection to the specified LPG ID. peer_id should only be specified in one of the LPGs.
  
  Example:
  ```
  {
    to_vcn1 = {
      peer_id     = module.vcn1.peering_ids["to_vcn2"]
      route_table = "rt"
      cidr_block  = "172.21.0.0/16"
    },
    to_vcn2 = {
      route_table = "rt"
      cidr_block  = "172.22.0.0/16"
    }
  }
  ```
  EOF
  type        = map(any)
  default     = {}
}

variable "use_drg" {
  description = "Set to true if you want to use DRG"
  type        = bool
  default     = false

}
variable "drg_id" {
  description = "The OCID of the DRG to attach this VCN to (used only when use_drg==true)."
  type        = string
  default     = null
}
