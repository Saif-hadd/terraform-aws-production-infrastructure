terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  external_api_mtls_secret_arns = length(var.external_api_mtls_secret_arns) > 0 ? var.external_api_mtls_secret_arns : [
    "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${var.external_api_mtls_secret_name_prefix}-*"
  ]
}

resource "aws_iam_policy" "external_api_mtls_read" {
  name        = "${var.name}-external-api-mtls-read"
  description = "Allow pods to read external API mTLS material from AWS Secrets Manager."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = local.external_api_mtls_secret_arns
      }
    ]
  })

  tags = var.tags
}
