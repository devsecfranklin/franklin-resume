### AWS Provider Authentication and Attributes
variable "region" {
  default = "us-west-2"
  type    = string
}

variable "aws_access_key" {
  description = "See the [`aws` provider documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#static-credentials) for details."
  default     = null
  type        = string
}

variable "aws_secret_key" {
  description = "See the [`aws` provider documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#static-credentials) for details."
  default     = "franklin-key"
  type        = string
}

variable "aws_shared_credentials_file" {
  description = "Example: \"/Users/tf_user/.aws/creds\". See the [`aws` provider documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#static-credentials) for details."
  default     = null
  type        = string
}

variable "aws_profile" {
  description = "Which profile name to use from within the `aws_shared_credentials_file`. Example: \"myprofile\". See the [`aws` provider documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#static-credentials) for details."
  default     = null
  type        = string
}

variable "aws_assume_role" {
  description = <<-EOF
  Example:

  ```
  aws_assume_role = {
    role_arn     = "arn:aws:iam::ACCOUNT_ID:role/ROLE_NAME"
    session_name = "SESSION_NAME"
    external_id  = "EXTERNAL_ID"
  }
  ```
  EOF
  default     = null
  type        = map(string)
}

### General
variable "name" {}

variable "name_prefix" {
  type    = string
  default = "lab-franklin-"
}

variable "global_tags" {
  default = {
    ManagedBy   = "terraform" #change me
    Application = "Palo Alto Networks VM-Series Centralized"
    Owner       = "PS team"
    Creator     = "terraform"
  }
}

### VM-Series
variable "vmseries" {}

variable "vmseries_common" {}

variable "vmseries_version" {}

variable "ssh_key_name" {
  type    = string
  default = "franklin-key"
}

variable "instance_type" {}

variable "create_ssh_key" {
  default = true
  type    = bool
}

variable "ssh_public_key_file" {
  default = null
}

### Transit gateway

variable "create_tgw" {
  default = true
  type    = bool
}

variable "transit_gateway_name" {
  description = "The name tag of the created Transit Gateway."
  type        = string
}

variable "transit_gateway_asn" {
  description = <<-EOF
  Private Autonomous System Number (ASN) of the Transit Gateway for the Amazon side of a BGP session.
  The range is 64512 to 65534 for 16-bit ASNs and 4200000000 to 4294967294 for 32-bit ASNs.
  EOF
  type        = number
}

variable "transit_gateway_route_tables" {
  description = <<-EOF
  Complex input with the Route Tables of the Transit Gateway. Example:

  ```
  {
    "from_security_vpc" = {
      create = true
      name   = "myrt1"
    }
    "from_spoke_vpc" = {
      create = true
      name   = "myrt2"
    }
  }
  ```

  Two keys are required:

  - from_security_vpc describes which route table routes the traffic coming from the Security VPC,
  - from_spoke_vpc describes which route table routes the traffic coming from the Spoke (App1) VPC.

  Each of these entries can specify `create = true` which creates a new RT with a `name`.
  With `create = false` the pre-existing RT named `name` is used.
  EOF
}

### Security VPC
variable "create_vpc" {
  type = bool
  default = true
  
}
variable "security_vpc_name" {
  type = string
  default = "lab-franklin-vpc"
}
variable "security_vpc_cidr" {
    type    = string
  default = "10.243.148.0/25" // changes subnets if you changes this
}
variable "security_vpc_subnets" {}
variable "security_vpc_security_groups" {}
variable "security_vpc_tgw_attachment_name" {}
variable "secondary_cidr_blocks" {}

# Security VPC Routes
variable "security_vpc_routes_outbound_source_cidrs" {
  description = <<-EOF
  From the perspective of Security VPC, the source addresses of packets coming from TGW and flowing outside.
  Used for return traffic routes post-inspection. 
  A list of strings, for example `[\"10.0.0.0/8\"]`.
  EOF
  type        = list(string)
}

variable "security_vpc_routes_outbound_destin_cidrs" {
  description = <<-EOF
  From the perspective of Security VPC, the destination addresses of packets coming from TGW and flowing outside. 
  A list of strings, for example `[\"0.0.0.0/0\"]`.
  EOF
  type        = list(string)
}

variable "security_vpc_mgmt_routes_to_tgw" {
  description = <<-EOF
  The eastwest inspection of traffic heading to VM-Series management interface is not possible. 
  Due to AWS own limitations, anything from the TGW destined for the management interface could *not* possibly override LocalVPC route. 
  Henceforth no management routes go back to gwlbe_eastwest.
  EOF
  type        = list(string)
}

variable "security_vpc_routes_eastwest_cidrs" {
  description = <<-EOF
  From the perspective of Security VPC, the source addresses of packets coming from TGW and flowing back to TGW. 
  A list of strings, for example `[\"10.0.0.0/8\"]`.
  EOF
  type        = list(string)
}

variable "gwlb_name" {}
variable "gwlb_endpoint_set_eastwest_name" {}
variable "gwlb_endpoint_set_outbound_name" {}

variable "security_gwlb_service_name" {
  description = <<-EOF
  Optional Service Name of the pre-existing GWLB which should receive traffic from `app1_gwlb_endpoint_set_name`.
  If empty or null, instead use the Service Name of the default GWLB named `gwlb_name`.
  Example: "com.amazonaws.vpce.us-west-2.vpce-svc-0123".
  EOF
  default     = ""
  type        = string
}

variable "east_west_subinterface" {

}

variable "outbound_subinterface" {

}

variable "security_subnet_data_name" {

}

variable "security_subnet_mgmt_name" {

}

variable "security_subnet_transit_name" {

}

variable "security_subnet_gwlb_name" {

}

variable "security_subnet_gwlbe_eastwest_name" {

}

variable "security_subnet_gwlbe_outbound_name" {
  type        = string
  description = "(optional) describe your variable"
}

// ***** Network-Team-Sandbox *** 

variable "app1_vpc_name" {
  type    = string
  default = "sandbox-test-vpc" // the igw will have this name plus "-igw" and it's own RT
}

variable "app1_vpc_cidr" {
  type    = string
  default = "10.243.148.128/25" // changes subnets if you changes this
}

variable "app1_vpc_security_groups" {
  description = "these are set in terraform.tfvars"
  default = {

  }
}

variable "app1_vpc_subnets" {
  description = "these are set in terraform.tfvars"
}

variable "app1_transit_gateway_attachment_name" {
  type    = string
  default = "sandbox-test-vpc-TGW-Attach"
}

variable "gwlb_endpoint_set_app1_name" {
  type    = string
  default = "sandbox-test-vpc-gwlb-endpoint"
}