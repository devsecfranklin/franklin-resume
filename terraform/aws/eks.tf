resource "aws_vpc" "lab-franklin" {
  cidr_block = "172.16.240.0/20"
}

resource "aws_subnet" "first" {
  vpc_id            = aws_vpc.lab-franklin.id
  cidr_block        = "172.16.240.0/25"
  availability_zone = "eu-west-1b"

  tags = var.tags
}

resource "aws_subnet" "second" {
  vpc_id            = aws_vpc.lab-franklin.id
  cidr_block        = "172.16.240.128/25"
  availability_zone = "eu-west-1c"

  tags = var.tags
}

resource "aws_eks_cluster" "lab-franklin-eks" {
  name             = "lab-franklin-cluster"
  role_arn         = aws_iam_role.eks-iam-role.arn
  version          = "1.24"
  enabled_cluster_log_types = []
  tags             = {}

  kubernetes_network_config {
    ip_family         = "ipv4"
    service_ipv4_cidr = "10.100.0.0/16"
    #service_ipv6_cidr = (known after apply)
  }

  vpc_config {
    security_group_ids        = []
    subnet_ids = [aws_subnet.first.id, aws_subnet.second.id]
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
  subnet_ids      = [aws_subnet.first.id, aws_subnet.second.id]
  instance_types  = ["t3.xlarge"]
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
}