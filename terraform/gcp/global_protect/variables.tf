variable "project_id" {
  description = "The project indicates the default GCP project ID"
  type        = string
  default     = "gcp-gcs-pso"
}

variable "vpc_name" {
  default = "lab-franklin-gp-client-vpc"
  type    = string
}

variable "region" {
  description = "The region will be used to choose the default location for regional resources. Regional resources are spread across several zones."
  type        = string
  default     = "us-east1"
}

variable "gcp_zone" {
  default = "us-east1-b"
  type    = string
}

variable "ssh_keys" {
  type = string
}

variable "windows_2012_r2_sku" {
  type        = string
  description = "SKU for Windows Server 2012 R2"
  default     = "windows-cloud/windows-2012-r2"
}

variable "windows_2016_sku" {
  type        = string
  description = "SKU for Windows Server 2016"
  default     = "windows-cloud/windows-2016"
}

variable "windows_2019_sku" {
  type        = string
  description = "SKU for Windows Server 2019"
  default     = "windows-cloud/windows-2019"
}

variable "windows_2022_sku" {
  type        = string
  description = "SKU for Windows Server 2022"
  default     = "windows-cloud/windows-2022"
}

variable "windows_instance_type" {
  type        = string
  description = "VM instance type for Windows Server"
  default     = "n2-standard-2"
}
