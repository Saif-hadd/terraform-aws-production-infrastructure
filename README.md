# Demo Platform — Production-Grade AWS EKS Infrastructure

<p align="center">
  <img src="assets/logo.svg" alt="Demo Platform" width="120" />
</p>

<p align="center">
  A production-ready, open-source reference implementation of an AWS EKS Kubernetes platform foundation built with modular Terraform, IRSA, and Karpenter.
</p>

<p align="center">
  <img alt="Terraform" src="https://img.shields.io/badge/Terraform-≥1.14-7B42BC?logo=terraform&logoColor=white" />
  <img alt="AWS EKS" src="https://img.shields.io/badge/AWS%20EKS-1.34-FF9900?logo=amazon-eks&logoColor=white" />
  <img alt="Kubernetes" src="https://img.shields.io/badge/Kubernetes-1.34-326CE5?logo=kubernetes&logoColor=white" />
  <img alt="Karpenter" src="https://img.shields.io/badge/Karpenter-Autoscaling-00A9E0?logo=karpenter&logoColor=white" />
  <img alt="IRSA" src="https://img.shields.io/badge/IRSA-Least%20Privilege-232F3E?logo=amazon-aws&logoColor=white" />
  <img alt="License" src="https://img.shields.io/badge/License-MIT-green" />
  <img alt="PRs Welcome" src="https://img.shields.io/badge/PRs-welcome-brightgreen" />
</p>

---

## Overview

**Demo Platform** is a production-grade AWS infrastructure reference repository. It provisions a multi-environment EKS Kubernetes platform foundation using modular Terraform — VPC networking, the EKS control plane, Karpenter autoscaling infrastructure, and least-privilege IAM roles for Kubernetes workloads (IRSA).

This repository deliberately stops at the AWS boundary. It does **not** deploy Helm charts, Kubernetes manifests, or cluster add-ons — those belong to a separate GitOps repository reconciled by Argo CD. The Terraform outputs (IAM role ARNs, the OIDC provider, the Karpenter node role, and the interruption queue) are the contract between this infrastructure layer and that GitOps layer.

The goal of this repository is to serve as an educational and production reference for:

- **Infrastructure as Code** with modular, multi-environment Terraform
- **Platform Engineering** with Karpenter autoscaling infrastructure and IRSA
- **DevSecOps** with least-privilege IAM, private networking, and secret access patterns
- **AWS architecture** with isolated VPCs, EKS, and remote state management

> This repository is a generalized, company-agnostic reference implementation. All names, domains, and identifiers are placeholders — replace them with your own values before deploying.

---

## Architecture

<p align="center">
  <img src="assets/architecture.svg" alt="Platform Architecture" />
</p>

The platform follows a clear separation of concerns:

| Layer              | Tool             | Responsibility                                                        | In this repo? |
|--------------------|------------------|-----------------------------------------------------------------------|---------------|
| **Infrastructure** | Terraform        | VPC, EKS cluster, node groups, IAM roles, Karpenter AWS-side, SQS     | Yes           |
| **GitOps runtime** | Argo CD (external) | Helm charts, Kubernetes manifests, add-ons, workloads              | No            |
| **Autoscaling**    | Karpenter        | AWS-side IAM/roles/queue here; NodePool/EC2NodeClass in GitOps        | AWS side only |
| **Networking**     | AWS VPC          | Public/private/intra subnets, NAT gateway, subnet discovery tags      | Yes           |
| **Security**       | IRSA + IAM       | Pod identity roles, least-privilege policies, Secrets Manager access  | Yes           |

See [`docs/architecture.md`](docs/architecture.md) for the full design.

---

## What This Repository Provisions

Everything below is created by Terraform in this repository:

### Networking (`modules/vpc`)
- VPC with public, private, and intra subnets across multiple AZs
- NAT gateway for private egress
- Subnet discovery tags for Karpenter and AWS Load Balancer Controller

### EKS Cluster (`modules/eks`)
- EKS control plane (Kubernetes 1.34)
- Managed node group running Bottlerocket for the Karpenter controller
- Cluster and node security groups
- Configurable public API endpoint access with CIDR restrictions

### Karpenter Infrastructure (`modules/karpenter`)
- Karpenter controller IAM role
- Karpenter node IAM role (with SSM managed instance policy)
- SQS interruption queue for spot/health event handling
- EKS Pod Identity association for the controller

### IAM Roles for Service Accounts (`modules/irsa`)
- **EBS CSI Driver** IRSA role — scoped to `kube-system:ebs-csi-controller-sa`
- **AWS Load Balancer Controller** IRSA role — scoped to `kube-system:aws-load-balancer-controller`
- **External API mTLS** IRSA role — scoped to workload service accounts

### IAM Policies (`modules/iam`)
- Least-privilege policy for reading external API mTLS material from AWS Secrets Manager

### Security Groups (`modules/security`)
- Optional additional ingress rules for the cluster and node security groups

### Remote State (`bootstrap/backend`)
- S3 state bucket with versioning and SSE-KMS encryption
- DynamoDB lock table with point-in-time recovery
- Dedicated KMS key and alias

---

## What Lives in the GitOps Repository (Not Here)

This repository creates the AWS infrastructure and IAM roles. A separate GitOps repository, reconciled by Argo CD, would consume the Terraform outputs and deploy:

| Component                       | Uses Terraform output                          |
|---------------------------------|------------------------------------------------|
| Karpenter Helm chart + NodePool | `karpenter_node_iam_role_name`, `karpenter_queue_name` |
| AWS Load Balancer Controller    | `aws_load_balancer_controller_irsa_role_arn`   |
| EBS CSI Driver                  | `ebs_csi_irsa_role_arn`                        |
| External API mTLS workload      | `external_api_mtls_irsa_role_arn`              |
| Argo CD root application        | `cluster_name`, `cluster_endpoint`             |

An example Argo CD root `Application` is provided in [`examples/argocd/root-app.yaml`](examples/argocd/root-app.yaml) to show how the two layers connect.

---

## Repository Structure

```text
.
├── README.md                    # Project overview and quick start
├── LICENSE                      # MIT license
├── CONTRIBUTING.md              # How to contribute
├── CODE_OF_CONDUCT.md           # Community standards
├── MIGRATION.md                 # Safe state migration plan
├── docs/                        # In-depth documentation
│   ├── architecture.md
│   ├── networking.md
│   ├── security.md
│   ├── terraform.md
│   ├── gitops.md
│   ├── eks.md
│   ├── monitoring.md
│   ├── disaster-recovery.md
│   └── troubleshooting.md
├── assets/                      # Diagrams and logo assets
│   ├── logo.svg
│   └── architecture.svg
├── bootstrap/
│   └── backend/                 # S3, DynamoDB, KMS for remote state
├── modules/                     # Reusable Terraform modules
│   ├── vpc/
│   ├── eks/
│   ├── iam/
│   ├── irsa/
│   ├── karpenter/
│   └── security/
├── environments/                # Per-environment configurations
│   ├── dev/
│   ├── staging/
│   └── prod/
├── examples/                    # Worked configuration examples
│   ├── terraform/minimal-vpc-eks/
│   └── argocd/root-app.yaml
└── .github/                     # CI/CD and community files
    ├── workflows/
    ├── ISSUE_TEMPLATE/
    └── PULL_REQUEST_TEMPLATE.md
```

---

## Technologies

| Category        | Technology                                         | In this repo? |
|-----------------|----------------------------------------------------|---------------|
| Cloud           | AWS (EKS, VPC, IAM, S3, DynamoDB, KMS, Secrets Manager, SQS) | Yes |
| IaC             | Terraform ≥ 1.14, AWS provider 6.22.1             | Yes           |
| Container       | Kubernetes 1.34, Bottlerocket nodes                | Yes (EKS)     |
| Autoscaling     | Karpenter (AWS-side IAM, node role, SQS queue)     | Yes (AWS side)|
| Pod identity    | IRSA (IAM Roles for Service Accounts)              | Yes           |
| Remote state    | S3 backend, DynamoDB locking, KMS encryption       | Yes           |
| GitOps          | Argo CD                                            | Example only  |
| CI/CD           | GitHub Actions                                     | Yes           |

---

## Quick Start

### Prerequisites

- Terraform ≥ 1.14
- AWS CLI configured with credentials
- `kubectl` (for post-apply cluster access)

### 1. Bootstrap the Terraform backend

```bash
cd bootstrap/backend
terraform init
terraform apply
```

This creates the S3 state bucket, DynamoDB lock table, and KMS key.

### 2. Provision an environment

```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

### 3. Retrieve outputs for GitOps

```bash
terraform output
```

The outputs (`cluster_name`, IRSA role ARNs, Karpenter node role, queue name) are the values you wire into your GitOps repository.

### 4. Connect a GitOps repository (external)

After the cluster is up, install Argo CD and point it at your GitOps repo:

```bash
kubectl create namespace argocd
helm install argocd argo/argo-cd -n argocd
kubectl apply -f examples/argocd/root-app.yaml
```

Argo CD then deploys the Kubernetes add-ons and workloads using the IAM roles this repository created.

---

## Infrastructure Workflow

```text
Developer → Git commit → CI validation → Terraform plan → Review → Terraform apply → AWS
```

1. Infrastructure changes are made in `modules/` or `environments/`.
2. A pull request triggers `terraform fmt` and `terraform validate` in CI.
3. After review and merge, `terraform apply` provisions the change in the target environment.
4. Each environment maintains its own remote state file in the shared S3 backend.

See [`docs/terraform.md`](docs/terraform.md) for the full workflow and module reference.

---

## GitOps Workflow

```text
Git (source of truth) → Argo CD (reconciler) → Kubernetes cluster
```

1. All Kubernetes runtime components are declared in a separate GitOps repository.
2. Argo CD continuously reconciles cluster state to match Git.
3. Terraform (this repo) provisions AWS infrastructure and IAM roles; Argo CD owns everything inside the cluster.
4. The Terraform outputs are the contract between the two layers.

See [`docs/gitops.md`](docs/gitops.md) for the GitOps architecture and how outputs feed into it.

---

## Security

- **Least-privilege IAM** — every workload gets a scoped IRSA role, never the node instance profile
- **Private networking** — nodes run in private subnets; the API endpoint can be restricted by CIDR
- **KMS-encrypted state** — Terraform state is encrypted at rest with a dedicated KMS key
- **State locking** — DynamoDB prevents concurrent state writes
- **Secrets access pattern** — IAM policy grants scoped `secretsmanager:GetSecretValue` for mTLS material
- **No secrets in Git** — all sensitive values are references, never literals
- **Security groups** — cluster and node security groups with configurable ingress rules

See [`docs/security.md`](docs/security.md) for the security model and hardening checklist.

---

## CI/CD

GitHub Actions workflows automate:

- **Terraform formatting** — `terraform fmt -recursive -check` on every pull request
- **Terraform validation** — `terraform init` and `terraform validate` on every pull request
- **Documentation linting** — markdown linting on README and docs

See [`.github/workflows/`](.github/workflows/) for workflow definitions.

---

## Best Practices

- **Module separation** — each module has a single responsibility and no cross-module coupling
- **State isolation** — one state file per environment, never shared
- **IRSA over node IAM** — pods assume scoped roles, never the node instance profile
- **Karpenter over cluster autoscaler** — faster, simpler, bin-packing-aware provisioning
- **Version pinning** — Terraform, providers, and modules are pinned for reproducibility
- **No Helm/K8s in Terraform** — modules create AWS resources only; runtime is GitOps-managed
- **Naming conventions** — kebab-case for resources, snake_case for Terraform variables

---

## Future Improvements

- [ ] Add VPC flow logs
- [ ] Add EKS control plane logging configuration
- [ ] Add OPA Gatekeeper / Kyverno policy examples
- [ ] Add cost estimation with Infracost in CI
- [ ] Add a production-hardened example with multi-AZ NAT and restricted endpoint
- [ ] Add cross-region disaster recovery runbook
- [ ] Add a companion GitOps repository as a linked example
- [ ] Add `terraform plan` in CI (requires AWS credentials and remote state access)

---

## Learning Objectives

This repository is designed to teach and demonstrate:

1. How to structure multi-environment Terraform with reusable modules
2. How to split infrastructure (Terraform) from runtime (GitOps) responsibilities
3. How to implement IRSA for secure pod-to-AWS access
4. How to configure Karpenter AWS-side infrastructure for autoscaling
5. How to build a least-privilege IAM pattern for external API mTLS access via Secrets Manager
6. How to manage remote state with S3, DynamoDB locking, and KMS encryption
7. How to harden AWS infrastructure with private networking and scoped security groups

---

## Troubleshooting

See [`docs/troubleshooting.md`](docs/troubleshooting.md) for common issues and solutions.

Common questions:

- **`terraform plan` wants to replace the cluster** — see [`MIGRATION.md`](MIGRATION.md)
- **IRSA pod gets AccessDenied** — verify the service account annotation and trust policy
- **Karpenter nodes not joining** — check the node IAM role and `EC2NodeClass`

---

## Contributing

Contributions are welcome! Please read [`CONTRIBUTING.md`](CONTRIBUTING.md) and follow the [code of conduct](CODE_OF_CONDUCT.md).

---

## License

This project is licensed under the MIT License — see [`LICENSE`](LICENSE).
