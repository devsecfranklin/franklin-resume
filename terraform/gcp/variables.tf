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

variable "zone" {
  description = "The zone will be used to choose the default location for zonal resources. Zonal resources exist in a single zone."
  default     = "us-central1-a"
}

variable "tags" {
  description = "Map of tags to be associated with the virtual machines, their interfaces and public IP addresses."
  type        = list(any)
  default     = ["lab", "franklin", "ssh", "http-server", "https-server"]
}

# curl ifconfig.me to get the public IP
variable "access_list" {
  type = list(any)
  default = [
    "3.233.53.199", # AWS bh51pafwinb01p-mgmt1
    "8.44.144.96",  # viktor
    "10.0.0.0/8",
    "24.8.186.84",      # Home network
    "34.27.202.221",    # GCP fw 1
    "34.134.31.136/32", # GCP panorama one
    "34.136.90.64/32",  # GCP panorama two
    "34.206.152.182",   # AWS bh52pafwoew01p-mgmt1
    "35.222.82.220/32", # GCP lab-franklin-airlock1
    "44.216.25.244",    # AWS bh51pafwinb02p-mgmt1
    "52.55.185.160",    # AWS bh52pafwoew02p-mgmt1)
    "134.238.141.178",  # corp network
    "134.238.141.180",  # corp network
    "134.238.163.160",  # corp network
    "174.16.149.41",    # viktor
    "192.168.0.0/24",    # old mgmt network
    "8.44.144.96",      # viktor
    "165.85.137.128"    #corp network
  ]
}

variable "service_account_terraform" {
  description = "https://tfsec.dev/docs/google/GCP012/"
  type        = string
  default     = "fdiaz-gke-bot@gcp-gcs-pso.iam.gserviceaccount.com"
}

# gcloud compute images list --filter debian-cloud
# The “PROJECT” and “FAMILY” columns are the two we need to combine to create the image name.
variable "debian_11_sku" {
  type        = string
  description = "SKU for Debian 11"
  default     = "debian-cloud/debian-11"
}

variable "linux_instance_type" {
  type        = string
  description = "VM instance type for Linux Server"
  default     = "e2-standard-4"
}

// ***************************** OPENSHIFT
variable "openshift-region" {
  description = "The region will be used to choose the default location for regional resources. Regional resources are spread across several zones."
  type        = string
  default     = "australia-southeast2"
}

variable "openshift-zone" {
  description = "The zone will be used to choose the default location for zonal resources. Zonal resources exist in a single zone."
  default     = "australia-southeast2-a"
}

variable "ubuntu_2004_sku" {
  description = "SKU for Ubuntu 20.04 LTS"
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2004-lts"
}

variable "ssh_key" {
  description = "Add the key so you can SSH into VM series and set the admin pass on initial bring up."
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCu+5vKjTtTWZwlDlm7AlmQdWKujHq7cWnoeJZa/sUGNj+rg8d+SfJZCF+cSuOEFxqJ6wVbX5WSAvB0MNETtncVsC6NvKNSGFsc8vIrIas5cQtyk8frp6SA9aJ/M90p2ekYwPVhqshGCLiRZ1enbm+8uvpGZkWW/g7eQV8HbxFnFCsdf9JZzHcnXWOD8tkRO9r/uuIX31BmVxEG2YE8IPC3Xq18hGglLsi0vOGdBicfOGGc/DRsw6wxXSjXF66nJAxmKZgg4lWzNIe8MkEJthI9cWPsTWcJC3XPpRuKQY6crofZa+atwkymhYJ/MUIJW4172cWLpbA1+4dvSFKSUpyo/Qs+0Zpft8vVvceaDhOsNCpzKk/qINZ3Z+Q/B4I9Ribw83K3FwfAlr6t35Z4j7cCw3VrlJtyVHrwUnVwkCNuw2zcWISfXSnCCFyVgxiJltnqk6CBOUfk6P3qIXqvQqQqp3cB1SiimVtSN5bzITiNnAdySnOUYJIsmMxkPH0Qua8cOQNNs2Ns9zAjgilTZtzG0siJtWmHJrg8+3jMG5mwzOvIgT3DadAx5ao1/+8ak4gBfoqSrLSJXPwW8Myl/I3/uxVkbxb4+jjJwnxKsbGS5LnfVGSvqEFXgtGYfNz79emdIWf3Tbh6Lv9+3Rrt9maCPg3/i5QtWBpaflI2RxurbQ=="
}

variable "use_preemtible_nodes" {
  description = "Should the nodes in the pool be pre-emptible"
  type        = bool
  default     = false
}

variable "machine_type" {
  type    = string
  default = "e2-medium"
}

variable "cluster_name" {
  type    = string
  default = "lab-franklin-gke"
}

// ***************************** CTFd

variable "root_domain" {
  type    = string
  default = "dead10c5.org"
}

variable "cert_manager_enabled" {
  type    = bool
  default = false
}

variable "cloudflare_api_token" {
  type    = string
  default = "O1vhChy2fZ6cUPy-ZnXQgo5fYdxLFfPHQEH9GBBv"
}

variable "cloudflare_email" {
  type    = string
  default = "ctfd@dead10c5.org"
}

variable "grafana_password" {
  type    = string
  default = "1234"
}

variable "prometheus_blackbox_enabled" {
  type    = bool
  default = false
}

variable "prometheus_blackbox_targets" {
  default = "1234"
}
