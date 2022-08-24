/*
    ****************************************************************
    Externally-Facing Regional TCP/UDP Network Load Balancer on GCP

    Creates a TCP Network Load Balancer for
    regional load balancing across a managed instance group. You provide a
    reference to a managed instance group and the module adds it to a target
    pool. A regional forwarding rule is created to forward traffic to healthy
    instances in the target pool.

    
    * A regional LB, which is faster than a global one.
    * IPv4 only, a limitation imposed by GCP.
    * The External TCP/UDP NLB has additional limitations imposed by GCP 
      compared to the Internal TCP/UDP NLB, namely:

        * Despite it works for any TCP traffic (also UDP and other protocols), 
          it can only use a plain HTTP health check. So, HTTPS or SSH probes are not possible.
        * Can only use the nic0 (the base interface) of an instance.
        * Cannot serve as a next hop in a GCP custom routing table entry.
    ****************************************************************
*/


/*
resource "google_compute_address" "this" {
  for_each = { for k, v in var.rules : k => v if !can(v.ip_address) }

  name         = each.key
  address_type = "EXTERNAL"
  region       = var.region
  project      = var.project
}
*/

/* 
    Google uses forwarding rules instead of routing instances. These forwarding rules
    are combined with backend services, target pools, URL maps and target proxies to
    construct a functional load balancer across multiple regions and instance groups.
*/


/*
*/
###########################
## GCP Windows VM - Main ##
###########################

# Terraform plugin for creating random ids
resource "random_id" "instance_id" {
  byte_length = 4
}

# Bootstrapping Script
data "template_file" "windows-metadata" {
  template = <<EOF
# Install IIS
Install-WindowsFeature -name Web-Server -IncludeManagementTools;
EOF
}



# ---------------------------------------------------------------------------------------------------------------------
# CREATE A FIREWALL RULE TO ALLOW TRAFFIC FROM ALL ADDRESSES
# ---------------------------------------------------------------------------------------------------------------------

/*
resource "google_compute_firewall" "firewall" {
  project = var.project
  name    = "${var.name}-fw"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["5000"]
  }

  # These IP ranges are required for health checks
  source_ranges = ["0.0.0.0/0"]

  # Target tags define the instances to which the rule applies
  target_tags = [var.name]
}
*/
