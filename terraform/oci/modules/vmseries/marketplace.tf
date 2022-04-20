// We probably need to improve this part of the code, but I do not have a good solution now

data "oci_marketplace_listings" "this" {
  name = ["Palo Alto Networks"]
}

locals {
  listing_id = [for i in data.oci_marketplace_listings.this.listings : i if i.name == "Palo Alto Networks VM-Series Next Generation Firewall"][0].id
}

data "oci_marketplace_listing_package" "this" {
  listing_id      = local.listing_id
  package_version = var.img_version
  compartment_id  = var.compartment
}
