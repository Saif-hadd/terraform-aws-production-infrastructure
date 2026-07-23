terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "21.9.0"

  cluster_name = var.cluster_name

  node_iam_role_use_name_prefix = var.node_iam_role_use_name_prefix
  node_iam_role_name            = var.node_iam_role_name

  create_pod_identity_association = var.create_pod_identity_association

  node_iam_role_additional_policies = var.node_iam_role_additional_policies

  tags = var.tags
}
