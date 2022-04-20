# Palo Alto Networks VCN module for Oracle Cloud Infrastructure

A terraform module for deploying a Virtual Cloud Network and its components required for the VM-Series firewalls in Oracle Cloud.

## Usage

```hcl
module "network" {
  source = "../../modules/vcn"

  compartment          = var.compartment
  region               = var.region
  cidr_blocks          = var.cidr_blocks
  virtual_network_name = var.virtual_network_name
  tags                 = var.tags
  route_tables         = var.route_tables
  subnets              = var.subnets
  security_lists       = var.security_lists
  create_igw           = true
}

```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=0.13, <0.15 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | =4.23.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | =4.23.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_core_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/oci/4.23.0/docs/resources/core_internet_gateway) | resource |
| [oci_core_local_peering_gateway.this](https://registry.terraform.io/providers/hashicorp/oci/4.23.0/docs/resources/core_local_peering_gateway) | resource |
| [oci_core_route_table.this](https://registry.terraform.io/providers/hashicorp/oci/4.23.0/docs/resources/core_route_table) | resource |
| [oci_core_security_list.this](https://registry.terraform.io/providers/hashicorp/oci/4.23.0/docs/resources/core_security_list) | resource |
| [oci_core_subnet.this](https://registry.terraform.io/providers/hashicorp/oci/4.23.0/docs/resources/core_subnet) | resource |
| [oci_core_vcn.this](https://registry.terraform.io/providers/hashicorp/oci/4.23.0/docs/resources/core_vcn) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cidr_blocks"></a> [cidr\_blocks](#input\_cidr\_blocks) | The address space used by the virtual network. You can supply more than one cidr blocks. | `list(string)` | n/a | yes |
| <a name="input_compartment"></a> [compartment](#input\_compartment) | n/a | `any` | n/a | yes |
| <a name="input_create_igw"></a> [create\_igw](#input\_create\_igw) | Set to true if you want to create Internet Gateway | `bool` | `false` | no |
| <a name="input_dns_label"></a> [dns\_label](#input\_dns\_label) | (Optional) A DNS label for the VCN, used in conjunction with the VNIC's hostname and subnet's DNS label to form a fully qualified domain name (FQDN) for each <br>VNIC within this subnet (for example, instance1.subnet123.vcn1.oraclevcn.com). Not required to be unique, but it's a best practice to set unique DNS labels <br>for VCNs in your tenancy. Must be an alphanumeric string that begins with a letter. The value cannot be changed.<br>You must set this value if you want instances to be able to use hostnames to resolve other instances in the VCN. Otherwise the Internet and VCN Resolver will not work.<br>For more information, see [DNS in Your Virtual Cloud Network](https://docs.cloud.oracle.com/iaas/Content/Network/Concepts/dns.htm). | `string` | `null` | no |
| <a name="input_peerings"></a> [peerings](#input\_peerings) | A map of objects describing Peerings. The key of each entry acts as the Peering name.<br>List of arguments available to define a peering:<br>- `cidr_block` : The address prefix of a remote network.<br>- `route_table` : The Route Table name to which peering entry will be added.<br>- `peer_id` (Optional) : ID of a Peering on a remote side. Specifying a peer\_id creates a connection to the specified LPG ID. peer\_id should only be specified in one of the LPGs.<br><br>Example:<pre>{<br>  to_vcn1 = {<br>    peer_id     = module.vcn1.peering_ids["to_vcn2"]<br>    route_table = "rt"<br>    cidr_block  = "172.21.0.0/16"<br>  },<br>  to_vcn2 = {<br>    route_table = "rt"<br>    cidr_block  = "172.22.0.0/16"<br>  }<br>}</pre> | `map(any)` | `{}` | no |
| <a name="input_region"></a> [region](#input\_region) | Region of the resources that will be deployed. | `string` | n/a | yes |
| <a name="input_route_tables"></a> [route\_tables](#input\_route\_tables) | A map of objects describing a Route Table. The key of each entry acts as the Route Table name.<br><br>  Example:<pre>{<br>    "management_route_table" = {<br>    routes = {<br>      "default" = {<br>        cidr_block    = "0.0.0.0/0"<br>        next_hop_type = "igw"<br>      },<br>    }<br>  },<br>  "private_route_table" = {<br>    routes = {<br>      "default" = {<br>        cidr_block    = "0.0.0.0/0"<br>        next_hop_type = "igw"<br>      },<br>    }<br>  },<br>  "public_route_table" = {<br>    routes = {}<br>  },<br>}</pre> | `any` | n/a | yes |
| <a name="input_security_lists"></a> [security\_lists](#input\_security\_lists) | A map of Security Lists objects to create. The key of each entry acts as the Security List name.<br>  List of arguments available to define a Security List:<br>  - `ingress_rules`: A list of objects representing a Security List. The key of each entry acts as the name of the rule.<br>      List of arguments available to define Rules:<br>      - `protocol` : Network protocol this rule applies to. Possible values include 1 (ICMP), 6 (TCP), 17 (UDP).<br>      - `destination_port` : Destination Port. Integer or `*` to match any. Valid only for protocol set to 6 or 17.<br>      - `destination` : Destination IP range.<br>      - `stateless` : Set to "true" if ther rule should be stateless<br>  - `egress_rules`: A list of objects representing a Security List. The key of each entry acts as the name of the rule.<br>      List of arguments available to define Rules:<br>      - `protocol` : Network protocol this rule applies to. Possible values include 1 (ICMP), 6 (TCP), 17 (UDP).<br>      - `destination_port` : Destination Port. Integer or `*` to match any. Valid only for protocol set to 6 or 17.<br>      - `source` : Source IP range.<br>      - `stateless` : Set to "true" if ther rule should be stateless<br><br>  Example:<pre>{<br>  "management_security_list" = {<br>    ingress_rules = {<br>      "AllowSSH" = {<br>        protocol         = 6 // TCP<br>        destination_port = "22"<br>        source           = "0.0.0.0/0"<br>        stateless        = false<br>      },<br>      "AllowICMP" = {<br>        protocol = 1 // ICMP<br>        source   = "0.0.0.0/0"<br>      }<br><br>    },<br>    egress_rules = {<br>      "AllOutbound" = {<br>        protocol         = 6 // TCP<br>        destination_port = "*"<br>        destination      = "0.0.0.0/0"<br>      }<br>    }<br>  }<br>}</pre> | `any` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | A map of subnet objects to create within a VCN. The object `key` acts as the subnet name.<br>List of arguments available to define a subnet:<br>- `cidr_block` : The address prefix to use for the subnet.<br>- `security_list` : The Security List ID which should be associated with the subnet.<br>- `route_table` : The Route Table ID which should be associated with the subnet.<br>- `private` :  Mark subnet as private, ensure that instances in the subnet have no internet access, even if the VCN has a working internet gateway.<br>- `dns_label`: (Optional) A DNS label for the subnet, used in conjunction with the VNIC's hostname and VCN's DNS label to form a fully qualified domain name (FQDN) for each VNIC within this subnet.<br><br>Example:<pre>{<br>"management" = {<br>  cidr_block    = "172.19.1.0/24"<br>  security_list = "security_list_2"<br>  route_table   = "route_table_1"<br>  },<br>"private" = {<br>  cidr_block    = "172.19.2.0/24"<br>  security_list = "private_security_list"<br>  route_table   = "private_route_table"<br>  private       = true<br>  dns_label     = "private"<br>  },<br>"public" = {<br>  cidr_block    = "172.19.3.0/24"<br>  security_list = "security_list_2"<br>  route_table   = "route_table_3"<br>  }<br>}</pre> | `any` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to all of the created resources. | `map(any)` | `{}` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | The name of the VCN to create. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_internet_gateway_id"></a> [internet\_gateway\_id](#output\_internet\_gateway\_id) | The identifier of the created Internet Gateway (or 'null' if not created). |
| <a name="output_peering_ids"></a> [peering\_ids](#output\_peering\_ids) | The identifiers of the created Peerings. |
| <a name="output_route_table_ids"></a> [route\_table\_ids](#output\_route\_table\_ids) | The identifiers of the created Route Tables. |
| <a name="output_security_list_ids"></a> [security\_list\_ids](#output\_security\_list\_ids) | The identifiers of the created Security Lists. |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | The identifiers of the created Subnets. |
| <a name="output_virtual_network_id"></a> [virtual\_network\_id](#output\_virtual\_network\_id) | The identifier of the created Virtual Network. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
