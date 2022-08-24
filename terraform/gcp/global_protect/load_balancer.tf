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

    To define a Load Balancer in GCP there’s a number of concepts that fit
    together: 
        1. Front-end config
        2. Backend Services (or Backend Buckets)
        3. Instance Groups
        4. Health Checks
        5. Firewall config

*/

/* 
    Google uses forwarding rules instead of routing instances. These forwarding rules
    are combined with backend services, target pools, URL maps and target proxies to
    construct a functional load balancer across multiple regions and instance groups.
*/


