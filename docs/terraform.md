# Terraform

This document describes the Terraform structure, module reference, workflow, and conventions.

## Directory Layout

```text
.
├── bootstrap/
│   └── backend/             # S3 + DynamoDB + KMS for remote state
├── modules/                 # Reusable, single-responsibility modules
│   ├── vpc/
│   ├── eks/
│   ├── iam/
│   ├── irsa/
│   ├── karpenter/
│   └── security/
└── environments/            # One directory per environment
    ├── dev/
    ├── staging/
    └── prod/
```

Each environment directory contains:

| File              | Purpose                                                |
|-------------------|--------------------------------------------------------|
| `main.tf`         | Module composition and resource wiring                 |
| `variables.tf`    | Input variable declarations                            |
| `terraform.tfvars`| Environment-specific values                             |
| `outputs.tf`      | Useful outputs for GitOps bootstrapping                |
| `backend.tf`      | Remote state configuration (S3 + DynamoDB + KMS)       |
| `providers.tf`    | AWS provider with default tags                         |
| `versions.tf`     | Terraform and provider version constraints             |

## Module Reference

### `vpc`

Creates the AWS network foundation. Wraps `terraform-aws-modules/vpc/aws` v6.0.0.

| Input                  | Description                                  | Default |
|------------------------|----------------------------------------------|---------|
| `name`                 | VPC name and discovery tag value             | —       |
| `vpc_cidr`             | VPC CIDR block                               | —       |
| `az_count`             | Number of AZs (when not explicit)            | `3`     |
| `enable_nat_gateway`   | Create NAT gateways                          | `true`  |
| `single_nat_gateway`   | One shared NAT gateway                       | `true`  |

Outputs: `vpc_id`, `private_subnets`, `public_subnets`, `intra_subnets`, `availability_zones`.

### `eks`

Creates the EKS control plane and managed node groups. Wraps `terraform-aws-modules/eks/aws` v21.9.0.

| Input                                | Description                          | Default       |
|--------------------------------------|--------------------------------------|---------------|
| `name`                               | Cluster name                         | —             |
| `kubernetes_version`                 | EKS version                          | —             |
| `vpc_id` / `subnet_ids`              | Network wiring                       | —             |
| `endpoint_public_access`             | Public API endpoint                  | `true`        |
| `endpoint_public_access_cidrs`       | Allowed CIDRs                        | `["0.0.0.0/0"]` |
| `eks_managed_node_groups`            | Node group definitions               | `{}`          |

Outputs: `cluster_name`, `cluster_endpoint`, `oidc_provider_arn`, `node_security_group_id`.

### `irsa`

Creates an IAM role trusted by a Kubernetes service account via OIDC.

| Input                                  | Description                          |
|----------------------------------------|--------------------------------------|
| `role_name_prefix`                     | Role name prefix                     |
| `oidc_provider_arn`                    | EKS OIDC provider ARN                |
| `namespace_service_accounts`           | Allowed `namespace:serviceaccount`   |
| `attach_ebs_csi_policy`                | Attach AWS EBS CSI managed policy    |
| `attach_load_balancer_controller_policy` | Attach AWS ALB controller policy   |

### `iam`

Creates least-privilege IAM policies for workloads.

Currently provides the **external API mTLS read** policy for AWS Secrets Manager.

### `karpenter`

Creates the AWS-side Karpenter infrastructure: controller IAM role, node IAM role, and SQS interruption queue. Wraps the Karpenter submodule of `terraform-aws-modules/eks/aws`.

### `security`

Adds optional security group ingress rules to the cluster and node security groups. Creates nothing by default.

## Remote State

All environments use the same S3 backend with per-environment state keys:

```hcl
backend "s3" {
  bucket         = "demo-platform-terraform-state"
  key            = "demo-platform/<env>/eks/terraform.tfstate"
  region         = "eu-south-2"
  dynamodb_table = "terraform-locks"
  encrypt        = true
  kms_key_id     = "alias/demo-platform-terraform-state"
}
```

## Workflow

```text
1. Edit modules/ or environments/
2. terraform fmt -recursive
3. cd environments/<env> && terraform init && terraform plan
4. Review the plan — stop if core infrastructure is replaced
5. terraform apply
6. Use terraform output to feed GitOps values
```

## Conventions

- **Resource names:** kebab-case (e.g., `demo-platform-dev-eks`)
- **Variables:** snake_case with `description`, `type`, and `default`
- **Tags:** every resource gets `Project`, `Environment`, `ManagedBy` via `default_tags`
- **Version pinning:** provider and module versions are pinned
- **No Helm/K8s in modules:** modules create AWS resources only
