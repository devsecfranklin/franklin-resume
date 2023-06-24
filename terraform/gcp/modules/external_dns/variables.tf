
variable "cluster_id" {}
variable "external_dns_enabled" {
  type    = bool
  default = true
}

variable "external_dns_id" {}
variable "external_dns_project" {}
variable "external_dns_chart_version" {}
variable "external_dns_namespace" {
  type    = string
  default = "external-dns"
}

variable "cloudflare_email" {}
variable "cloudflare_api_key" {}
variable "domain" {}
variable "kubernetes_namespace" {}
