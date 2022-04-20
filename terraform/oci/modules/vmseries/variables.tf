variable "compartment" {
  description = "The OCID of the compartment where the instance will be created."
  type        = string
}

variable "name" {
  description = "Hostname of the VM-Series virtual machine and its virtual NICs."
  type        = string
}

variable "shape" {
  description = "The shape of the instance. The shape determines the number of CPUs and the amount of memory allocated to the instance."
  type        = string
  default     = "VM.Standard2.4"
}

variable "availability_domain" {
  description = "The availability domain of the instance."
  type        = string
}

variable "ssh_authorized_keys" {
  description = "Public SSH keys for the default user on the instance."
  type        = string
}

variable "boot_volume_size" {
  description = "Boot volume size in GB."
  type        = number
  default     = 60
}

variable "tags" {
  description = "A mapping of tags to assign to all of the created resources."
  type        = map(string)
  default     = {}
}

variable "preserve_boot_volume" {
  description = "Whether to preserve the boot volume that was used to launch the preemptible instance when the instance is terminated."
  type        = bool
  default     = false
}

variable "interfaces" {
  description = <<-EOF
  List of the network interface specifications.
  The first item should be the Management network interface, which does not participate in data filtering.
  The remaining ones are the dataplane interfaces.

  Example:
  ```
  [
    {
      name             = "fw01-mgmt"
      subnet_id        = module.vcn.subnet_ids["management"]
      assign_public_ip = false
    },
    {
      name             = "fw01-public"
      subnet_id        = module.vcn.subnet_ids["public"]
      assign_public_ip = true
    },
    {
      name                   = "fw01-trusted"
      subnet_id              = module.vcn.subnet_ids["trusted"]
      assign_public_ip       = false
      private_ip             = "10.11.12.13"
      skip_source_dest_check = true
    }
  ]
  ```  
  EOF
  type        = list(any)
  validation {
    condition     = length(var.interfaces) <= 6
    error_message = "The current maximum is 6 interfaces."
  }
}

variable "img_id" {
  description = ""
  type        = string
  default     = null
}

variable "img_version" {
  description = "VM-series PAN-OS version."
  type        = string
  default     = "9.1.6"
}

variable "create_timeout" {
  description = "Timeout for creating oci_core_instance resource."
  type        = string
  default     = "60m"
}
