# Architecture

This document describes the overall architecture of the Demo Platform, the separation of concerns between Terraform and Argo CD, and how the components interact.

## Design Principles

1. **Infrastructure / Runtime split** — Terraform owns AWS resources; Argo CD owns everything inside the Kubernetes cluster. No Helm charts or Kubernetes manifests are managed by Terraform.
2. **Modularity** — each Terraform module has a single responsibility and can be composed into any environment.
3. **Environment isolation** — `dev`, `staging`, and `prod` each have their own VPC, EKS cluster, and remote state file.
4. **Least privilege** — every workload gets a scoped IAM role via IRSA; the node instance profile is never used for application access.
5. **Reproducibility** — Terraform, provider, and module versions are pinned.

## High-Level Diagram

See [`assets/architecture.svg`](../assets/architecture.svg) for the visual diagram.

## Component Overview

### Terraform Layer (Infrastructure)

| Module      | Creates                                                              |
|-------------|----------------------------------------------------------------------|
| `vpc`       | VPC, public/private/intra subnets, NAT gateway, Kubernetes tags     |
| `eks`       | EKS control plane, managed node group, node/cluster security groups |
| `irsa`      | IAM roles trusted by Kubernetes service accounts (EBS CSI, ALB, mTLS) |
| `iam`       | Least-privilege IAM policies (external API mTLS read)               |
| `karpenter` | Karpenter controller IAM role, node IAM role, SQS interruption queue |
| `security`  | Optional additional security group ingress rules                    |

### Bootstrap Layer

| Component                | Purpose                                             |
|--------------------------|-----------------------------------------------------|
| S3 bucket                | Remote state storage with versioning                |
| DynamoDB table           | State locking                                       |
| KMS key + alias          | Encryption for state objects                        |

### Runtime Layer (GitOps / Argo CD)

These are **not** in this Terraform repository — they belong to a separate GitOps repository reconciled by Argo CD:

| Component                   | Purpose                                        |
|-----------------------------|------------------------------------------------|
| Argo CD                     | GitOps controller and source of truth          |
| Karpenter Helm + NodePool   | Node autoscaling                               |
| AWS Load Balancer Controller| ALB/NLB ingress                                |
| EBS CSI Driver              | Persistent volumes                             |
| Secrets Store CSI Driver    | Mount AWS Secrets Manager material             |
| Prometheus + Grafana        | Metrics and dashboards                         |
| External API mTLS workload  | Reference pattern for third-party API calls    |

## Module Dependency Flow

```text
vpc
  → eks
      → irsa
      → karpenter
      → security
      → iam
          → aws_iam_role_policy_attachment in environment root
```

## Data Flow

1. **Provisioning:** Terraform creates the AWS infrastructure and outputs IAM role ARNs, the OIDC provider, and the Karpenter queue name.
2. **GitOps bootstrap:** Argo CD is installed manually, then pointed at a root `Application` that references the GitOps repository.
3. **Reconciliation:** Argo CD pulls Helm charts and manifests from Git and applies them to the cluster, using the IAM roles and outputs from Terraform.
4. **Runtime:** Workloads run on Karpenter-provisioned nodes, access AWS via IRSA, and mount secrets via Secrets Store CSI.

## Why This Split?

Keeping Terraform out of the Kubernetes runtime layer provides:

- **Faster iteration** — GitOps changes don't require a Terraform plan/apply cycle
- **Safer state** — Terraform state stays small and focused on AWS resources
- **Clear ownership** — platform engineers own Terraform; developers own GitOps
- **No Helm-in-Terraform drift** — Helm releases managed by Terraform are notoriously fragile

## Environments

| Environment | VPC CIDR      | Cluster Name                  | Purpose                |
|-------------|---------------|-------------------------------|------------------------|
| `dev`       | `10.10.0.0/16`| `demo-platform-dev-eks`       | Development and testing|
| `staging`   | `10.20.0.0/16`| `demo-platform-staging-eks`   | Pre-production         |
| `prod`      | `10.0.0.0/16` | `demo-platform-prod-eks`      | Production             |

Each environment is fully isolated with its own VPC and state file.
