# Troubleshooting

Common issues and their solutions.

## Terraform

### `terraform plan` wants to replace the EKS cluster

This usually means a field was changed that forces replacement. Check:

1. Did `name` or `kubernetes_version` change? (forces replacement)
2. Did the VPC or subnet IDs change? (forces replacement)
3. Are you running against the correct state file?

For safe migrations, follow [`MIGRATION.md`](../MIGRATION.md). **Never apply a plan that replaces core infrastructure without explicit approval.**

### State lock errors

```
Error: Failed to save state: ConditionalCheckFailedException
```

Another Terraform process holds the lock. Options:

1. Wait for the other process to finish.
2. If the lock is stale (crashed process), force-unlock:

```bash
terraform force-unlock <lock-id>
```

Use `force-unlock` only when you are certain no other Terraform process is running.

### Provider version mismatch

```
Error: Incompatible provider version
```

Run `terraform init -upgrade` to align with the pinned versions in `versions.tf`. Do not manually edit `.terraform.lock.hcl`.

## EKS and Kubernetes

### IRSA pod gets `AccessDenied`

1. Verify the ServiceAccount is annotated with the correct role ARN:

```bash
kubectl get sa <sa-name> -n <namespace> -o yaml
```

2. Verify the IAM role trust policy includes the correct OIDC provider and service account.
3. Verify the IAM policy is attached to the role.
4. Check that the pod is actually using the annotated ServiceAccount.

### Karpenter nodes not joining

1. Check the `EC2NodeClass` references the correct node IAM role:

```bash
kubectl get ec2nodeclass <name> -o yaml
```

2. Verify the role name matches the Terraform output:

```bash
terraform output karpenter_node_iam_role_name
```

3. Check subnet tags — private subnets must have `karpenter.sh/discovery = <cluster-name>`.
4. Check Karpenter controller logs:

```bash
kubectl logs -l app.kubernetes.io/name=karpenter -n karpenter
```

### EBS CSI volume stuck pending

1. Verify the EBS CSI controller is running.
2. Check the IRSA role ARN in the ServiceAccount annotation.
3. Verify the `StorageClass` references the correct provisioner (`ebs.csi.aws.com`).

### Argo CD application stuck `OutOfSync`

1. Check the repo URL and path in the `Application` spec.
2. Verify the GitOps repo has the expected files at the target revision.
3. Check Argo CD has credentials to access a private repo.
4. Look at the sync error in the Argo CD UI or:

```bash
kubectl get application <name> -n argocd -o yaml
```

## Networking

### Load balancer not created

1. Verify the AWS Load Balancer Controller is running.
2. Check the IRSA role is attached to the controller ServiceAccount.
3. Verify the Ingress has the correct annotations (`kubernetes.io/ingress.class: alb`).
4. Check subnet tags — public subnets need `kubernetes.io/role/elb = 1`.

### Pod cannot reach external API (mTLS)

1. Verify the `SecretProviderClass` is synced and the secret volume is mounted.
2. Check the pod has the correct certificate files:

```bash
kubectl exec <pod> -- ls /mnt/mtls
```

3. Verify the IRSA role has `secretsmanager:GetSecretValue` for the secret ARN.
4. Check the external API endpoint and certificate SAN match.
