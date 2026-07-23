# IRSA Module

Creates a reusable IAM Role for Service Accounts.

Responsibilities:

- trusted OIDC relationship for selected Kubernetes service accounts
- optional AWS-managed controller policies, such as EBS CSI or AWS Load Balancer Controller
- role outputs for Argo CD Helm values or ServiceAccount annotations

This module creates IAM only. It does not create Kubernetes ServiceAccounts.
