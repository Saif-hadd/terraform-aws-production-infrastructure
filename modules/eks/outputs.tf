output "cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API endpoint."
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded cluster CA data."
  value       = module.eks.cluster_certificate_authority_data
}

output "oidc_provider" {
  description = "OIDC provider URL without https://."
  value       = module.eks.oidc_provider
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN."
  value       = module.eks.oidc_provider_arn
}

output "cluster_security_group_id" {
  description = "Cluster security group ID."
  value       = module.eks.cluster_security_group_id
}

output "node_security_group_id" {
  description = "Node security group ID."
  value       = module.eks.node_security_group_id
}

output "eks_managed_node_groups" {
  description = "EKS managed node group outputs."
  value       = module.eks.eks_managed_node_groups
}
