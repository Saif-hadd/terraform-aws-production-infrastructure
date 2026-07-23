output "external_api_mtls_policy_arn" {
  description = "Policy ARN for reading external API mTLS material."
  value       = aws_iam_policy.external_api_mtls_read.arn
}

output "external_api_mtls_policy_name" {
  description = "Policy name for reading external API mTLS material."
  value       = aws_iam_policy.external_api_mtls_read.name
}
