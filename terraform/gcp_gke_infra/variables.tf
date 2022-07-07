variable "region" {
  description = "The region will be used to choose the default location for regional resources. Regional resources are spread across several zones."
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The zone will be used to choose the default location for zonal resources. Zonal resources exist in a single zone."
  type        = string
  default     = "us-central1-b"
}

variable "project_id" {
  description = "The project indicates the default GCP project ID"
  type        = string
  default     = "gcp-gcs-pso"
}

variable "name" {
  description = "Name to add to our resources"
  type        = string
  default     = "lab-franklin"
}

variable "prefix_name_tag" {
  description = "Prepend a string to Name tags for the created resources. Can be empty."
  default     = "franklin-"
  type        = string
}

variable "global_tags" {
  description = "Optional map of arbitrary tags to apply to all the created resources."
  default     = {}
  type        = map(string)
}

variable "vpc_tags" {
  description = "Optional map of arbitrary tags to apply to the created VPC resource, in addition to the `global_tags`."
  default     = {}
  type        = map(string)
}

variable "secondary_ip_range" {
  // See https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips
  description = "The CIDR from which to allocate pod IPs for IP Aliasing."
  type        = string
  default     = "10.0.92.0/22"
}

variable "secondary_subnet_name" {
  // See https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips
  description = "The name to give the secondary subnet."
  type        = string
  default     = "ps-devsecops-alpha-secondary-sub"
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
  default     = 2
  description = "number of gke nodes"
}

variable "node_machine_type" {
  description = "The instance to use for your node instances"
  type        = string
  default     = "n1-standard-4"
}

variable "service_account_terraform" {
  description = "https://tfsec.dev/docs/google/GCP012/"
  type        = string
  default     = "fdiaz-gke-bot@gcp-gcs-pso.iam.gserviceaccount.com"
}

