terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_vpc_security_group_ingress_rule" "cluster" {
  for_each = var.cluster_ingress_rules

  security_group_id            = var.cluster_security_group_id
  description                  = each.value.description
  ip_protocol                  = each.value.ip_protocol
  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  cidr_ipv4                    = try(each.value.cidr_ipv4, null)
  referenced_security_group_id = try(each.value.referenced_security_group_id, null)

  tags = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "node" {
  for_each = var.node_ingress_rules

  security_group_id            = var.node_security_group_id
  description                  = each.value.description
  ip_protocol                  = each.value.ip_protocol
  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  cidr_ipv4                    = try(each.value.cidr_ipv4, null)
  referenced_security_group_id = try(each.value.referenced_security_group_id, null)

  tags = var.tags
}
