variable "role_name" {
  description = "Explicit IAM role name. Leave null to use role_name_prefix."
  type        = string
  default     = null
}

variable "role_name_prefix" {
  description = "IAM role name prefix."
  type        = string
  default     = null
}

variable "oidc_provider_arn" {
  description = "EKS OIDC provider ARN."
  type        = string
}

variable "namespace_service_accounts" {
  description = "Allowed Kubernetes service accounts in namespace:name format."
  type        = list(string)
}

variable "attach_ebs_csi_policy" {
  description = "Attach the AWS-managed EBS CSI policy."
  type        = bool
  default     = false
}

variable "attach_load_balancer_controller_policy" {
  description = "Attach the AWS Load Balancer Controller policy."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
