variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "node_iam_role_use_name_prefix" {
  description = "Whether Karpenter node IAM role should use a generated name prefix."
  type        = bool
  default     = false
}

variable "node_iam_role_name" {
  description = "Karpenter node IAM role name. This must match the EC2NodeClass role used by Argo CD."
  type        = string
}

variable "create_pod_identity_association" {
  description = "Create the AWS EKS Pod Identity association for the Karpenter controller."
  type        = bool
  default     = true
}

variable "node_iam_role_additional_policies" {
  description = "Additional policies attached to the Karpenter node IAM role."
  type        = map(string)
  default = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
