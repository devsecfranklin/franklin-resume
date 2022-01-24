variable "region" {
  description = "AWS Region for deployment, for example \"us-east-1\"."
  type        = string
  default     = "us-east-1"
}

variable "tf_state_bucket" {
  description = "where to store terraform state files"
  type        = string
  default     = "nj-courts-tf-state"
}

// all the logging
variable "work_bucket" {
  default = "tf-state-nj-courts-logging"
  type    = string
}

variable "prefix_name_tag" {
  description = "Prepend a string to Name tags for the created resources. Can be empty."
  default     = ""
  type        = string
}

variable "global_tags" {
  description = "Optional map of arbitrary tags to apply to all the created resources."
  default     = {}
  type        = map(string)
}

variable "vpc_tags" {
  description = "Optional map of arbitrary tags to apply to the created VPC resource, in addition to the `global_tags`."
  default     = {}
  type        = map(string)
}

variable "fw_instance_type" {
  default = "m5.xlarge"
  type    = string
}

variable "fw_license_type" {
  default = "byol"
  type    = string
}

variable "fw_version" {
  default     = "10.0.7"
  type        = string
  description = "This can be empty"
}

variable "security_vpc_name" {
  type    = string
  default = "Network-Security-VPC"
}

variable "security_vpc_cidr" {
  description = "Security VPC CIDR"
  type        = string
  default     = "10.243.146.0/23"
}

variable "security_vpc_subnets" {}

variable "security_vpc_security_groups" {}

variable "transit_gateway_name" {}

variable "transit_gateway_asn" {}

variable "transit_gateway_route_tables" {}

variable "security_transit_gateway_attachment" {}

variable "firewalls" {}

variable "interfaces" {}

variable "summary_cidr_behind_tgw" {}

variable "summary_cidr_behind_gwlbe_outbound" {}

variable "nat_gateway_name" {
  type    = string
  default = "nj-courts-natgw"
}

variable "gwlb_name" {
  type    = string
  default = "nj-courts-security-gwlb"
}

variable "gwlb_endpoint_set_eastwest_name" {
  type        = string
  default     = "nj-courts-gwlb-out-endpoint"
  description = ""
}

variable "gwlb_endpoint_set_outbound_name" {
  type        = string
  default     = "nj-courts-gwlb-ew-endpoint"
  description = ""
}

/*
variable "gwlb_endpoint_set_panorama_name" {
  default = "panorama-gwlb-endpoint"
  type    = string
}
*/

variable "ssh_key_name" {
  description = "name of pub SSH key, manual add to ec2 console"
  type        = string
  default     = "Network-Security"
}

variable "vpc_secondary_cidr_blocks" {
  default = []
}

variable "security_groups" {
  default = {}
  type    = map(string)
}

variable "existing_gwlb_name" {
  type    = string
  default = "nj-courts-security-gwlb"
}

variable "create_tgw" {
  type    = string
  default = true
}

// ***** Network-Team-Sandbox *** 

variable "app1_vpc_name" {
  type    = string
  default = "NetworkTeam-Sandbox-Test-VPC" // the igw will have this name plus "-igw" and it's own RT
}

variable "app1_vpc_cidr" {
  type    = string
  default = "10.243.148.0/23" // changes subnets if you changes this
}

variable "app1_vpc_security_groups" {
  description = "these are set in terraform.tfvars"
  default = {

  }
}

variable "app1_vpc_subnets" {
  description = "these are set in terraform.tfvars"
}

variable "app1_transit_gateway_attachment_name" {
  type    = string
  default = "NetworkTeam-Sandbox-Test-VPC-TGW-Attach"
}

variable "gwlb_endpoint_set_app1_name" {
  type    = string
  default = "NetworkTeam-Sandbox-Test-VPC-gwlb-endpoint"
}
