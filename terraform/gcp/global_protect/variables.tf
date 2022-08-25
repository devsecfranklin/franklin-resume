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

# Load balancer variables
variable "create_health_check" {
  description = "Whether to create a health check on the target pool."
  type        = bool
  default     = true
}

variable "health_check_interval_sec" {
  description = "Health check parameter, see [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check)"
  type        = number
  default     = null
}

variable "health_check_healthy_threshold" {
  description = "Health check parameter, see [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check)"
  type        = number
  default     = null
}

variable "health_check_timeout_sec" {
  description = "Health check parameter, see [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check)"
  type        = number
  default     = null
}

variable "health_check_unhealthy_threshold" {
  description = "Health check parameter, see [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check)"
  type        = number
  default     = null
}

variable "health_check_http_port" {
  description = "Health check parameter, see [provider doc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check)"
  type        = number
  default     = null
}

variable "health_check_http_request_path" {
  description = "Health check http request path, with the default adjusted to /php/login.php to be able to check the health of the PAN-OS webui."
  type        = string
  default     = "/php/login.php"
}

variable "health_check_http_host" {
  description = "Health check http request host header, with the default adjusted to localhost to be able to check the health of the PAN-OS webui."
  type        = string
  default     = "localhost"
}