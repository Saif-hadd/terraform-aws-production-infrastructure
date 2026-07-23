variable "environment" {
  description = "Environment name."
  type        = string
}

variable "project" {
  description = "Project name."
  type        = string
}

variable "name" {
  description = "EKS cluster and platform resource name."
  type        = string
}

variable "region" {
  description = "AWS region."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version."
  type        = string
}

variable "endpoint_public_access" {
  description = "Whether the EKS public API endpoint is enabled."
  type        = bool
}

variable "endpoint_public_access_cidrs" {
  description = "CIDRs allowed to reach the public EKS API endpoint."
  type        = list(string)
}

variable "enable_cluster_creator_admin_permissions" {
  description = "Whether the Terraform caller receives cluster admin access."
  type        = bool
}

variable "eks_managed_node_groups" {
  description = "EKS managed node groups."
  type        = any
}

variable "external_api_mtls_namespace_service_accounts" {
  description = "Service accounts allowed to read external API mTLS secrets."
  type        = list(string)
}

variable "cluster_ingress_rules" {
  description = "Additional EKS cluster security group ingress rules."
  type        = any
  default     = {}
}

variable "node_ingress_rules" {
  description = "Additional EKS node security group ingress rules."
  type        = any
  default     = {}
}

variable "tags" {
  description = "Additional tags."
  type        = map(string)
  default     = {}
}
