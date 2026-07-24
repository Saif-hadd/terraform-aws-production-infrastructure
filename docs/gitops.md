# GitOps

This document describes the GitOps architecture and the responsibility split between Terraform and Argo CD.

## The Split

```text
┌──────────────┐     ┌──────────────┐     ┌──────────────────┐
│   Terraform  │────▶│     AWS      │     │     Git Repo     │
│  (IaC repo)  │     │ Infrastructure│◀────│  (GitOps source) │
└──────────────┘     └──────┬───────┘     └────────┬─────────┘
                            │                      │
                     ┌──────▼──────────────────────▼─────┐
                     │            EKS Cluster             │
                     │         (Argo CD reconciles)       │
                     └───────────────────────────────────┘
```

| Layer           | Owned by    | Examples                                          |
|-----------------|-------------|---------------------------------------------------|
| AWS infrastructure | Terraform | VPC, EKS, IAM, Karpenter AWS-side, SQS           |
| Kubernetes runtime | Argo CD    | Helm charts, manifests, add-ons, workloads       |

**Terraform never manages Helm releases or Kubernetes manifests.** This prevents state drift and keeps infrastructure changes separate from application changes.

## Argo CD Application Set

The GitOps repository (separate from this repo) contains:

```text
gitops-repo/
├── argocd/
│   └── root-app.yaml          # Root Application that bootstraps everything
├── charts/
│   ├── karpenter/
│   ├── aws-load-balancer-controller/
│   ├── ebs-csi-driver/
│   ├── secrets-store-csi-driver/
│   └── external-api-workload/
└── manifests/
    ├── karpenter-nodepool.yaml
    ├── karpenter-ec2nodeclass.yaml
    └── secretproviderclass-external-api.yaml
```

## Root Application

A root Argo CD `Application` points to the GitOps repo and bootstraps all child applications via App-of-Apps or an `ApplicationSet`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: root
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-github/demo-platform-gitops
    targetRevision: HEAD
    path: argocd
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## Bootstrapping Argo CD

1. Install Argo CD manually after the cluster is provisioned:

```bash
kubectl create namespace argocd
helm install argocd argo/argo-cd -n argocd
```

2. Apply the root application:

```bash
kubectl apply -f examples/argocd/root-app.yaml
```

3. Argo CD pulls the GitOps repo and reconciles all runtime components.

## Feeding Terraform Outputs into GitOps

Terraform outputs the IAM role ARNs and other values needed by GitOps:

```bash
terraform output karpenter_queue_name
terraform output karpenter_node_iam_role_name
terraform output aws_load_balancer_controller_irsa_role_arn
terraform output ebs_csi_irsa_role_arn
terraform output external_api_mtls_irsa_role_arn
```

These values are wired into Helm values or ServiceAccount annotations in the GitOps repo. Common patterns:

- **Helm values file** — pass the role ARN via Argo CD `Application` spec
- **ServiceAccount annotation** — annotate the service account with `eks.amazonaws.com/role-arn`
- **ExternalSecret** — store the role ARN in AWS Secrets Manager and reference it

## Why Not Terraform for Helm?

Managing Helm releases with the Terraform `helm` provider is a known anti-pattern:

- State drift from manual `kubectl`/`helm` operations
- Slow plan/apply cycles for chart changes
- Tight coupling between infrastructure and application releases
- No self-healing — Terraform doesn't continuously reconcile

GitOps with Argo CD solves all of these by making Git the single source of truth with continuous reconciliation.
