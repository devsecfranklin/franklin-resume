variable "region" {
  default = "eu-west-1"
  type    = string
}

variable "tags" {
  description = "Map of tags to be associated with the virtual machines, their interfaces and public IP addresses."
  default     = {}
  type        = map(string)
}
