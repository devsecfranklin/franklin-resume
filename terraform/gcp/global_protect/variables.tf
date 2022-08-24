variable "project_id" {
  description = "The project indicates the default GCP project ID"
  type        = string
  default     = "gcp-gcs-pso"
}

variable "region" {
  description = "The region will be used to choose the default location for regional resources. Regional resources are spread across several zones."
  type        = string
  default     = "us-east1"
}

variable "ssh_keys" {
  type = string
}
