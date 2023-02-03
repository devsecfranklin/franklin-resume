host_project_id = "gcp-gcs-pso" // remove after testing

service_projects_ids = {
  service1 = "pgvpc-h-b2b-prd-us-01"
}

# PUBLIC key needs to be added here
ssh_keys = "admin:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCu+5vKjTtTWZwlDlm7AlmQdWKujHq7cWnoeJZa/sUGNj+rg8d+SfJZCF+cSuOEFxqJ6wVbX5WSAvB0MNETtncVsC6NvKNSGFsc8vIrIas5cQtyk8frp6SA9aJ/M90p2ekYwPVhqshGCLiRZ1enbm+8uvpGZkWW/g7eQV8HbxFnFCsdf9JZzHcnXWOD8tkRO9r/uuIX31BmVxEG2YE8IPC3Xq18hGglLsi0vOGdBicfOGGc/DRsw6wxXSjXF66nJAxmKZgg4lWzNIe8MkEJthI9cWPsTWcJC3XPpRuKQY6crofZa+atwkymhYJ/MUIJW4172cWLpbA1+4dvSFKSUpyo/Qs+0Zpft8vVvceaDhOsNCpzKk/qINZ3Z+Q/B4I9Ribw83K3FwfAlr6t35Z4j7cCw3VrlJtyVHrwUnVwkCNuw2zcWISfXSnCCFyVgxiJltnqk6CBOUfk6P3qIXqvQqQqp3cB1SiimVtSN5bzITiNnAdySnOUYJIsmMxkPH0Qua8cOQNNs2Ns9zAjgilTZtzG0siJtWmHJrg8+3jMG5mwzOvIgT3DadAx5ao1/+8ak4gBfoqSrLSJXPwW8Myl/I3/uxVkbxb4+jjJwnxKsbGS5LnfVGSvqEFXgtGYfNz79emdIWf3Tbh6Lv9+3Rrt9maCPg3/i5QtWBpaflI2RxurbQ== fdiaz@paloaltonetworks.com"

vmseries_common = {
  vmseries_image = "vmseries-flex-byol-1015h1"
  bootstrap_options = {
    mgmt-interface-swap         = "enable"
    type                        = "dhcp-client"
    dhcp-accept-server-hostname = "yes"
    dhcp-accept-server-domain   = "yes"
    panorama-server             = "34.134.31.136" # this is Franklin lab Panorama
    panorama-server-2           = "10.255.0.3"
    vm-auth-key                 = "249960450218671"
  }
  metadata = {
    block-projectssh-keys = "true"
    serial-port-enable    = "true"
  }
  tags = ["vmseries"]
}
vmseries_common_inbound = {
  bootstrap_options = {
    tplname = "vmseries-inbound"
    dgname  = "vmseries-inbound"
  }
  tags = ["vmseries-inbound"]
}
vmseries_common_outbound = {
  bootstrap_options = {
    tplname = "vmseries-outbound"
    dgname  = "vmseries-outbound"
  }
  tags = ["vmseries-outbound"]
}

vmseries = {
  inbound = {
    fw01 = {
      name = "fw01"
      zone = "us-east1-b"
      private_ips = {
        mgmt    = "10.250.0.3"
        public  = "10.250.0.19"
        private = "10.250.0.35"
      }
    }
    fw02 = {
      name = "fw02"
      zone = "us-east1-c"
      private_ips = {
        mgmt    = "10.250.0.4"
        public  = "10.250.0.20"
        private = "10.250.0.36"
      }
    }
  }
  outbound = {
    fw03 = {
      name = "fw03"
      zone = "us-east1-b"
      private_ips = {
        mgmt    = "10.250.0.10"
        public  = "10.250.0.26"
        private = "10.250.0.42"
      }
    }
    fw04 = {
      name = "fw04"
      zone = "us-east1-c"
      private_ips = {
        mgmt    = "10.250.0.11"
        public  = "10.250.0.27"
        private = "10.250.0.43"
      }
    }
  }
}


allowed_sources = []
# These are for GCP healthchecks: "35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22", "169.254.169.254/32"

allowed_sources_mgmt     = []
allowed_sources_panorama = ["68.38.137.81/32"]
extlb_name               = "elb"
