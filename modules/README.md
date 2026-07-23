# Terraform Modules

Module dependency flow:

```text
vpc
  -> eks
      -> irsa
      -> karpenter
      -> security
      -> iam
          -> aws_iam_role_policy_attachment in environment root
```

Responsibilities:

- `vpc`: AWS network foundation and subnet discovery tags.
- `eks`: EKS control plane and managed node groups only.
- `iam`: reusable least-privilege IAM policies.
- `irsa`: reusable IAM roles trusted by Kubernetes service accounts.
- `karpenter`: AWS-side Karpenter IAM, node role, and interruption queue only.
- `security`: optional AWS security group ingress rules.

No module in this directory installs Helm charts or Kubernetes manifests.
