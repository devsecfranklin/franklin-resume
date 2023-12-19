variable "location" {
  description = "The Azure region to use."
  default     = "West US"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Resource Group to create. If not provided, it will be auto-generated."
  default     = "lab-franklin"
  type        = string
}

variable "virtual_network_name" {
  type        = string
  default     = "HubVNet"
  description = "Name of the vnet to build"
}

variable "address_space_fw" {
  description = "The CIDRs for the VNET"
  type        = list(string)
  default     = ["172.21.0.0/21"]
}

variable "name_prefix" {
  description = "A prefix for all the names of the created Azure objects. It can end with a dash `-` character, if your naming convention prefers such separator."
  default     = "lab-franklin-"
  type        = string
}

variable "tags" {
  description = "Map of tags to be associated with the virtual machines, their interfaces and public IP addresses."
  default = {
    lab = "franklin"
  }
  type = map(string)
}

variable "create_subnets" {
  type    = bool
  default = true
}

variable "inside_subnet" {
  default = "PaloTrustSubnet"
}

variable "outside_subnet" {
  default = "PaloUntrustSubnet"
}

variable "mgmt_subnet" {
  default = "PaloManagementSubnet"
}

variable "enable_zones" {
  description = "If false, all the VM-Series, load balancers and public IP addresses default to not to use Availability Zones (the `No-Zone` setting). It is intended for the regions that do not yet support Availability Zones."
  default     = false
  type        = bool
}

variable "inside_lb_name" {
  default = "palo-ilb"
}

variable "inside_lb_ip" {
  default = "172.21.5.125"
}

variable "username" {
  description = "Initial administrative username to use for all systems."
  default     = "panadmin"
  type        = string
}

variable "password" {
  description = "Initial administrative password to use for all systems. Set to null for an auto-generated password."
  default     = null
  type        = string
}

variable "vmseries" {
  description = <<-EOF
  Map of virtual machines to create to run VM-Series. Keys are the individual names, values
  are the objects containing the attributes unique to that individual virtual machine:
  - `avzone`: the Azure Availability Zone identifier ("1", "2", "3"). Default is "1" in order to avoid non-HA deployments.
  - `trust_private_ip`: the static private IP to assign to the trust-side data interface (nic2). If unspecified, uses a dynamic IP.
  The hostname of each of the VM-Series will consist of a `name_prefix` concatenated with its map key.
  Basic:
  ```
  {
    "fw00" = { avzone = 1 }
    "fw01" = { avzone = 2 }
  }
  ```
  Full example:
  ```
  {
    "fw00" = {
      trust_private_ip = "192.168.0.10"
      avzone           = "1"
    }
    "fw01" = { 
      trust_private_ip = "192.168.0.11"
      avzone           = "2"
    }
  }
  ```
  EOF
  default = {
    "palo01" = {
      avzone             = 1
      inside_private_ip  = "172.21.5.70"
      outside_private_ip = "172.21.5.134"
      mgmt_private_ip    = "172.21.5.196"
    }
    "palo02" = {
      avzone             = 2
      inside_private_ip  = "172.21.5.71"
      outside_private_ip = "172.21.5.135"
      mgmt_private_ip    = "172.21.5.197"
    }
  }
}

variable "vmseries_sku" {
  description = "VM-Series SKU - list available with `az vm image list -o table --all --publisher paloaltonetworks`"
  #default     = "bundle2"
  default = "byol"
  type    = string
}

variable "vmseries_version" {
  description = "VM-Series PAN-OS version - list available with `az vm image list -o table --all --publisher paloaltonetworks`"
  default     = "10.2.2"
  type        = string
}

variable "vmseries_vm_size" {
  description = "Azure VM size (type) to be created. Consult the *VM-Series Deployment Guide* as only a few selected sizes are supported."
  default     = "Standard_D3_v2"
  type        = string
}

variable "vmseries_bootstrap_options" {
  description = "Bootstrap options for the vm-series"
  default     = "type=dhcp-client;dhcp-accept-server-hostname;authcodes=D9629642"
}

variable "avzones" {
  type    = list(string)
  default = ["1", "2", "3"]
}