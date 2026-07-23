variable "name" {
  description = "Name prefix for IAM policies."
  type        = string
}

variable "region" {
  description = "AWS region."
  type        = string
}

variable "external_api_mtls_secret_name_prefix" {
  description = "Secrets Manager secret name prefix for external API mTLS material."
  type        = string
  default     = "demo-platform-external-api-mtls"
}

variable "external_api_mtls_secret_arns" {
  description = "Explicit Secrets Manager ARNs for external API mTLS material. Overrides external_api_mtls_secret_name_prefix when set."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
