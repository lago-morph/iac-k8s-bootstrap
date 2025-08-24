module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.1.0"

  name               = "${var.name}-eks"
  kubernetes_version = "1.33"

  # EKS Addons
  addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
    aws-efs-csi-driver     = { most_recent = true }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  endpoint_public_access                   = true
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    nodes = {
      # with k8s v1.30 and later AL2023 is AMI for EKS managed node groups
      instance_types = ["t3.medium"]

      min_size     = var.numAZs
      max_size     = var.numAZs
      desired_size = var.numAZs
      # desired size only used on creation
      iam_role_additional_policies = { AmazonEFSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy" }
    }
  }

  node_security_group_additional_rules = {
    ingress_self_http = {
      description = "Node to node http"
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      type        = "ingress"
      self        = true
    }

  }
  tags = local.tags
}

