variable "host_project_id" {
  type    = string
  default = "lpgprj-b2b-p-hostcc-us-01"
}

variable "service_projects_ids" {
  type = map(any)
}

variable "region" {
  type    = string
  default = "us-east1"
}

variable "name_prefix" {
  type    = string
  default = "lpgcen-ppal-"
}

variable "vmseries" {}

variable "vmseries_common" {}
variable "vmseries_common_ingress" {}
variable "vmseries_common_egress" {}

variable "ssh_keys" {
  type = string
}

variable "extlb_name" {
  type    = string
  default = "elb"
}

variable "allowed_sources_ingress" {}
variable "allowed_sources_egress" {}
variable "allowed_sources_mgmt" {}
variable "allowed_sources_panorama" {}

variable "ip_cidr_range_mgmt" {}
variable "ip_cidr_range_ingress" {}
variable "ip_cidr_range_egress" {}