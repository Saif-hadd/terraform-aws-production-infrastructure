# Examples

This directory contains worked configuration examples that complement the main Terraform environments.

## Contents

| Path | Description |
|------|-------------|
| `terraform/minimal-vpc-eks/` | Minimal single-environment VPC + EKS configuration |
| `argocd/root-app.yaml` | Argo CD root Application to bootstrap GitOps |

## Usage

### Minimal Terraform example

```bash
cd examples/terraform/minimal-vpc-eks
terraform init
terraform plan
```

### Argo CD bootstrap

```bash
kubectl apply -f examples/argocd/root-app.yaml
```

Replace the `repoURL` with your own GitOps repository before applying.
