# Karpenter Module

Creates only the AWS-side Karpenter infrastructure.

Terraform owns:

- Karpenter controller IAM role
- Karpenter node IAM role
- SQS interruption queue
- optional EKS Pod Identity association

Argo CD owns:

- Karpenter Helm chart
- Karpenter NodePool
- Karpenter EC2NodeClass

This split prevents Terraform from managing Kubernetes runtime components.
