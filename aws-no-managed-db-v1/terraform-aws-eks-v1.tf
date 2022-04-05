variable "eks_node_type" {
  default     = "t3.small"
  description = "Node instance type"
}

variable "eks_nodes_count" {
  default     = 6
  description = "Node instance type"
}

variable "eks_volume_size" {
  default     = 100
  description = "Node volume size (GB)"
}

locals {
  eks_cluster_name = "${local.resource_prefix}-eks"
}

resource "aws_security_group" "eks_ssh_sg" {
  name        = "${local.resource_prefix}-eks-ssh-sg"
  vpc_id      = module.vpc.vpc_id
  description = "SSH Access by admin to eks cluster"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "18.16.0"
  cluster_name                    = local.eks_cluster_name
  cluster_version                 = "1.21"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = false

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {
      resolve_conflicts = "OVERWRITE"
    }
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  vpc_id = module.vpc.vpc_id
  subnet_ids = [
    (length(data.aws_subnets.private_subnet_1.ids) > 0 ? data.aws_subnets.private_subnet_1.ids[0] : ""),
    (length(data.aws_subnets.private_subnet_2.ids) > 0 ? data.aws_subnets.private_subnet_2.ids[0] : ""),
    (length(data.aws_subnets.private_subnet_3.ids) > 0 ? data.aws_subnets.private_subnet_3.ids[0] : ""),
  ]

  eks_managed_node_group_defaults = {
    instance_type          = var.eks_node_type
    disk_size              = var.eks_volume_size
    ami_type               = "AL2_x86_64"
    vpc_security_group_ids = [aws_security_group.eks_ssh_sg.id]
    min_size               = var.eks_nodes_count
    max_size               = var.eks_nodes_count
    desired_size           = var.eks_nodes_count
  }

  eks_managed_node_groups = {
    pam = {
      name                   = "${local.resource_prefix}-node-group"
      create_launch_template = false
      launch_template_name   = ""
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

output "eks_cluster_id" {
  description = "EKS cluster ID."
  value       = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks.cluster_security_group_id
}

output "eks_region" {
  description = "AWS region"
  value       = var.region
}

output "eks_cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = local.eks_cluster_name
}
