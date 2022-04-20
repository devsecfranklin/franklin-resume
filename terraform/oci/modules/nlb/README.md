

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
| [oci_network_load_balancer_backend_set.this](https://registry.terraform.io/providers/hashicorp/oci/4.23.0/docs/resources/network_load_balancer_backend_set) | resource |
| [oci_network_load_balancer_listener.this](https://registry.terraform.io/providers/hashicorp/oci/4.23.0/docs/resources/network_load_balancer_listener) | resource |
| [oci_network_load_balancer_network_load_balancer.this](https://registry.terraform.io/providers/hashicorp/oci/4.23.0/docs/resources/network_load_balancer_network_load_balancer) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartment"></a> [compartment](#input\_compartment) | The OCID of the compartment in which to create the load balancer resources. | `string` | n/a | yes |
| <a name="input_health_checker_interval"></a> [health\_checker\_interval](#input\_health\_checker\_interval) | The interval between health checks, in milliseconds. | `number` | `10000` | no |
| <a name="input_health_checker_port"></a> [health\_checker\_port](#input\_health\_checker\_port) | The backend server port against which to run the health check. | `number` | `80` | no |
| <a name="input_health_checker_protocol"></a> [health\_checker\_protocol](#input\_health\_checker\_protocol) | The protocol the health check will use. Possible values: HTTP or TCP. | `string` | `"TCP"` | no |
| <a name="input_is_preserve_source_destination"></a> [is\_preserve\_source\_destination](#input\_is\_preserve\_source\_destination) | This parameter can be enabled only if backends are compute OCIDs. When enabled, the skipSourceDestinationCheck parameter is automatically enabled on the load balancer VNIC, and packets are sent to the backend with the entire IP header intact. | `bool` | `false` | no |
| <a name="input_listeners"></a> [listeners](#input\_listeners) | A map of listeners to deploy.<br><br>Example:<pre>{<br>  SSH = {<br>    port     = 22<br>    protocol = "TCP"<br>  }<br>  HTTP = {<br>    port     = 80<br>    protocol = "TCP"<br>  }<br>}</pre> | `map(any)` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the LoadBalancer to create. | `string` | n/a | yes |
| <a name="input_policy"></a> [policy](#input\_policy) | The network load balancer policy for the backend set. | `string` | `"FIVE_TUPLE"` | no |
| <a name="input_private"></a> [private](#input\_private) | Whether the load balancer has a VCN-local (private) IP address. Please note, that You cannot specify a private subnet for your public load balancer. | `bool` | n/a | yes |
| <a name="input_reserved_ips"></a> [reserved\_ips](#input\_reserved\_ips) | An array of reserved IPs.<br>!!! Only one reserved IP is supported per Network Load Balancer at the moment !!!<br>Example:<pre>{<br>  reserved_ip = {<br>    id = oci_core_public_ip.this.id<br>  }<br>}</pre> | `map(any)` | `{}` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | n/a | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to all of the created resources. | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backend_sets"></a> [backend\_sets](#output\_backend\_sets) | n/a |
| <a name="output_listeners"></a> [listeners](#output\_listeners) | n/a |
| <a name="output_loadbalancer"></a> [loadbalancer](#output\_loadbalancer) | n/a |
| <a name="output_loadbalancer_ip"></a> [loadbalancer\_ip](#output\_loadbalancer\_ip) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
