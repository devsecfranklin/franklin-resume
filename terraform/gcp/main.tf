data "google_compute_zones" "this" {}

variable "allowed_sources" {
  default = ["0.0.0.0/0"]
}

// gcloud compute images list --no-standard-images --uri --project=paloaltonetworksgcp-public
variable "image_uri" {
  default = null
}

module "vpc" {
  source = "./modules/vpc"

  networks = [
    {
      name            = "ti-ai-outside"
      subnetwork_name = "ti-ai-outside"
      ip_cidr_range   = "10.245.252.0/24"
      allowed_sources = var.allowed_sources
    },
    {
      name            = "ti-ai-mgt"
      subnetwork_name = "ti-ai-mgt"
      ip_cidr_range   = "10.245.255.0/24"
      allowed_sources = var.allowed_sources
    },
    {
      name            = "ti-ai-sandbox"
      subnetwork_name = "ti-ai-sandbox"
      ip_cidr_range   = "10.245.3.0/24"
    },
    {
      name            = "ti-ai-dmz"
      subnetwork_name = "ti-ai-dmz"
      ip_cidr_range   = "10.245.5.0/24"
    },
  ]
}

# Spawn the VM-series firewall as a Google Cloud Engine Instance.
module "vmseries" {
  source = "./modules/vmseries"

  create_instance_group = true

  instances = {
    "ti-ai-fw01" = {
      name = "ti-ai-fw-01"
      zone = var.zone # data.google_compute_zones.this.names[2]

      network_interfaces = [
        {
          subnetwork = module.vpc.subnetworks["ti-ai-outside"].self_link
          public_nat = true
        },
        {
          subnetwork = module.vpc.subnetworks["ti-ai-mgt"].self_link
          public_nat = true
        },
        {
          subnetwork = module.vpc.subnetworks["ti-ai-dmz"].self_link
          public_nat = true
        },
        {
          subnetwork = module.vpc.subnetworks["ti-ai-sandbox"].self_link
          public_nat = false
        },
      ]
    }
    "ti-ai-fw02" = {
      name = "ti-ai-fw-02"
      zone = var.zone # data.google_compute_zones.this.names[2]

      network_interfaces = [
        {
          subnetwork = module.vpc.subnetworks["ti-ai-outside"].self_link
          public_nat = true
        },
        {
          subnetwork = module.vpc.subnetworks["ti-ai-mgt"].self_link
          public_nat = true
        },
        {
          subnetwork = module.vpc.subnetworks["ti-ai-dmz"].self_link
          public_nat = true
        },
        {
          subnetwork = module.vpc.subnetworks["ti-ai-sandbox"].self_link
          public_nat = false
        },
      ]
    }
  }
  ssh_key = "admin:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCu+5vKjTtTWZwlDlm7AlmQdWKujHq7cWnoeJZa/sUGNj+rg8d+SfJZCF+cSuOEFxqJ6wVbX5WSAvB0MNETtncVsC6NvKNSGFsc8vIrIas5cQtyk8frp6SA9aJ/M90p2ekYwPVhqshGCLiRZ1enbm+8uvpGZkWW/g7eQV8HbxFnFCsdf9JZzHcnXWOD8tkRO9r/uuIX31BmVxEG2YE8IPC3Xq18hGglLsi0vOGdBicfOGGc/DRsw6wxXSjXF66nJAxmKZgg4lWzNIe8MkEJthI9cWPsTWcJC3XPpRuKQY6crofZa+atwkymhYJ/MUIJW4172cWLpbA1+4dvSFKSUpyo/Qs+0Zpft8vVvceaDhOsNCpzKk/qINZ3Z+Q/B4I9Ribw83K3FwfAlr6t35Z4j7cCw3VrlJtyVHrwUnVwkCNuw2zcWISfXSnCCFyVgxiJltnqk6CBOUfk6P3qIXqvQqQqp3cB1SiimVtSN5bzITiNnAdySnOUYJIsmMxkPH0Qua8cOQNNs2Ns9zAjgilTZtzG0siJtWmHJrg8+3jMG5mwzOvIgT3DadAx5ao1/+8ak4gBfoqSrLSJXPwW8Myl/I3/uxVkbxb4+jjJwnxKsbGS5LnfVGSvqEFXgtGYfNz79emdIWf3Tbh6Lv9+3Rrt9maCPg3/i5QtWBpaflI2RxurbQ== fdiaz@paloaltonetworks.com"

  image_uri = var.image_uri
}
