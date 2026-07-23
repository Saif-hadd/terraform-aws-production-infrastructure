module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.9.0"

  name               = var.name
  kubernetes_version = var.kubernetes_version

  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions
  endpoint_public_access                   = var.endpoint_public_access
  endpoint_public_access_cidrs             = var.endpoint_public_access_cidrs

  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_ids
  control_plane_subnet_ids = var.control_plane_subnet_ids

  eks_managed_node_groups = var.eks_managed_node_groups

  node_security_group_tags = merge(
    var.node_security_group_tags,
    {
      "karpenter.sh/discovery" = var.name
    }
  )

  tags = var.tags
}