# VPC Module

Creates the AWS network foundation for an EKS cluster.

Responsibilities:

- VPC
- public subnets for internet-facing load balancers
- private subnets for nodes and internal load balancers
- intra subnets for the EKS control plane
- NAT gateway configuration
- Kubernetes and Karpenter discovery tags

This module does not create Kubernetes resources.
