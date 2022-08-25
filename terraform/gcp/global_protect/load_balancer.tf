/*
    ****************************************************************
    Externally-Facing Regional TCP/UDP Network Load Balancer on GCP

    Creates a TCP Network Load Balancer for regional load balancing
    across a managed instance group. You provide a reference to a
    managed instance group and the module adds it to a target pool.
    A regional forwarding rule is created to forward traffic to healthy
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
    To define a Load Balancer in GCP there’s a number of concepts that fit
    together: 
        1. Front-end config
        2. Backend Services (or Backend Buckets)
        3. Instance Groups
        4. Health Checks
        5. Firewall config
    ****************************************************************
*/

resource "google_compute_http_health_check" "lab-franklin-gp-health-check" {
  //count = var.create_health_check && local.target_pool_needed ? 1 : 0

  name                = "lab-franklin-gp-health-check"
  check_interval_sec  = var.health_check_interval_sec
  healthy_threshold   = var.health_check_healthy_threshold
  timeout_sec         = var.health_check_timeout_sec
  unhealthy_threshold = var.health_check_unhealthy_threshold
  port                = var.health_check_http_port
  request_path        = var.health_check_http_request_path
  host                = var.health_check_http_host
  project             = var.project_id
}
