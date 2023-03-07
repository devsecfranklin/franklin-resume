variable "name" {
  description = "Name to add to our resources"
  type        = string
  default     = "lab-franklin"
}

variable "tags" {
  description = "Map of tags to be associated with the virtual machines, their interfaces and public IP addresses."
  default     = {}
  type        = map(string)
}

// *********************** AZURE
variable "az_location" {
  description = "The Azure region to use."
  default     = "West US"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Resource Group to create. If not provided, it will be auto-generated."
  default     = "lab-franklin"
  type        = string
}

// *********************** GOOGLE
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
