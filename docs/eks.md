# Amazon EKS

This document covers the EKS cluster configuration, node groups, Karpenter integration, and add-on strategy.

## Cluster Configuration

| Setting                              | Default       | Notes                                |
|--------------------------------------|---------------|--------------------------------------|
| Kubernetes version                   | `1.34`        | Pinned per environment               |
| Endpoint public access               | `true`        | Restrict CIDRs in production         |
| Cluster creator admin permissions    | `true` (dev/staging) | Allows Terraform caller to manage cluster |
| Node AMI                             | Bottlerocket  | Hardened, minimal OS                 |
| VPC CNI                              | Default       | VPC-native pod IPs                   |

## Managed Node Groups

Each environment deploys a single managed node group for the Karpenter controller:

```hcl
eks_managed_node_groups = {
  karpenter = {
    ami_type       = "BOTTLEROCKET_x86_64"
    instance_types = ["t3.medium"]
    min_size       = 1
    max_size       = 1
    desired_size   = 1
    labels = {
      "karpenter.sh/controller" = "true"
    }
  }
}
```

This node group is intentionally small and fixed — it only runs the Karpenter controller. All workload nodes are provisioned dynamically by Karpenter.

## Karpenter

Karpenter provides demand-based node autoscaling. The AWS-side infrastructure is created by Terraform; the Kubernetes-side configuration is managed by Argo CD.

### Terraform owns (this repo)

- Karpenter controller IAM role
- Karpenter node IAM role
- SQS interruption queue
- EKS Pod Identity association

### Argo CD owns (GitOps repo)

- Karpenter Helm chart
- `NodePool` — defines scheduling constraints and taints
- `EC2NodeClass` — defines AMI family, subnet selector, and security group

The `EC2NodeClass` references:

- The Karpenter node IAM role name (Terraform output: `karpenter_node_iam_role_name`)
- Private subnets (discovered via `karpenter.sh/discovery` tag)
- The node security group (Terraform output)

## Add-On Strategy

Core EKS add-ons (CoreDNS, kube-proxy, VPC CNI, EKS Pod Identity Agent) were previously managed by the EKS module. They have been moved out of Terraform state to be owned by Argo CD. See [`MIGRATION.md`](../MIGRATION.md) for the state removal procedure.

| Add-on                  | IRSA role (Terraform)      | Chart (GitOps)                |
|-------------------------|----------------------------|-------------------------------|
| EBS CSI Driver          | `<name>-ebs-csi-*`         | `ebs-csi-driver`              |
| AWS Load Balancer Ctrl  | `<name>-alb-*`             | `aws-load-balancer-controller`|
| Secrets Store CSI       | — (uses external API role) | `secrets-store-csi-driver`    |
| External API mTLS       | `<name>-external-api-mtls-*`| Custom workload              |

## Upgrading Kubernetes

1. Update `kubernetes_version` in the target environment's `terraform.tfvars`
2. Run `terraform plan` — verify only the cluster version changes
3. Apply — EKS performs a controlled control-plane upgrade
4. Upgrade node groups and Karpenter `EC2NodeClass` AMI family via GitOps
5. Drain and recycle old nodes

## Pod Identity

The platform uses **EKS Pod Identity** for the Karpenter controller association (preferred over legacy OIDC IRSA where supported). Other workloads continue to use OIDC-based IRSA via the `irsa` module.
