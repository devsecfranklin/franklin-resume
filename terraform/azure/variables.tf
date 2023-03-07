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

variable "address_space_eu_west" {
  description = "The address space used by the virtual network. You can supply more than one address space."
  type        = list(string)
  default     = ["10.10.8.0/25"]
}

variable "address_space_eu_north" {
  description = "The address space used by the virtual network. You can supply more than one address space."
  type        = list(string)
  default     = ["10.10.8.128/25"]
}

variable "name_prefix" {
  description = "A prefix for all the names of the created Azure objects. It can end with a dash `-` character, if your naming convention prefers such separator."
  default     = "lab-franklin-"
  type        = string
}

variable "tags" {
  description = "Map of tags to be associated with the virtual machines, their interfaces and public IP addresses."
  default     = {}
  type        = map(string)
}
