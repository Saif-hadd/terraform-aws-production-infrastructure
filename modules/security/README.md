# Security Module

Adds optional AWS security group rules around the EKS cluster and nodes.

Default behavior creates no extra rules. This keeps migration safe while giving each environment a clean place for future production network hardening.

This module manages AWS security group rules only. Kubernetes NetworkPolicies belong in Argo CD.
