variable "name" {
  description = "Name to add to our resources"
  type        = string
  default     = "franklin-lab"
}

variable "name_prefix" {
  type    = string
  default = "lab-franklin"
}

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
