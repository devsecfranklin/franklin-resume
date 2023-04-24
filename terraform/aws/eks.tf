module "eks_c1" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = "${var.name}-c1"
  cluster_version = var.k8s_version

  vpc_id = module.vpc_eks.vpc.id
  control_plane_subnet_ids = [
    for k, v in module.vpc_eks.subnets : v.id if length(regexall("k8s-cp-", k)) > 0
  ]
  subnet_ids = [
    for k, v in module.vpc_eks.subnets : v.id if length(regexall("k8s-n-", k)) > 0
  ]

  cluster_addons = {
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_irsa_role_c1.iam_role_arn
    }
    # coredns = {
    #   most_recent = true
    # }
    # kube-proxy = {
    #   most_recent = true
    # }
    # vpc-cni = {
    #   most_recent = true
    # }
  }


  cluster_endpoint_public_access_cidrs = concat(
    [for k, v in var.mgmt_ips : v.cidr],
    [for ip in [var.panorama1_ip, var.panorama2_ip] : "${ip}/32"],
  )
  cluster_endpoint_public_access  = true #just to have it explicitly
  cluster_endpoint_private_access = true

  manage_aws_auth_configmap = false

  node_security_group_additional_rules = {
    r1 = {
      protocol  = 6
      from_port = 22
      to_port   = 22
      type      = "ingress"
      cidr_blocks = [
        module.vpc_eks.subnets["mgmt"].cidr_block
      ]
    }
  }

  eks_managed_node_groups = {
    default_node_group = {
      desired_size               = 2
      instance_types             = ["t3.2xlarge"]
      use_custom_launch_template = false

      remote_access = {
        ec2_ssh_key = var.key_name
      }
      labels = {
        ng = "def"
      }
    }
    cnng = {
      desired_size         = 2
      instance_types       = ["t3.2xlarge"]
      ami_type             = "BOTTLEROCKET_x86_64"
      platform             = "bottlerocket"
      bootstrap_extra_args = <<-EOT
      [settings.host-containers.admin]
      enabled = true

      [settings.kubernetes.node-labels]
      nge = "cne"
      EOT
      labels = {
        ng = "cn"
      }
      taints = [
        {
          key    = "dedicated"
          value  = "cn-series"
          effect = "NO_SCHEDULE"
        }
      ]
    }
  }
}


module "ebs_csi_irsa_role_c1" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "ebs-csi-c1"
  attach_ebs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks_c1.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}



# provider "kubernetes" {
#   host                   = module.eks_c1.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks_c1.cluster_certificate_authority_data)

#   exec {
#     api_version = "client.authentication.k8s.io/v1"
#     command     = "aws"
#     args        = ["eks", "get-token", "--cluster-name", module.eks_c1.cluster_name]
#   }
# }


/*
resource "aws_subnet" "first" {
  vpc_id            = aws_vpc.lab-franklin.id
  cidr_block        = "172.16.240.0/25"
  availability_zone = "${var.region}a"
  tags              = var.tags
}

resource "aws_subnet" "second" {
  vpc_id            = aws_vpc.lab-franklin.id
  cidr_block        = "172.16.240.128/25"
  availability_zone = "${var.region}d"
  tags              = var.tags
}

resource "aws_subnet" "third" {
  vpc_id            = aws_vpc.lab-franklin.id
  cidr_block        = "172.16.241.0/25"
  availability_zone = "${var.region}a"
  tags              = var.tags
}

resource "aws_subnet" "fourth" {
  vpc_id            = aws_vpc.lab-franklin.id
  cidr_block        = "172.16.241.128/25"
  availability_zone = "${var.region}b"
  tags              = var.tags
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

*/
