variable "cluster_security_group_id" {
  description = "EKS cluster security group ID."
  type        = string
}

variable "node_security_group_id" {
  description = "EKS node security group ID."
  type        = string
}

variable "cluster_ingress_rules" {
  description = "Additional cluster security group ingress rules."
  type = map(object({
    description                  = string
    ip_protocol                  = string
    from_port                    = number
    to_port                      = number
    cidr_ipv4                    = optional(string)
    referenced_security_group_id = optional(string)
  }))
  default = {}
}

variable "node_ingress_rules" {
  description = "Additional node security group ingress rules."
  type = map(object({
    description                  = string
    ip_protocol                  = string
    from_port                    = number
    to_port                      = number
    cidr_ipv4                    = optional(string)
    referenced_security_group_id = optional(string)
  }))
  default = {}
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
