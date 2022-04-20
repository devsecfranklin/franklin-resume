terraform {
  required_version = ">=0.13, <2.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 4.69.0"
    }
  }
}

/*
provider "oci" {
  tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaanlsdir6d4"
  user_ocid        = "ocid1.user.oc1..aaaaaaaaie5sdq"
  private_key_path = "/home/franklin/.oci/oci_api_key.pem"
  fingerprint      = "4c:9f:81:ab:e5:77:c4asdfsadfasdfasdfsd"
  region           = "us-ashburn-1"          
}
*/
