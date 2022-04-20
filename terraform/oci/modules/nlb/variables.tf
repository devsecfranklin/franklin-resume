variable "compartment" {
  description = "The OCID of the compartment in which to create the load balancer resources."
  type        = string
}

variable "name" {
  description = "The name of the LoadBalancer to create."
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to all of the created resources."
  type        = map(any)
  default     = {}
}

variable "subnet_id" {
  description = ""
  type        = string
}

variable "private" {
  description = "Whether the load balancer has a VCN-local (private) IP address. Please note, that You cannot specify a private subnet for your public load balancer."
  type        = bool
  //default     = true // I'm not sure if we want to use default here?
}

variable "is_preserve_source_destination" {
  description = "This parameter can be enabled only if backends are compute OCIDs. When enabled, the skipSourceDestinationCheck parameter is automatically enabled on the load balancer VNIC, and packets are sent to the backend with the entire IP header intact."
  type        = bool
  default     = false
}

variable "policy" {
  description = "The network load balancer policy for the backend set."
  type        = string
  default     = "FIVE_TUPLE"
}

variable "listeners" {
  description = <<-EOF
  A map of listeners to deploy.

  Example:
  ```
  {
    SSH = {
      port     = 22
      protocol = "TCP"
    }
    HTTP = {
      port     = 80
      protocol = "TCP"
    }
  }
  ```
  EOF
  type        = map(any)
}

variable "reserved_ips" {
  description = <<-EOF
  An array of reserved IPs.
  !!! Only one reserved IP is supported per Network Load Balancer at the moment !!!
  Example:
  ```
  {
    reserved_ip = {
      id = oci_core_public_ip.this.id
    }
  }
  ```
  EOF
  type        = map(any)
  default     = {}
}

# Health Checks
variable "health_checker_protocol" {
  description = "The protocol the health check will use. Possible values: HTTP or TCP."
  type        = string
  default     = "TCP"
}

variable "health_checker_port" {
  description = "The backend server port against which to run the health check."
  type        = number
  default     = 80
}

variable "health_checker_interval" {
  description = "The interval between health checks, in milliseconds."
  type        = number
  default     = 10000
}
