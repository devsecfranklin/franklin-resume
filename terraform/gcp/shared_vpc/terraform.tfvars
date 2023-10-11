vmseries_common_ingress = {
  bootstrap_options = {
    tplname = "vmseries-inbound"
    dgname  = "vmseries-inbound"
  }
  tags = ["vmseries-inbound"]
}

vmseries_common_egress = {
  bootstrap_options = {
    tplname = "vmseries-outbound"
    dgname  = "vmseries-outbound"
  }
  tags = ["vmseries-outbound"]
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


allowed_sources_panorama = ["34.134.31.136/32", "34.136.90.64/32"]