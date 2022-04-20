# Warning: Additional VNICs are attached to VMSeries in random order
# and we cannot use a single block with:
#   for_each = { for i, v in var.interfaces : v.name => v if i != 0 }

resource "oci_core_vnic_attachment" "int1" {
  for_each     = { for i, v in var.interfaces : v.name => v if i == 1 }
  instance_id  = oci_core_instance.this.id
  display_name = "${var.name}-${each.key}"
  depends_on   = [oci_core_instance.this]

  create_vnic_details {
    subnet_id                 = each.value.subnet_id
    display_name              = each.key
    private_ip                = try(each.value.private_ip, null)
    assign_public_ip          = try(each.value.assign_public_ip, false)
    assign_private_dns_record = try(each.value.assign_private_dns_record, false)
    skip_source_dest_check    = try(each.value.skip_source_dest_check, true)
    nsg_ids                   = try(each.value.nsg_ids, [])
    freeform_tags             = var.tags
  }
}

resource "oci_core_vnic_attachment" "int2" {
  for_each     = { for i, v in var.interfaces : v.name => v if i == 2 }
  instance_id  = oci_core_instance.this.id
  display_name = "${var.name}-${each.key}"
  depends_on   = [oci_core_vnic_attachment.int1]

  create_vnic_details {
    subnet_id                 = each.value.subnet_id
    display_name              = each.key
    private_ip                = try(each.value.private_ip, null)
    assign_public_ip          = try(each.value.assign_public_ip, false)
    assign_private_dns_record = try(each.value.assign_private_dns_record, false)
    skip_source_dest_check    = try(each.value.skip_source_dest_check, true)
    nsg_ids                   = try(each.value.nsg_ids, [])
    freeform_tags             = var.tags
  }
}

resource "oci_core_vnic_attachment" "int3" {
  for_each     = { for i, v in var.interfaces : v.name => v if i == 3 }
  instance_id  = oci_core_instance.this.id
  display_name = "${var.name}-${each.key}"
  depends_on   = [oci_core_vnic_attachment.int2]

  create_vnic_details {
    subnet_id                 = each.value.subnet_id
    display_name              = each.key
    private_ip                = try(each.value.private_ip, null)
    assign_public_ip          = try(each.value.assign_public_ip, false)
    assign_private_dns_record = try(each.value.assign_private_dns_record, false)
    skip_source_dest_check    = try(each.value.skip_source_dest_check, true)
    nsg_ids                   = try(each.value.nsg_ids, [])
    freeform_tags             = var.tags
  }
}

resource "oci_core_vnic_attachment" "int4" {
  for_each     = { for i, v in var.interfaces : v.name => v if i == 4 }
  instance_id  = oci_core_instance.this.id
  display_name = "${var.name}-${each.key}"
  depends_on   = [oci_core_vnic_attachment.int3]

  create_vnic_details {
    subnet_id                 = each.value.subnet_id
    display_name              = each.key
    private_ip                = try(each.value.private_ip, null)
    assign_public_ip          = try(each.value.assign_public_ip, false)
    assign_private_dns_record = try(each.value.assign_private_dns_record, false)
    skip_source_dest_check    = try(each.value.skip_source_dest_check, true)
    nsg_ids                   = try(each.value.nsg_ids, [])
    freeform_tags             = var.tags
  }
}

resource "oci_core_vnic_attachment" "int5" {
  for_each     = { for i, v in var.interfaces : v.name => v if i == 5 }
  instance_id  = oci_core_instance.this.id
  display_name = "${var.name}-${each.key}"
  depends_on   = [oci_core_vnic_attachment.int4]

  create_vnic_details {
    subnet_id                 = each.value.subnet_id
    display_name              = each.key
    private_ip                = try(each.value.private_ip, null)
    assign_public_ip          = try(each.value.assign_public_ip, false)
    assign_private_dns_record = try(each.value.assign_private_dns_record, false)
    skip_source_dest_check    = try(each.value.skip_source_dest_check, true)
    nsg_ids                   = try(each.value.nsg_ids, [])
    freeform_tags             = var.tags
  }
}
