terraform {
  required_version = ">= 0.13, < 2.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 4.69.0"
    }
  }
}
