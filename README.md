# Demo Platform - AWS EKS Infrastructure Reference

<p align="center">
  <img src="assets/logo.svg" alt="Demo Platform" width="120" />
</p>

<p align="center">
  A production-oriented AWS EKS infrastructure reference built with modular Terraform, multi-environment configuration, IRSA, and AWS-side Karpenter infrastructure.
</p>

<p align="center">
  <img alt="Terraform" src="https://img.shields.io/badge/Terraform-%3E%3D1.14-7B42BC?logo=terraform&logoColor=white" />
  <img alt="AWS EKS" src="https://img.shields.io/badge/AWS%20EKS-1.34-FF9900?logo=amazon-eks&logoColor=white" />
  <img alt="Kubernetes" src="https://img.shields.io/badge/Kubernetes-1.34-326CE5?logo=kubernetes&logoColor=white" />
  <img alt="Karpenter" src="https://img.shields.io/badge/Karpenter-AWS--side%20infra-00A9E0" />
  <img alt="License" src="https://img.shields.io/badge/License-MIT-green" />
</p>

---

## Overview

**Demo Platform** is an open-source reference repository for provisioning the AWS infrastructure layer of an EKS-based Kubernetes platform.

The repository uses Terraform to compose reusable modules for:

- VPC networking
- Amazon EKS clusters
- EKS managed node groups
- AWS-side Karpenter infrastructure
- IAM roles for Kubernetes service accounts
- A scoped Secrets Manager access policy for an external API mTLS pattern
- Optional additional security group ingress rules
- S3, DynamoDB, and KMS resources for Terraform remote state

This repository intentionally stops at the AWS infrastructure boundary. It does **not** deploy Helm releases, Kubernetes manifests, Kubernetes add-ons, monitoring stacks, or workloads. Those runtime components are expected to live in a separate GitOps repository reconciled by Argo CD.

The environment examples are useful as a platform engineering reference, but they are not hardened defaults for a live production account. For example, the committed `dev`, `staging`, and `prod` tfvars currently enable the public EKS API endpoint from `0.0.0.0/0`; restrict this before using the configuration beyond a demo or lab account.

## Architecture

The platform is split into two ownership layers:

| Layer | Owner | Responsibility | Implemented here |
|---|---|---|---|
| AWS infrastructure | Terraform | VPC, EKS, managed node groups, IAM, security groups, remote state | Yes |
| Karpenter AWS integration | Terraform | Controller IAM role, node IAM role, SQS interruption queue, Pod Identity association | Yes |
| Kubernetes runtime | External GitOps repo | Helm charts, add-ons, NodePools, workloads, monitoring | No |
| GitOps bootstrap example | Argo CD manifest | Example root `Application` with placeholder repo URL | Example only |

Terraform outputs provide the contract between this infrastructure repository and the external GitOps layer:

- `cluster_name`
- `cluster_endpoint`
- `oidc_provider_arn`
- `karpenter_queue_name`
- `karpenter_node_iam_role_name`
- `ebs_csi_irsa_role_arn`
- `aws_load_balancer_controller_irsa_role_arn`
- `external_api_mtls_irsa_role_arn`

See [`docs/architecture.md`](docs/architecture.md) for a deeper design overview.

## What This Repository Provisions

### Networking (`modules/vpc`)

- VPC per environment
- Public, private, and intra subnet tiers
- NAT gateway support, using one shared NAT gateway by default
- Public subnet tags for internet-facing load balancers
- Private subnet tags for internal load balancers and Karpenter discovery

### EKS (`modules/eks`)

- Amazon EKS control plane
- Configurable Kubernetes version, currently set to `1.34` in the environment tfvars
- Configurable public API endpoint access and allowed CIDRs
- EKS managed node groups, currently used for a small Bottlerocket Karpenter controller node group
- Cluster and node security group outputs
- OIDC provider output for IRSA

### Karpenter AWS-Side Infrastructure (`modules/karpenter`)

- Karpenter controller IAM role
- Karpenter node IAM role
- SQS interruption queue
- Optional EKS Pod Identity association, enabled by default
- Additional node role policies, including `AmazonSSMManagedInstanceCore` by default

The Karpenter Helm chart, `NodePool`, and `EC2NodeClass` are not managed here.

### IAM Roles For Service Accounts (`modules/irsa`)

- EBS CSI Driver IRSA role scoped to `kube-system:ebs-csi-controller-sa`
- AWS Load Balancer Controller IRSA role scoped to `kube-system:aws-load-balancer-controller`
- External API mTLS workload IRSA role scoped through environment variables

This module creates IAM roles only. It does not create Kubernetes ServiceAccounts.

### IAM Policies (`modules/iam`)

- A scoped IAM policy for reading external API mTLS material from AWS Secrets Manager
- Default resource scope based on the `demo-platform-external-api-mtls-*` secret name prefix, with support for explicit secret ARNs

### Security Groups (`modules/security`)

- Optional extra ingress rules for the EKS cluster security group
- Optional extra ingress rules for the EKS node security group
- No extra rules are created by default

### Remote State (`bootstrap/backend`)

- S3 bucket for Terraform state
- S3 versioning
- S3 public access block
- SSE-KMS encryption for state objects
- DynamoDB lock table with point-in-time recovery
- Dedicated KMS key and alias

## What Is Not Implemented Here

The following are intentionally outside this repository:

- Argo CD installation and lifecycle management
- Helm releases
- Kubernetes manifests
- Karpenter `NodePool` and `EC2NodeClass`
- EKS add-ons such as CoreDNS, kube-proxy, VPC CNI, and EBS CSI runtime installation
- Secrets Store CSI Driver deployment
- Prometheus, Grafana, Alertmanager, dashboards, and alert rules
- OPA Gatekeeper, Kyverno, NetworkPolicies, WAF, service mesh, Velero, and AWS Backup policies
- Terraform plan/apply automation with AWS credentials in CI

Some docs describe how these components fit into the intended GitOps architecture, but they are not provisioned by this repository.

## Repository Structure

```text
.
|-- README.md
|-- LICENSE
|-- CONTRIBUTING.md
|-- CODE_OF_CONDUCT.md
|-- MIGRATION.md
|-- assets/
|   |-- logo.svg
|   `-- architecture.svg
|-- bootstrap/
|   `-- backend/
|-- docs/
|   |-- architecture.md
|   |-- disaster-recovery.md
|   |-- eks.md
|   |-- gitops.md
|   |-- monitoring.md
|   |-- networking.md
|   |-- security.md
|   |-- terraform.md
|   `-- troubleshooting.md
|-- environments/
|   |-- dev/
|   |-- staging/
|   `-- prod/
|-- examples/
|   |-- argocd/root-app.yaml
|   `-- terraform/minimal-vpc-eks/
|-- modules/
|   |-- eks/
|   |-- iam/
|   |-- irsa/
|   |-- karpenter/
|   |-- security/
|   `-- vpc/
`-- .github/
    |-- workflows/
    |-- ISSUE_TEMPLATE/
    `-- PULL_REQUEST_TEMPLATE.md
```

## Technologies

| Category | Technology | Status |
|---|---|---|
| Cloud | AWS | Implemented |
| Kubernetes platform | Amazon EKS | Implemented |
| Infrastructure as Code | Terraform `>= 1.14.0` | Implemented |
| Terraform provider | HashiCorp AWS provider `= 6.22.1` | Implemented |
| Terraform modules | `terraform-aws-modules/vpc/aws` `6.0.0`, `terraform-aws-modules/eks/aws` `21.9.0`, `terraform-aws-modules/iam/aws` `5.0.0` | Implemented |
| Node OS | Bottlerocket managed node group | Configured in environment tfvars |
| Pod AWS access | OIDC-based IRSA for selected workloads | Implemented |
| Karpenter | AWS-side IAM, node role, SQS queue, Pod Identity association | Implemented |
| Remote state | S3 backend, DynamoDB locking, KMS encryption | Implemented |
| GitOps | Argo CD | Example manifest only |
| CI | GitHub Actions | Implemented for formatting, dev validation, and markdown linting |

## Quick Start

### Prerequisites

- Terraform `>= 1.14.0`
- AWS CLI configured with credentials for the target account
- `kubectl` for post-apply cluster access
- Helm, only if you want to install Argo CD manually

### 1. Bootstrap the Terraform backend

```bash
cd bootstrap/backend
terraform init
terraform plan
terraform apply
cd ../..
```

This creates the S3 state bucket, DynamoDB lock table, and KMS key used by the environment backends.

### 2. Provision an environment

Review and edit `environments/dev/terraform.tfvars` before applying. In particular, replace the open EKS API endpoint CIDR with a trusted CIDR range for any non-demo use.

```bash
cd environments/dev
terraform init
terraform plan
terraform apply
terraform output
```

### 3. Configure local cluster access

```bash
aws eks update-kubeconfig \
  --region eu-south-2 \
  --name "$(terraform output -raw cluster_name)"
```

### 4. Optionally bootstrap an external GitOps repository

The included Argo CD manifest is only an example. Before applying it, replace the placeholder `repoURL` in [`examples/argocd/root-app.yaml`](examples/argocd/root-app.yaml) with your real GitOps repository.

From the repository root:

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
kubectl create namespace argocd
helm install argocd argo/argo-cd -n argocd
kubectl apply -f examples/argocd/root-app.yaml
```

## Infrastructure Workflow

```text
Change Terraform -> Open PR -> CI fmt/validate -> Review -> terraform plan -> terraform apply
```

1. Make infrastructure changes in `modules/` or `environments/`.
2. Run `terraform fmt -recursive`.
3. Run `terraform init -backend=false` and `terraform validate` in the affected environment.
4. Run `terraform plan` with the real backend and review the diff.
5. Apply only after checking that Terraform is not replacing core infrastructure unexpectedly.
6. Pass Terraform outputs to the external GitOps repository as needed.

See [`docs/terraform.md`](docs/terraform.md) for module details and workflow guidance.

## GitOps Workflow

```text
Terraform outputs -> External GitOps repo -> Argo CD -> Kubernetes cluster
```

This repository provides the AWS resources and IAM contracts that a GitOps repository can consume. The GitOps repository is expected to own runtime objects such as Helm charts, controller ServiceAccounts, Karpenter `NodePool` resources, `EC2NodeClass` resources, workloads, and monitoring.

See [`docs/gitops.md`](docs/gitops.md) for the intended integration model.

## Security

- Nodes are placed in private subnets.
- The EKS public API endpoint is configurable, but the committed environment tfvars currently allow `0.0.0.0/0`.
- Workload IAM access is modeled with scoped IRSA roles instead of node instance profile permissions.
- Karpenter node roles include SSM access through `AmazonSSMManagedInstanceCore`.
- Terraform state is stored in S3 with versioning, public access block, and SSE-KMS encryption.
- DynamoDB state locking is enabled with point-in-time recovery.
- The external API mTLS IAM policy is scoped to Secrets Manager read actions for selected secret ARNs or a configured name prefix.
- No static AWS credentials or secret values are committed in the repository.

See [`docs/security.md`](docs/security.md) for the security model and hardening checklist.

## CI/CD

GitHub Actions currently provides:

- Terraform formatting checks with `terraform fmt -recursive -check -diff`
- Terraform initialization and validation for `environments/dev` only
- Markdown linting for README, contributing docs, `docs/**/*.md`, and `modules/**/*.md`

The CI does not currently run Terraform plans, apply infrastructure, or validate every environment.

See [`.github/workflows/`](.github/workflows/) for workflow definitions.

## Best Practices Demonstrated

- Modular Terraform with a small set of reusable infrastructure modules
- One environment directory per deployment target
- Separate remote state key per environment
- Clear split between Terraform-owned AWS resources and GitOps-owned Kubernetes runtime
- IRSA for selected workload AWS permissions
- Pinned provider and upstream module versions
- Migration guidance for moving runtime resources out of Terraform state
- Optional security group rule module for environment-specific ingress hardening

## Future Improvements

- Restrict committed non-demo endpoint CIDRs, especially for `prod`
- Add an explicit production-hardened example with per-AZ NAT gateways
- Add VPC flow logs
- Add EKS control plane logging configuration
- Expand CI validation to `staging`, `prod`, bootstrap, and examples
- Add `terraform plan` checks in CI for trusted AWS contexts
- Add policy-as-code examples for OPA Gatekeeper or Kyverno in a companion GitOps repository
- Add cost estimation with Infracost
- Add cross-region state replication guidance
- Add a real companion GitOps repository example
- Replace placeholder Argo CD `repoURL` before any real bootstrap

## Learning Objectives

This repository demonstrates:

1. How to structure Terraform for multiple AWS environments.
2. How to wrap mature upstream Terraform modules with local platform modules.
3. How to keep AWS infrastructure concerns separate from Kubernetes runtime concerns.
4. How to expose Terraform outputs as a contract for GitOps.
5. How to model OIDC-based IRSA roles for Kubernetes controllers and workloads.
6. How to configure AWS-side Karpenter infrastructure without managing its Kubernetes objects in Terraform.
7. How to bootstrap an encrypted, locked Terraform remote state backend.
8. How to document migration paths away from Terraform-managed runtime resources.

## Troubleshooting

See [`docs/troubleshooting.md`](docs/troubleshooting.md) for common operational checks.

Common starting points:

- If `terraform validate` reports missing modules, run `terraform init -backend=false` in the environment directory.
- If Terraform wants to replace the EKS cluster, stop and review [`MIGRATION.md`](MIGRATION.md).
- If an IRSA-enabled pod gets `AccessDenied`, verify the ServiceAccount annotation, OIDC trust policy, and policy attachment.
- If Karpenter nodes do not join, compare the GitOps `EC2NodeClass` role name with `terraform output karpenter_node_iam_role_name`.
- If the Argo CD example does not sync, replace the placeholder `repoURL` in `examples/argocd/root-app.yaml`.

## Contributing

Contributions are welcome. Please read [`CONTRIBUTING.md`](CONTRIBUTING.md) and follow the [code of conduct](CODE_OF_CONDUCT.md).

## License

This project is licensed under the MIT License. See [`LICENSE`](LICENSE).
