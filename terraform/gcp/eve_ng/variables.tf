variable "region" {
  description = "The region will be used to choose the default location for regional resources. Regional resources are spread across several zones."
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The zone will be used to choose the default location for zonal resources. Zonal resources exist in a single zone."
  type        = string
  default     = "us-central1-a"
}

variable "project_id" {
  description = "The project indicates the default GCP project ID"
  type        = string
  default     = "gcp-gcs-pso"
}
