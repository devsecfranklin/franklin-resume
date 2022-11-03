variable "region" {
  description = "The region will be used to choose the default location for regional resources. Regional resources are spread across several zones."
  type        = string
}

variable "zone" {
  description = "The zone will be used to choose the default location for zonal resources. Zonal resources exist in a single zone."
}

variable "project_id" {
  description = "The project indicates the default GCP project ID"
  type        = string
}

variable "name" {
  description = "Name to add to our resources"
  type        = string
}

/*
variable "secondary_ip_range" {
  // See https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips
  description = "The CIDR from which to allocate pod IPs for IP Aliasing."
  type        = string
}

variable "secondary_subnet_name" {
  // See https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips
  description = "The name to give the secondary subnet."
  type        = string
}

variable "gke_username" {
  default     = ""
  type        = string
  description = "gke username (disable basic auth by setting null username/password)"
}

variable "gke_password" {
  default     = ""
  type        = string
  description = "gke password (disable basic auth by setting null username/password)"
}

variable "gke_num_nodes" {
  description = "number of gke nodes"
  default = 3
  type = number
}

variable "node_machine_type" {
  description = "The instance to use for your node instances"
  type        = string
  default     = "n1-standard-4"
}

variable "service_account_terraform" {
  description = "https://tfsec.dev/docs/google/GCP012/"
  type        = string
  default     = ""
}
*/
