variable "region" {
  description = "The region will be used to choose the default location for regional resources. Regional resources are spread across several zones."
  type        = string
  default     = "australia-southeast2"
}

variable "zone" {
  description = "The zone will be used to choose the default location for zonal resources. Zonal resources exist in a single zone."
  default     = "australia-southeast2-a"
}

variable "project_id" {
  description = "The project indicates the default GCP project ID"
  type        = string
  default     = "gcp-gcs-pso"
}

variable "name" {
  description = "Name to add to our resources"
  type        = string
  default     = "lab-franklin-"
}