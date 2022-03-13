module "app1_vpc" {
  source = "./modules/vpc"

  name                    = var.app1_vpc_name
  cidr_block              = var.app1_vpc_cidr
  security_groups         = var.app1_vpc_security_groups
  create_internet_gateway = true
  enable_dns_hostnames    = true
  enable_dns_support      = true
  instance_tenancy        = "default"
}

module "app1_subnet_sets" {
  for_each = toset(distinct([for _, v in var.app1_vpc_subnets : v.set]))
  source   = "./modules/subnet_set"

  name   = each.key
  vpc_id = module.app1_vpc.id
  cidrs  = { for k, v in var.app1_vpc_subnets : k => v if v.set == each.key }
}

module "app1_transit_gateway_attachment" {
  source = "./modules/transit_gateway_attachment"

  name                        = var.app1_transit_gateway_attachment_name
  subnet_set                  = module.app1_subnet_sets["app1_web"]
  transit_gateway_route_table = module.transit_gateway.route_tables["from_app1_vpc"]
  //propagate_routes_to = {
  //  to1 = module.transit_gateway.route_tables["from_security_vpc"].id
  //}
}

module "app1_gwlbe_inbound" {
  source = "./modules/gwlb_endpoint_set"

  name       = var.gwlb_endpoint_set_app1_name
  gwlb       = module.security_gwlb # this is cross-vpc
  subnet_set = module.app1_subnet_sets["app1_gwlbe"]
  act_as_next_hop_for = {
    "from-igw-to-alb" = {
      route_table_id = module.app1_vpc.internet_gateway_route_table.id
      to_subnet_set  = module.app1_subnet_sets["app1_alb"]
    }
    "from-igw-to-web" = {
      route_table_id = module.app1_vpc.internet_gateway_route_table.id
      to_subnet_set  = module.app1_subnet_sets["app1_web"]
    }
    # The routes in this section are special in that they are on the "edge", that is they are part of an IGW route table,
    # and AWS allows their destinations to only be:
    #     - The entire IPv4 or IPv6 CIDR block of your VPC. (Not interesting, as we always want AZ-specific next hops.)
    #     - The entire IPv4 or IPv6 CIDR block of a subnet in your VPC. (This is used here.)
    # Source: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html#gateway-route-table
  }
}

module "app1_route" {
  for_each = {
    from-gwlbe-to-igw = {
      next_hop_set    = module.app1_vpc.igw_as_next_hop_set
      route_table_ids = module.app1_subnet_sets["app1_gwlbe"].unique_route_table_ids
      to_cidr         = "0.0.0.0/0"
    }
    from-web-to-tgw = {
      next_hop_set    = module.app1_transit_gateway_attachment.next_hop_set
      route_table_ids = module.app1_subnet_sets["app1_web"].unique_route_table_ids
      to_cidr         = "0.0.0.0/0"
    }
    from-alb-to-gwlbe = {
      next_hop_set    = module.app1_gwlbe_inbound.next_hop_set
      route_table_ids = module.app1_subnet_sets["app1_alb"].unique_route_table_ids
      to_cidr         = "0.0.0.0/0"
    }
  }
  source = "./modules/vpc_route"

  route_table_ids = each.value.route_table_ids
  to_cidr         = each.value.to_cidr
  next_hop_set    = each.value.next_hop_set
}

data "aws_ami" "this" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

/* # A second app server in the other AZ can be provisioned
   # put an application load balancer in front of the app servers
module "app1_ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "3.5.0"

  name           = "nj-courts-sandbox-app-b"
  ami                    = data.aws_ami.this.id
  instance_type          = "t2.micro"
  key_name               = var.ssh_key_name
  monitoring             = true
  vpc_security_group_ids = [module.app1_vpc.security_group_ids["app1_web"]]
  subnet_id              = module.app1_subnet_sets["app1_web"].subnets["us-east-1a"].id
  tags = var.global_tags
}
*/

module "app1_ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "3.5.0"

  name                   = "nj-courts-sandbox-app-b"
  ami                    = data.aws_ami.this.id
  instance_type          = "t2.micro"
  key_name               = var.ssh_key_name
  monitoring             = true
  vpc_security_group_ids = [module.app1_vpc.security_group_ids["app1_web"]]
  subnet_id              = module.app1_subnet_sets["app1_web"].subnets["us-east-1a"].id
  tags                   = var.global_tags
}

resource "aws_eip" "this" {
  vpc      = true
  instance = module.app1_ec2.id
}

module "nlb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "${var.prefix_name_tag}nlb"

  load_balancer_type = "network"

  vpc_id = module.app1_vpc.id
  subnets = [
    module.app1_subnet_sets["app1_alb"].subnets["us-east-1a"].id
    //module.app1_subnet_sets["app1_alb"].subnets["us-east-1b"].id
  ]

  target_groups = [
    {
      name_prefix      = "njc-"
      backend_protocol = "TCP"
      backend_port     = 80
      target_type      = "ip"
    }
  ]

  /*
  https_listeners = [
    {
      port               = 443
      protocol           = "TLS"
      certificate_arn    = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
      target_group_index = 0
    }
  ]
  */

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "TCP"
      target_group_index = 0
    },
    {
      port               = 22
      protocol           = "TCP"
      target_group_index = 0
    }
  ]

  tags = var.global_tags
}
