variable "location" {
  description = "The Azure region to use."
  default     = "Central US"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Resource Group to create. If not provided, it will be auto-generated."
  default     = "franklin-lab"
  type        = string
}

variable "name_prefix" {
  description = "A prefix for all the names of the created Azure objects. It can end with a dash `-` character, if your naming convention prefers such separator."
  default     = "franklin-lab-"
  type        = string
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

variable "storage_account_name" {
  description = <<-EOF
  Default name of the storage account to create.
  The name you choose must be unique across Azure. The name also must be between 3 and 24 characters in length, and may include only numbers and lowercase letters.
  EOF
  default     = "franklintfstore001"
  type        = string
}

variable "inbound_files" {
  description = "Map of all files to copy to `inbound_storage_share_name`. The keys are local paths, the values are remote paths. Always use slash `/` as directory separator (unix-like), not the backslash `\\`. For example `{\"dir/my.txt\" = \"config/init-cfg.txt\"}`"
  default     = {}
  type        = map(string)
}

variable "outbound_files" {
  description = "Map of all files to copy to `outbound_storage_share_name`. The keys are local paths, the values are remote paths. Always use slash `/` as directory separator (unix-like), not the backslash `\\`. For example `{\"dir/my.txt\" = \"config/init-cfg.txt\"}`"
  default     = {}
  type        = map(string)
}

variable "outbound_storage_share_name" {
  description = "Name of storage share to be created that holds `files` for bootstrapping outbound VM-Series."
  type        = string
}

variable "virtual_network_name" {
  description = "Name of the Virtual Network to create."
  default     = "franklin-vnet"
  type        = string
}

# variable "address_space" {
#   description = "The address space used by the virtual network. You can supply more than one address space."
#   type        = list(string)
# }

variable "network_security_groups" {
  description = "Map of Network Security Groups to create. Refer to the `vnet` module documentation for more information."
}

variable "allow_inbound_mgmt_ips" {
  description = <<-EOF
    List of IP CIDR ranges (like `["23.23.23.23"]`) that are allowed to access management interfaces of VM-Series.
    If you use Panorama, include its address in the list (as well as the secondary Panorama's).
  EOF
  default     = []
  type        = list(string)
}

variable "allow_inbound_data_ips" {
  description = <<-EOF
    List of IP CIDR ranges (like `["23.23.23.23"]`) that are allowed to access public data interfaces of VM-Series.
    If the list is empty, the contents of `allow_inbound_mgmt_ips` are substituted instead.
  EOF
  default     = []
  type        = list(string)
}

variable "allow_inbound_gp_data_ips" {
  description = <<-EOF
    List of IP CIDR ranges (like `["23.23.23.23"]`) that are allowed to access public data interfaces of VM-Series.
    If the list is empty, the contents of `allow_inbound_mgmt_ips` are substituted instead.
  EOF
  default     = []
  type        = list(string)
}

variable "allow_inbound_ipsec_data_ips" {
  description = <<-EOF
    List of IP CIDR ranges (like `["23.23.23.23"]`) that are allowed to access public data interfaces of VM-Series.
    If the list is empty, the contents of `allow_inbound_mgmt_ips` are substituted instead.
  EOF
  default     = []
  type        = list(string)
}

variable "route_tables" {
  description = "Map of Route Tables to create. Refer to the `vnet` module documentation for more information."
}

variable "subnets" {
  description = "Map of Subnets to create. Refer to the `vnet` module documentation for more information."
}

variable "vnet_tags" {
  description = "Map of tags to assign to the created virtual network and other network-related resources. By default equals to `inbound_vmseries_tags`."
  type        = map(string)
  default     = {}
}

variable "olb_private_ip" {
  description = "The private IP address to assign to the outbound load balancer. This IP **must** fall in the `private_subnet` network."
  default     = "10.110.0.21"
  type        = string
}

variable "frontend_ips" {
  description = "Map of objects describing frontend IP configurations and rules for the inbound load balancer. See the [loadbalancer documentation](./modules/loadbalancer/README.md) for details."
}

variable "outbound_vmseries_sku" {
  description = "VM-Series SKU - list available with `az vm image list -o table --all --publisher paloaltonetworks`"
  default     = "bundle2"
  type        = string
}

variable "inbound_vmseries_version" {
  description = "Inbound VM-Series PAN-OS version - list available with `az vm image list -o table --all --publisher paloaltonetworks`"
  default     = "9.1.3"
  type        = string
}

variable "outbound_vmseries" {
  description = <<-EOF
  Map of virtual machines to create to run VM-Series dedicated for traffic outbound to the Internet. Format is the same as for `inbound_vmseries`.
  EOF
}

variable "outbound_vmseries_version" {
  description = "Outbound VM-Series PAN-OS version - list available with `az vm image list -o table --all --publisher paloaltonetworks`"
  default     = "10.0.6"
  type        = string
}

variable "outbound_vmseries_vm_size" {
  description = "Azure VM size (type) to be created. Consult the *VM-Series Deployment Guide* as only a few selected sizes are supported."
  default     = "Standard_D3_v2"
  type        = string
}

variable "outbound_vmseries_tags" {
  description = "Map of tags to be associated with the outbound virtual machines, their interfaces and public IP addresses."
  default     = {}
  type        = map(string)
}

variable "outbound_lb_name" {
  description = "Name of the outbound load balancer."
  default     = "lb_outbound"
  type        = string
}

variable "outbound_gp_lb_name" {
  description = "Name of the outbound GP load balancer."
  default     = "lb_gp_outbound"
  type        = string
}

variable "outbound_ipsec_lb_name" {
  description = "Name of the outbound GP load balancer."
  default     = "lb_ipsec_outbound"
  type        = string
}

variable "enable_zones" {
  description = "If false, all the VM-Series, load balancers and public IP addresses default to not to use Availability Zones (the `No-Zone` setting). It is intended for the regions that do not yet support Availability Zones."
  default     = true
  type        = bool
}

variable "tags" {
  type = map(string)
}

variable "inbound_lb_name" {
  description = "Name of the inbound load balancer (the public-facing one)."
  default     = "lb_inbound"
  type        = string
}

variable "inbound_gp_lb_name" {
  description = "Name of the inbound load balancer (the public-facing one)."
  default     = "lb_gp_inbound"
  type        = string
}

variable "inbound_ipsec_lb_name" {
  description = "Name of the inbound load balancer (the public-facing one)."
  default     = "lb_ipsec_inbound"
  type        = string
}


variable "olb_gp_private_ip" {
  description = "The private IP address to assign to the outbound GP load balancer. This IP **must** fall in the `private_subnet` network."
  default     = "10.11.40.136"
  type        = string
}

variable "gp_vmseries" {
  description = <<-EOF
  Map of virtual machines to create to run VM-Series dedicated for traffic outbound to the Internet. Format is the same as for `inbound_vmseries`.
  EOF
}

variable "frontend_gp_ips" {
  description = "Map of objects describing frontend IP configurations and rules for the inbound load balancer. See the [loadbalancer documentation](./modules/loadbalancer/README.md) for details."
}

variable "olb_ipsec_private_ip" {
  description = "The private IP address to assign to the outbound IPsec load balancer. This IP **must** fall in the `private_subnet` network."
  type        = string
}

variable "frontend_ipsec_ips" {
  description = "Map of objects describing frontend IP configurations and rules for the inbound load balancer. See the [loadbalancer documentation](./modules/loadbalancer/README.md) for details."
}

variable "ipsec_vmseries" {
  description = <<-EOF
  Map of virtual machines to create to run VM-Series dedicated for traffic outbound to the Internet. Format is the same as for `inbound_vmseries`.
  EOF
}
