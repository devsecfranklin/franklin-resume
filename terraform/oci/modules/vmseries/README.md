# Palo Alto Networks VMSeries module for Oracle Cloud Infrastructure

A Terraform module for deploying a VM-Series firewall in Oracle cloud. This module is not intended for use with autoscaling.

## Usage

```hcl
module "vmseries" {
  source = "../../modules/vmseries"

  compartment         = var.compartment
  name                = "some-name"
  availability_domain = "AzxO:US-ASHBURN-AD-2"
  ssh_authorized_keys = file("/home/user/.ssh/id_rsa.pub")
  shape               = "VM.Standard2.4"
  img_version         = "10.0.4"
  tags                = var.tags
  interfaces = [
    {
      name             = "fw01-mgmt"
      subnet_id        = module.vcn.subnet_ids["management"]
      assign_public_ip = true
    },
    {
      name             = "fw01-public"
      subnet_id        = module.vcn.subnet_ids["public"]
      assign_public_ip = true
    },
    {
      name      = "fw01-private"
      subnet_id = module.vcn.subnet_ids["private"]
    }
  ]
}

```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13, < 0.15 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | >= 4.23.0, <= 4.30.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | >= 4.23.0, <= 4.30.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_core_instance.this](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_instance) | resource |
| [oci_core_vnic_attachment.int1](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_vnic_attachment) | resource |
| [oci_core_vnic_attachment.int2](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_vnic_attachment) | resource |
| [oci_core_vnic_attachment.int3](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_vnic_attachment) | resource |
| [oci_core_vnic_attachment.int4](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_vnic_attachment) | resource |
| [oci_core_vnic_attachment.int5](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_vnic_attachment) | resource |
| [oci_marketplace_listing_package.this](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/marketplace_listing_package) | data source |
| [oci_marketplace_listings.this](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/marketplace_listings) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_domain"></a> [availability\_domain](#input\_availability\_domain) | The availability domain of the instance. | `string` | n/a | yes |
| <a name="input_boot_volume_size"></a> [boot\_volume\_size](#input\_boot\_volume\_size) | Boot volume size in GB. | `number` | `60` | no |
| <a name="input_compartment"></a> [compartment](#input\_compartment) | The OCID of the compartment where the instance will be created. | `string` | n/a | yes |
| <a name="input_create_timeout"></a> [create\_timeout](#input\_create\_timeout) | Timeout for creating oci\_core\_instance resource. | `string` | `"60m"` | no |
| <a name="input_img_id"></a> [img\_id](#input\_img\_id) | n/a | `string` | `null` | no |
| <a name="input_img_version"></a> [img\_version](#input\_img\_version) | VM-series PAN-OS version. | `string` | `"9.1.6"` | no |
| <a name="input_interfaces"></a> [interfaces](#input\_interfaces) | List of the network interface specifications.<br>The first should be the Management network interface, which does not participate in data filtering.<br>The remaining ones are the dataplane interfaces.<br><br>Example:<pre>[<br>  {<br>    name             = "fw01-mgmt"<br>    subnet_id        = module.vcn.subnet_ids["management"]<br>    assign_public_ip = false<br>  },<br>  {<br>    name             = "fw01-public"<br>    subnet_id        = module.vcn.subnet_ids["public"]<br>    assign_public_ip = true<br>  },<br>  {<br>    name                   = "fw01-trusted"<br>    subnet_id              = module.vcn.subnet_ids["trusted"]<br>    assign_public_ip       = false<br>    private_ip             = "10.11.12.13"<br>    skip_source_dest_check = true<br>  }<br>]</pre> | `list(any)` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Hostname of the VM-Series virtual machine and its virtual NICs. | `string` | n/a | yes |
| <a name="input_preserve_boot_volume"></a> [preserve\_boot\_volume](#input\_preserve\_boot\_volume) | Whether to preserve the boot volume that was used to launch the preemptible instance when the instance is terminated. | `bool` | `false` | no |
| <a name="input_shape"></a> [shape](#input\_shape) | The shape of the instance. The shape determines the number of CPUs and the amount of memory allocated to the instance. | `string` | `"VM.Standard2.4"` | no |
| <a name="input_ssh_authorized_keys"></a> [ssh\_authorized\_keys](#input\_ssh\_authorized\_keys) | Public SSH keys for the default user on the instance. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to all of the created resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Identifier of the deployed VM-Series firewall. |
| <a name="output_mgmt_ip_address"></a> [mgmt\_ip\_address](#output\_mgmt\_ip\_address) | VM-Series management IP address. It is a public IP address if available. Otherwise a private IP address. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
