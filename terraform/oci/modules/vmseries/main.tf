resource "oci_core_instance" "this" {
  compartment_id = var.compartment

  availability_domain  = var.availability_domain
  display_name         = var.name
  shape                = var.shape
  freeform_tags        = var.tags
  preserve_boot_volume = var.preserve_boot_volume

  // This item seems to be required, but we can define only single interface inside oci_core_instance
  create_vnic_details {
    subnet_id                 = var.interfaces[0].subnet_id
    display_name              = var.interfaces[0].name
    private_ip                = try(var.interfaces[0].private_ip, null)
    assign_public_ip          = try(var.interfaces[0].assign_public_ip, false)
    assign_private_dns_record = try(var.interfaces[0].assign_private_dns_record, false)
    skip_source_dest_check    = try(var.interfaces[0].skip_source_dest_check, false)
    nsg_ids                   = try(var.interfaces[0].nsg_ids, [])
    freeform_tags             = var.tags
  }

  source_details {
    source_type             = "image"
    source_id               = coalesce(var.img_id, data.oci_marketplace_listing_package.this.image_id)
    boot_volume_size_in_gbs = var.boot_volume_size
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
    user_data           = base64encode(file("./files/init-cfg.txt"))
  }

  timeouts {
    create = var.create_timeout
  }
}
