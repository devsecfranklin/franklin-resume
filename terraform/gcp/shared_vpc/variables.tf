variable "host_project_id" {
  type    = string
  default = "gcp-gcs-pso"
}

variable "service_projects_ids" {
  type = map(any)
  default = {
    service1 = "pgvpc-h-b2b-prd-us-01"
  }
}

variable "region" {
  type    = string
  default = "us-east1"
}

variable "name_prefix" {
  type    = string
  default = "lab-franklin-"
}

variable "vmseries" {
  default = {
    ingress = {
      i-usea1-0001 = {
        name = "lab-franklin-ingress-fw1"
        zone = "us-east1-c"
        private_ips = {
          mgmt    = "10.252.0.3"
          ingress = "10.252.1.3"
          egress  = "10.252.2.3"
        }
      }
      i-usea1-0002 = {
        name = "lab-franklin-ingress-fw2"
        zone = "us-east1-b"
        private_ips = {
          mgmt    = "10.252.0.4"
          ingress = "10.252.1.4"
          egress  = "10.252.2.4"
        }
      }
    }
    egress = {
      e-usea1-0001 = {
        name = "lab-franklin-egress-fw1"
        zone = "us-east1-c"
        private_ips = {
          mgmt    = "10.252.0.10"
          ingress = "10.252.1.10"
          egress  = "10.252.2.10"
        }
      }
      e-usea1-0002 = {
        name = "lab-franklin-egress-fw2"
        zone = "us-east1-b"
        private_ips = {
          mgmt    = "10.252.0.11"
          ingress = "10.252.1.11"
          egress  = "10.252.2.11"
        }
      }
    }
  }
}

variable "vmseries_common" {
  default = {

    vmseries_image   = "vmseries-flex-byol-1015h1"
    min_cpu_platform = "Automatic"
    machine_type     = "n1-standard-8" # gcloud compute machine-types list | grep 'us-east1-b'
    bootstrap_options = {
      mgmt-interface-swap         = "enable"
      type                        = "dhcp-client"
      dhcp-accept-server-hostname = "yes"
      dhcp-accept-server-domain   = "yes"
      panorama-server             = "34.134.31.136" # this is Franklin lab Panorama
      panorama-server-2           = "34.136.90.64"
      vm-auth-key                 = "249960450218671"
    }
    metadata = {
      block-projectssh-keys = "true"
      serial-port-enable    = "true"
    }
    tags = ["vmseries"]
  }
}

variable "vmseries_common_ingress" {
  default = {
    min_cpu_platform = "Automatic"
    machine_type     = "n1-standard-8" # gcloud compute machine-types list | grep 'us-east1-b'
    bootstrap_options = {
      tplname = "vmseries-ingress"
      dgname  = "vmseries-ingress"
    }
    tags = ["vmseries-ingress"]
  }
}

variable "vmseries_common_egress" {
  default = {
    min_cpu_platform = "Automatic"
    machine_type     = "n1-standard-8" # gcloud compute machine-types list | grep 'us-east1-b'
    bootstrap_options = {
      tplname = "vmseries-egress"
      dgname  = "vmseries-egress"
    }
    tags = ["vmseries-egress"]
  }
}

variable "ssh_keys" {
  type    = string
  default = "admin:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCu+5vKjTtTWZwlDlm7AlmQdWKujHq7cWnoeJZa/sUGNj+rg8d+SfJZCF+cSuOEFxqJ6wVbX5WSAvB0MNETtncVsC6NvKNSGFsc8vIrIas5cQtyk8frp6SA9aJ/M90p2ekYwPVhqshGCLiRZ1enbm+8uvpGZkWW/g7eQV8HbxFnFCsdf9JZzHcnXWOD8tkRO9r/uuIX31BmVxEG2YE8IPC3Xq18hGglLsi0vOGdBicfOGGc/DRsw6wxXSjXF66nJAxmKZgg4lWzNIe8MkEJthI9cWPsTWcJC3XPpRuKQY6crofZa+atwkymhYJ/MUIJW4172cWLpbA1+4dvSFKSUpyo/Qs+0Zpft8vVvceaDhOsNCpzKk/qINZ3Z+Q/B4I9Ribw83K3FwfAlr6t35Z4j7cCw3VrlJtyVHrwUnVwkCNuw2zcWISfXSnCCFyVgxiJltnqk6CBOUfk6P3qIXqvQqQqp3cB1SiimVtSN5bzITiNnAdySnOUYJIsmMxkPH0Qua8cOQNNs2Ns9zAjgilTZtzG0siJtWmHJrg8+3jMG5mwzOvIgT3DadAx5ao1/+8ak4gBfoqSrLSJXPwW8Myl/I3/uxVkbxb4+jjJwnxKsbGS5LnfVGSvqEFXgtGYfNz79emdIWf3Tbh6Lv9+3Rrt9maCPg3/i5QtWBpaflI2RxurbQ== fdiaz@paloaltonetworks.com"
}

variable "extlb_name" {
  type    = string
  default = "elb"
}

variable "allowed_sources_ingress" {
  default = ["0.0.0.0/0"]
}
variable "allowed_sources_egress" {
  description = "These are for GCP healthchecks" # "35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22", "169.254.169.254/32"'
  default     = ["35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22", "169.254.169.254/32", "10.252.0.0/14"]
}

variable "allowed_sources_mgmt" {
  description = "whitelist the allowed mgmt IP's"
  default     = ["24.8.186.84/32"]
}
variable "allowed_sources_panorama" {

  default = ["34.134.31.136/32", "34.136.90.64/32"]
}

variable "ip_cidr_range_mgmt" {
  default = "10.252.0.0/24"
}

variable "ip_cidr_range_ingress" {
  default = "10.252.1.0/24"
}

variable "ip_cidr_range_egress" {
  default = "10.252.2.0/24"
}