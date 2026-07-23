output "cluster_ingress_rule_ids" {
  description = "Additional cluster security group ingress rule IDs."
  value       = { for key, rule in aws_vpc_security_group_ingress_rule.cluster : key => rule.id }
}

output "node_ingress_rule_ids" {
  description = "Additional node security group ingress rule IDs."
  value       = { for key, rule in aws_vpc_security_group_ingress_rule.node : key => rule.id }
}
