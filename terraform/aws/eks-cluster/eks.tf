resource "aws_vpc" "lab-franklin" {
  cidr_block = "172.16.240.0/20"
}

resource "aws_subnet" "first" {
  vpc_id            = aws_vpc.lab-franklin.id
  cidr_block        = "172.16.240.0/25"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "first"
  }
}

resource "aws_subnet" "second" {
  vpc_id            = aws_vpc.lab-franklin.id
  cidr_block        = "172.16.240.128/25"
  availability_zone = "eu-west-1c"

  tags = {
    Name = "second"
  }
}

resource "aws_eks_cluster" "lab-franklin-eks" {
  name     = "lab-franklin-cluster"
  role_arn = aws_iam_role.eks-iam-role.arn

  vpc_config {
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
  release_version = "1.23.13-20221112"

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    #aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}