# EKS Module

Creates the AWS EKS control plane and managed node groups.

Responsibilities:

- EKS cluster
- cluster endpoint configuration
- EKS managed node groups
- node and cluster security group wiring
- OIDC provider output for IRSA

This module intentionally does not install Helm charts, Kubernetes manifests, or runtime add-ons. Those belong to Argo CD.
