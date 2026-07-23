output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "karpenter_queue_name" {
  value = module.karpenter.queue_name
}

output "karpenter_node_iam_role_name" {
  value = module.karpenter.node_iam_role_name
}

output "ebs_csi_irsa_role_arn" {
  value = module.ebs_csi_irsa.iam_role_arn
}

output "aws_load_balancer_controller_irsa_role_arn" {
  value = module.aws_load_balancer_controller_irsa.iam_role_arn
}

output "external_api_mtls_irsa_role_arn" {
  value = module.external_api_mtls_irsa.iam_role_arn
}
