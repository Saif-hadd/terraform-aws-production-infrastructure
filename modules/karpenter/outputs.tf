output "queue_name" {
  description = "Karpenter interruption SQS queue name."
  value       = module.karpenter.queue_name
}

output "queue_arn" {
  description = "Karpenter interruption SQS queue ARN."
  value       = module.karpenter.queue_arn
}

output "node_iam_role_name" {
  description = "Karpenter node IAM role name."
  value       = module.karpenter.node_iam_role_name
}

output "node_iam_role_arn" {
  description = "Karpenter node IAM role ARN."
  value       = module.karpenter.node_iam_role_arn
}

output "controller_iam_role_arn" {
  description = "Karpenter controller IAM role ARN."
  value       = module.karpenter.iam_role_arn
}
