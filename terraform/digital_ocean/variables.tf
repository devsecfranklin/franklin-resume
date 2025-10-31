// Vars
variable "do_token" {
  default     = ""
  type        = string
  sensitive   = true
  description = "variable do_token: Tells Terraform to seek your DigitalOcean API token upon deployment so it can access your DigitalOcean account and deploy resources via the API."
}

variable "pvt_key" {
  default     = ""
  type        = string
  description = "variable pvt_key: Tells Terraform to seek the path to your private SSH key on your local machine upon deployment so it can access the Droplets you deploy."
}

variable "region" {
  default = "sfo3"
  type    = string
}