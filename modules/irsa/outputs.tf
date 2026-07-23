output "iam_role_arn" {
  description = "IRSA IAM role ARN."
  value       = module.irsa.iam_role_arn
}

output "iam_role_name" {
  description = "IRSA IAM role name."
  value       = module.irsa.iam_role_name
}

output "iam_role_unique_id" {
  description = "IRSA IAM role unique ID."
  value       = module.irsa.iam_role_unique_id
}
