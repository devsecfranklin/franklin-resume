host_project_id = "gcp-gcs-pso" // remove after testing

service_projects_ids = {
  service1 = "lpgcen-ppal-service1"
}

# PUBLIC key needs to be added here
ssh_keys = "admin:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCu+5vKjTtTWZwlDlm7AlmQdWKujHq7cWnoeJZa/sUGNj+rg8d+SfJZCF+cSuOEFxqJ6wVbX5WSAvB0MNETtncVsC6NvKNSGFsc8vIrIas5cQtyk8frp6SA9aJ/M90p2ekYwPVhqshGCLiRZ1enbm+8uvpGZkWW/g7eQV8HbxFnFCsdf9JZzHcnXWOD8tkRO9r/uuIX31BmVxEG2YE8IPC3Xq18hGglLsi0vOGdBicfOGGc/DRsw6wxXSjXF66nJAxmKZgg4lWzNIe8MkEJthI9cWPsTWcJC3XPpRuKQY6crofZa+atwkymhYJ/MUIJW4172cWLpbA1+4dvSFKSUpyo/Qs+0Zpft8vVvceaDhOsNCpzKk/qINZ3Z+Q/B4I9Ribw83K3FwfAlr6t35Z4j7cCw3VrlJtyVHrwUnVwkCNuw2zcWISfXSnCCFyVgxiJltnqk6CBOUfk6P3qIXqvQqQqp3cB1SiimVtSN5bzITiNnAdySnOUYJIsmMxkPH0Qua8cOQNNs2Ns9zAjgilTZtzG0siJtWmHJrg8+3jMG5mwzOvIgT3DadAx5ao1/+8ak4gBfoqSrLSJXPwW8Myl/I3/uxVkbxb4+jjJwnxKsbGS5LnfVGSvqEFXgtGYfNz79emdIWf3Tbh6Lv9+3Rrt9maCPg3/i5QtWBpaflI2RxurbQ== fdiaz@paloaltonetworks.com"

# Set the Subnets here (could resize down to a /28 for example)
ip_cidr_range_mgmt    = "10.252.0.0/24"
ip_cidr_range_ingress = "10.252.1.0/24"
ip_cidr_range_egress  = "10.252.2.0/24"

vmseries_common = {
  vmseries_image   = "vmseries-flex-byol-1015h1"
  min_cpu_platform = "Automatic"
  machine_type     = "n1-standard-8" # gcloud compute machine-types list | grep 'us-east1-b'
  bootstrap_options = {
    mgmt-interface-swap         = "enable"
    type                        = "dhcp-client"
    dhcp-accept-server-hostname = "yes"
    dhcp-accept-server-domain   = "yes"
    # panorama-server             = "172.16.24.220" # this is LP On-Prem Panorama
    panorama-server   = "34.134.31.136"   # this is Franklin lab Panorama
    panorama-server-2 = "34.136.90.64"    # this is Franklin lab Panorama
    vm-auth-key       = "249960450218671" # blank this one or next
    authcodes         = ""                # blank this one or previous 
  }
  metadata = {
    block-projectssh-keys = "true"
    serial-port-enable    = "true"
  }
  tags = ["vmseries"]
}

vmseries_common_ingress = {
  bootstrap_options = {
    tplname = "vmseries-ingress"
    dgname  = "vmseries-ingress"
  }
  tags = ["vmseries-ingress"]
}

vmseries_common_egress = {
  bootstrap_options = {
    tplname = "vmseries-egress"
    dgname  = "vmseries-egress"
  }
  tags = ["vmseries-egress"]
}

vmseries = {
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

# These are for GCP healthchecks: "35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22", "169.254.169.254/32"
# IAP 35.235.240.0/20
allowed_sources_egress = ["35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22", "169.254.169.254/32", "10.252.0.0/14"]

# Live Person
allowed_sources_ingress = ["0.0.0.0/0"]
# allowed_sources_mgmt     = ["10.0.0.0/8", "34.99.247.241/32"] #change me
# allowed_sources_panorama = ["172.16.24.220/32"]
#extlb_name               = "elb"

# Franklin Testing
# NOTE: cannot mix IPv4 and IPv6 in same sources set


allowed_sources_mgmt     = ["68.38.137.81/32"]
allowed_sources_panorama = ["34.134.31.136/32", "34.136.90.64/32"]
extlb_name               = "elb"
