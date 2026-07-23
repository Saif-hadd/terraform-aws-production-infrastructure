# IAM Module

Creates reusable least-privilege IAM policies used by Kubernetes workloads.

Current policies:

- External API mTLS read access for AWS Secrets Manager

This module creates IAM policies only. Workload role trust is handled by the `irsa` module.
