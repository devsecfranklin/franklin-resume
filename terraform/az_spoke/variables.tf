variable "location" {
  description = "Location of the resources that will be deployed."
  type        = string
}

variable "prefix" {
  description = "This is just to identify your resources, as all name are hardocded"
  default     = "fosix"
}

variable "vmseries_rg" {
  type = string
}

variable "vmseries_vnet" {
  type = string
}

variable "vmseries_private_olb" {
  type = string
}

variable "east_vnet" {
  default = {
    cdir         = ["172.16.10.0/28", "172.16.10.16/28"]
    eastVMs_cdir = "172.16.10.0/28"
    bastion_cdir = "172.16.10.16/28"
  }
}

variable "west_vnet" {
  default = {
    cdir         = ["172.16.10.48/28", "172.16.10.32/28"]
    westVMs_cdir = "172.16.10.32/28"
    bastion_cdir = "172.16.10.48/28"
  }
}

variable "ssh_key_path" {
  type = string
}
