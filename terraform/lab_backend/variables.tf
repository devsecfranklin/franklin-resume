/* *********************** AZURE ********************** */

variable "resource_group_name" {
  description = "Name of the Azure Resource Group to use for lab elements"
  default     = "franklin-lab"
  type        = string
}

variable "location" {
  description = "Location of the Azure resources that will be deployed."
  default            = "East US"
  type        = string
}

variable "tags" {
  description = "Map of tags to assign to all of the Azure resources."
  type        = map(any)
  default = {
    application = "Palo Alto Networks VM-Series"
    managed_by  = "terraform 1.x"
    owner       = "franklin"
  }
}
