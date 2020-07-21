variable "image" {
  description = "Name of the docker image to deploy."
  default     = "gcr.io/project_name/service_name"
}

variable "digest" {
  description = "The docker image digest to deploy."
  default     = "latest"
}
