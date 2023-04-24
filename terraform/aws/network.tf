module "vpc_eks" {
  source = "../modules/vpc"

  name = "${var.name}-eks"

  enable_dns_hostnames = true

  cidr_block              = var.cidr
  public_mgmt_prefix_list = aws_ec2_managed_prefix_list.mgmt_ips.id
  deploy_igw              = true
  deploy_natgw            = true

  connect_tgw = false

  subnets = {
    "mgmt" : { "idx" : 0, "zone" : var.availability_zones[0] },
    "natgw-a" : { "idx" : 1, "zone" : var.availability_zones[0] },
    "natgw-b" : { "idx" : 2, "zone" : var.availability_zones[1] },
    "k8s-cp-a" : { "idx" : 3, "zone" : var.availability_zones[0] },
    "k8s-cp-b" : { "idx" : 4, "zone" : var.availability_zones[1] },
    "k8s-n-a" : { "idx" : 1, "zone" : var.availability_zones[0], "subnet_mask_length" : 24 },
    "k8s-n-b" : { "idx" : 2, "zone" : var.availability_zones[1], "subnet_mask_length" : 24 },
  }
}

resource "aws_route_table_association" "mgmt" {
  subnet_id      = module.vpc_eks.subnets["mgmt"].id
  route_table_id = module.vpc_eks.route_tables["via_igw"]
}


resource "aws_route_table" "via_natgw" {
  for_each = { for k, v in module.vpc_eks.subnets : v.availability_zone => v if length(regexall("natgw-", k)) > 0 }

  vpc_id = module.vpc_eks.vpc.id
  tags = {
    Name = "${var.name}-via-natgw-${each.key}"
  }
}

resource "aws_route" "via_natgw-dg" {
  for_each = { for k, v in module.vpc_eks.subnets : v.availability_zone => v if length(regexall("natgw-", k)) > 0 }

  route_table_id         = aws_route_table.via_natgw[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = module.vpc_eks.nat_gateways[each.key].id
}


resource "aws_route_table_association" "k8s" {
  for_each = { for k, v in module.vpc_eks.subnets : k => v if length(regexall("k8s-", k)) > 0 }

  subnet_id      = each.value.id
  route_table_id = aws_route_table.via_natgw[each.value.availability_zone].id
}

resource "aws_route_table_association" "natgw" {
  for_each = { for k, v in module.vpc_eks.subnets : k => v if length(regexall("natgw-", k)) > 0 }

  subnet_id      = each.value.id
  route_table_id = module.vpc_eks.route_tables["via_igw"]
}

/* 
resource "aws_vpc" "lab-franklin" {
  cidr_block = "172.16.240.0/20"
  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

//provide access to the internet in the given VPC
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.lab-franklin.id
  tags = {
    Name = "${var.name_prefix}-vpc-igw"
  }
}

resource "aws_route_table" "second_rt" {
  vpc_id = aws_vpc.lab-franklin.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Second Route Table"
  }
}

// Explicitly associate all the public subnets with the second route table to enable internet access on them.
resource "aws_route_table_association" "public_subnet_asso" {
 count = length(var.public_subnet_cidrs)
 subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
 route_table_id = aws_route_table.second_rt.id
}
*/
