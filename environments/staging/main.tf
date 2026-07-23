locals {
  common_tags = merge(
    var.tags,
    {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )
}

module "vpc" {
  source = "../../modules/vpc"

  name     = var.name
  vpc_cidr = var.vpc_cidr
  tags     = local.common_tags
}

module "eks" {
  source = "../../modules/eks"

  name                                     = var.name
  kubernetes_version                       = var.kubernetes_version
  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions
  endpoint_public_access                   = var.endpoint_public_access
  endpoint_public_access_cidrs             = var.endpoint_public_access_cidrs

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  eks_managed_node_groups = var.eks_managed_node_groups

  tags = local.common_tags
}

module "karpenter" {
  source = "../../modules/karpenter"

  cluster_name       = module.eks.cluster_name
  node_iam_role_name = var.name

  tags = local.common_tags
}

module "ebs_csi_irsa" {
  source = "../../modules/irsa"

  role_name_prefix  = "${var.name}-ebs-csi-"
  oidc_provider_arn = module.eks.oidc_provider_arn
  namespace_service_accounts = [
    "kube-system:ebs-csi-controller-sa"
  ]
  attach_ebs_csi_policy = true

  tags = local.common_tags
}

module "aws_load_balancer_controller_irsa" {
  source = "../../modules/irsa"

  role_name_prefix  = "${var.name}-alb-"
  oidc_provider_arn = module.eks.oidc_provider_arn
  namespace_service_accounts = [
    "kube-system:aws-load-balancer-controller"
  ]
  attach_load_balancer_controller_policy = true

  tags = local.common_tags
}

module "iam" {
  source = "../../modules/iam"

  name   = var.name
  region = var.region
  tags   = local.common_tags
}

module "external_api_mtls_irsa" {
  source = "../../modules/irsa"

  role_name_prefix           = "${var.name}-external-api-mtls-"
  oidc_provider_arn          = module.eks.oidc_provider_arn
  namespace_service_accounts = var.external_api_mtls_namespace_service_accounts
  tags                       = local.common_tags
}

resource "aws_iam_role_policy_attachment" "external_api_mtls" {
  role       = module.external_api_mtls_irsa.iam_role_name
  policy_arn = module.iam.external_api_mtls_policy_arn
}

module "security" {
  source = "../../modules/security"

  cluster_security_group_id = module.eks.cluster_security_group_id
  node_security_group_id    = module.eks.node_security_group_id
  cluster_ingress_rules     = var.cluster_ingress_rules
  node_ingress_rules        = var.node_ingress_rules
  tags                      = local.common_tags
}
