variable "region" {
  default = "ca-central-1"
  type    = string
}

variable "name_prefix" {
  type    = string
  default = "lab-franklin"
}

variable "tags" {
  description = "Map of tags to be associated with the virtual machines, their interfaces and public IP addresses."
  default = {
    lab = "franklin"
  }
  type = map(string)
}

/*
variable "vpc_bucket" {
  description = "Name of the bucket where vpc state is stored"
  default     = "lab-franklin-tfstate"
  type        = string
}

variable "vpc_state_key" {
  description = "Key where the state file of the VPC is stored"
  default     = "lab-franklin-tfstate-key"
  type        = string
}

variable "vpc_state_region" {
  description = "Region where the state file of the VPC is stored"
  default     = "ca-central-1"
  type        = string
}
*/

variable "aws_security_group_cidr_blocks" {
  description = "List of CIDR to allow SSH from"
  type        = list(any)
  default     = ["68.38.137.81/32", "34.134.31.136/32", "34.136.90.64/32"]
}

variable "aws_security_group_jump_tags" {
  description = "Set of tags to be added to the jump SG"
  type        = map(string)
  default     = {}
}

variable "aws_instance_instance_type" {
  description = "The type of instance to start. Updates to this field will trigger a stop/start of the EC2 instance"
  default     = "t2.nano"
}

# https://wiki.debian.org/Cloud/AmazonEC2Image/Bullseye
variable "aws_instance_ami" {
  description = "The AMI to use for the instance, must match region above"
  default     = "ami-08413dce74940e624"
}

variable "aws_instance_key_name" {
  description = "The key name of the Key Pair to use for the instance"
  default     = "lab-franklin"
}

variable "aws_instance_volume_size" {
  description = "The size of the volume in gibibytes (GiB)"
  type        = string
  default     = "30"
}
