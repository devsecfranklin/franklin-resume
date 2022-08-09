variable "name" {
  description = "Name to add to our resources"
  type        = string
  default     = "franklin-lab"
}

variable "name_prefix" {
  type    = string
  default = "lab-franklin-"
}

/* *********************** AZURE ********************** */

variable "resource_group_name" {
  description = "Name of the Azure Resource Group to use for lab elements"
  default     = "franklin-lab"
  type        = string
}

variable "location" {
  description = "Location of the Azure resources that will be deployed."
  default     = "East US"
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

/* ******************** GCP CLOUD ********************** */

variable "project_id" {
  description = "The project indicates the default GCP project ID."
  type        = string
  default     = "gcp-gcs-pso"
}

variable "region" {
  description = "The region will be used to choose the default location for regional resources. Regional resources are spread across several zones."
  type        = string
  default     = "us-central1"
}

/* ******************** AWS CLOUD ********************** */
variable "aws_region" {
  default = "us-west-1"
  type    = string
}

variable "s3_bucket_name" {
  type    = string
  default = "lab-franklin"
}

variable "s3_acl_value" {
  default = "private"
  type    = string
}
