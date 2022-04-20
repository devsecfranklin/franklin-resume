variable "compartment" {
  type        = string
  description = "Franklin compartment"
}

variable "region" {
  type    = string
  default = "us-ashburn-1"
}

variable "drg_name" {
  type = string
}

variable "tags" {
  default = { "Owner" : "franklin" }
}

variable "vcn_name" {
  type    = string
  default = "franklin-security"
}

variable "subnets" {}

variable "cidr_blocks" {
  type = list(string)
}

variable "security_lists" {}

variable "route_tables" {}

variable "dns_label" {
  type = string
}

variable "firewalls" {}

variable "img_version" {
  type    = string
  default = "10.0.4"
}

variable "shape" {
  type        = string
  default     = "VM.Standard2.4"
  description = "https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/set-up-the-vm-series-firewall-on-oracle-cloud-infrastructure/oci-shape-types"
}

variable "ssh_key_file" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

variable "elb_name" {
  type = string
}
variable "ilb_name" {
  type = string
}
variable "elb_listeners" {}
variable "ilb_listeners" {}
variable "elb_preserve_source_destination" {}
variable "ilb_preserve_source_destination" {}
variable "elb_health_checker_port" {}
variable "ilb_health_checker_port" {}
