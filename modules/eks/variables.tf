variable "name" {
  description = "EKS cluster name."
  type        = string
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets used by worker nodes."
  type        = list(string)
}

variable "control_plane_subnet_ids" {
  description = "Subnets used by the EKS control plane."
  type        = list(string)
}

variable "enable_cluster_creator_admin_permissions" {
  description = "Whether the Terraform caller receives cluster admin access."
  type        = bool
  default     = false
}

variable "endpoint_public_access" {
  description = "Whether the EKS public API endpoint is enabled."
  type        = bool
  default     = true
}

variable "endpoint_public_access_cidrs" {
  description = "CIDRs allowed to reach the public EKS API endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "eks_managed_node_groups" {
  description = "EKS managed node groups."
  type        = any
  default     = {}
}

variable "cluster_security_group_additional_rules" {
  description = "Additional cluster security group rules passed to the EKS module."
  type        = any
  default     = {}
}

variable "node_security_group_additional_rules" {
  description = "Additional node security group rules passed to the EKS module."
  type        = any
  default     = {}
}

variable "node_security_group_tags" {
  description = "Additional node security group tags."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
