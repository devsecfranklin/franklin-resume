resource "aws_vpc" "lab-franklin" {
  cidr_block = "172.16.240.0/20"
  tags = {
    Name = "${var.name_prefix}-vpc"
  }
  lifecycle {
    prevent_destroy = true
  }
}

//provide access to the internet in the given VPC
/*
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
   Name = "2nd Route Table"
 }
}

// We have to explicitly associate all the public subnets with the second route table to enable internet access on them. 
resource "aws_route_table_association" "public_subnet_asso" {
 count = length(var.public_subnet_cidrs)
 subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
 route_table_id = aws_route_table.second_rt.id
}
*/

resource "aws_subnet" "first" {
  vpc_id            = aws_vpc.lab-franklin.id
  cidr_block        = "172.16.240.0/25"
  availability_zone = "${var.region}a"
  tags              = var.tags
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_subnet" "second" {
  vpc_id            = aws_vpc.lab-franklin.id
  cidr_block        = "172.16.240.128/25"
  availability_zone = "${var.region}d"
  tags              = var.tags
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_subnet" "third" {
  vpc_id            = aws_vpc.lab-franklin.id
  cidr_block        = "172.16.241.0/25"
  availability_zone = "${var.region}a"
  tags              = var.tags
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_subnet" "fourth" {
  vpc_id            = aws_vpc.lab-franklin.id
  cidr_block        = "172.16.241.128/25"
  availability_zone = "${var.region}b"
  tags              = var.tags
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_security_group" "lab-franklin-eks" {
  description = "Cluster security group"
  vpc_id      = aws_vpc.lab-franklin.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = var.aws_security_group_cidr_blocks
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = var.tags
}

resource "aws_eks_cluster" "lab-franklin-eks" {
  name                      = "lab-franklin-cluster"
  role_arn                  = aws_iam_role.eks-iam-role.arn
  version                   = "1.24"
  enabled_cluster_log_types = []

  kubernetes_network_config {
    ip_family         = "ipv4"
    service_ipv4_cidr = "10.100.0.0/16"
    #service_ipv6_cidr = (known after apply)
  }

  vpc_config {
    security_group_ids = []
    subnet_ids         = [aws_subnet.first.id, aws_subnet.second.id, aws_subnet.third.id, aws_subnet.fourth.id]
  }

  depends_on = [
    aws_iam_role.eks-iam-role,
  ]
}

// https://aws.amazon.com/premiumsupport/knowledge-center/resolve-eks-node-failures/
resource "aws_eks_node_group" "dev-nodes" {
  cluster_name    = aws_eks_cluster.lab-franklin-eks.name
  node_group_name = "lab-franklin-dev-nodes"
  node_role_arn   = aws_iam_role.workernodes.arn
  subnet_ids      = [aws_subnet.first.id, aws_subnet.second.id, aws_subnet.third.id, aws_subnet.fourth.id]
  instance_types  = ["c4.large", "c5.xlarge", "c5.xlarge", "c4.xlarge"]
  ami_type        = "AL2_x86_64"
  disk_size       = 20
  labels          = {}
  //release_version = "1.24"
  scaling_config {
    desired_size = 2
    max_size     = 6
    min_size     = 1
  }
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    #aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
  tags = {
    "git stat" = "owned",
  }
}

