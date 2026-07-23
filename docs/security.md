# Security

This document covers the security model, IAM strategy, secret management, and hardening checklist for Demo Platform.

## IAM Strategy

### Least Privilege

Every Kubernetes workload that needs AWS access gets its own IAM role via **IRSA** (IAM Roles for Service Accounts). The node instance profile is never used for application-level permissions.

| Workload                  | IRSA Role                          | Policy                         |
|---------------------------|------------------------------------|--------------------------------|
| EBS CSI Controller        | `<name>-ebs-csi-*`                 | AWS-managed EBS CSI policy     |
| AWS Load Balancer Controller | `<name>-alb-*`                 | AWS-managed ALB controller policy |
| External API mTLS workload| `<name>-external-api-mtls-*`       | Custom Secrets Manager read    |

### IRSA Trust

IRSA roles trust the EKS OIDC provider for a specific namespace:service-account pair. A role created for `kube-system:ebs-csi-controller-sa` cannot be assumed by any other service account.

### Karpenter Node Role

The Karpenter node IAM role is created by Terraform and referenced by the Argo CD-managed `EC2NodeClass`. It includes `AmazonSSMManagedInstanceCore` for SSM access. Workload-level permissions are always via IRSA, never the node role.

## Secret Management

### AWS Secrets Manager + Secrets Store CSI

External API mTLS certificates are stored in AWS Secrets Manager and mounted into pods via the Secrets Store CSI Driver:

1. Terraform creates an IAM policy allowing `secretsmanager:GetSecretValue` for the mTLS secret ARNs.
2. An IRSA role is created and the policy is attached.
3. Argo CD deploys the Secrets Store CSI Driver and a `SecretProviderClass` that references the secret.
4. Pods mount the secret volume and use the certificates for mTLS to the external API.

No secret values are ever stored in Git or in Kubernetes `Secret` objects.

### Terraform State Security

- State is stored in S3 with **SSE-KMS encryption** using a dedicated KMS key.
- **Versioning** is enabled on the state bucket for point-in-time recovery.
- **DynamoDB locking** prevents concurrent state writes.
- Public access to the state bucket is fully blocked.

## Hardening Checklist

- [ ] Restrict `endpoint_public_access_cidrs` to corporate CIDRs (or disable public access)
- [ ] Set `single_nat_gateway = false` in prod for multi-AZ HA
- [ ] Enable VPC flow logs
- [ ] Enable EKS control plane logging (api, audit, authenticator)
- [ ] Restrict the node security group to only required ports
- [ ] Use Bottlerocket or AL2023 node AMIs for a hardened OS
- [ ] Enforce pod security standards (restricted baseline)
- [ ] Add OPA Gatekeeper or Kyverno admission policies
- [ ] Rotate the KMS key periodically
- [ ] Enable AWS GuardDuty and Security Hub

## What Is Not Included

This reference does not include:

- NetworkPolicies (belong in the GitOps repo)
- OPA/Kyverno policies (belong in the GitOps repo)
- AWS WAF (configure on the ALB via GitOps or separately)
- Service mesh (Istio/Linkerd) — can be added via GitOps

These omissions are intentional to keep the Terraform/infrastructure boundary clean.
