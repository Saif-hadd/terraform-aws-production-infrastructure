# Disaster Recovery

This document outlines the disaster recovery strategy, backup procedures, and recovery runbooks for Demo Platform.

## Recovery Objectives

| Metric       | Target       | Notes                                  |
|--------------|--------------|----------------------------------------|
| RPO (data)   | Varies by workload | Depends on application backup strategy |
| RTO (infra)  | < 2 hours    | Full environment rebuild from Terraform |
| RTO (state)  | < 30 minutes | Restore Terraform state from S3 versioning |

## Backup Strategy

### Terraform State

- **S3 versioning** is enabled on the state bucket — every state write creates a new version.
- To restore a previous state version:

```bash
aws s3api list-object-versions \
  --bucket demo-platform-terraform-state \
  --prefix demo-platform/prod/eks/terraform.tfstate

# Copy a previous version back as the current version
aws s3api get-object \
  --bucket demo-platform-terraform-state \
  --key demo-platform/prod/eks/terraform.tfstate \
  --version-id <version-id> \
  restored.tfstate

aws s3 cp restored.tfstate \
  s3://demo-platform-terraform-state/demo-platform/prod/eks/terraform.tfstate
```

- The state bucket has SSE-KMS encryption and a blocked public access policy.

### DynamoDB Lock Table

- **Point-in-time recovery (PITR)** is enabled on the lock table.
- The lock table is ephemeral — it can be recreated from the bootstrap Terraform if lost.

### KMS Key

- The KMS key has a 30-day deletion window, providing a grace period for recovery.
- Key rotation is enabled.

### Kubernetes Persistent Volumes

- EBS volumes managed by the EBS CSI driver support AWS EBS snapshots.
- Schedule snapshots via AWS Backup or a Velero deployment (GitOps-managed).
- Snapshot policies belong in the GitOps repository, not Terraform.

## Recovery Runbooks

### Scenario 1: Terraform state corruption

1. List state object versions in S3 (see above).
2. Restore the last known-good version.
3. Run `terraform init` and `terraform plan` — verify the plan shows no destructive changes.
4. Apply only if the plan is clean.

### Scenario 2: Environment rebuild from scratch

1. Bootstrap the backend if needed (`bootstrap/backend`).
2. Run `terraform init` + `terraform apply` in the target environment.
3. Reinstall Argo CD and point it at the GitOps repo.
4. Argo CD reconciles all runtime components from Git.
5. Restore application data from EBS snapshots or application backups.

### Scenario 3: EKS control plane failure

1. Check AWS Health Dashboard for regional events.
2. If the control plane is unrecoverable, rebuild the cluster via Terraform.
3. Argo CD redeploys all workloads automatically once the new cluster is registered.

### Scenario 4: Accidental resource deletion

1. Identify the deleted resource from `terraform plan` output.
2. Run `terraform apply` to recreate the resource.
3. For Kubernetes resources, Argo CD self-heals from Git automatically.

## Multi-AZ and HA

- EKS control plane runs across multiple AZs by default.
- For production HA, set `single_nat_gateway = false` to deploy NAT gateways in each AZ.
- Karpenter spreads nodes across AZs based on the `NodePool` topology spread constraints.
- Stateless workloads should run with multiple replicas across AZs.

## What This Reference Does Not Include

- Application-level backup/restore (depends on the workload)
- Cross-region replication (can be added with S3 cross-region replication for state)
- Velero integration (belongs in the GitOps repo)
- Database backups (managed at the application or RDS layer)

## Future Improvements

- [ ] Add S3 cross-region replication for the state bucket
- [ ] Add a Velero deployment example in the GitOps repo
- [ ] Add AWS Backup policies for EBS volumes
- [ ] Document a cross-region failover runbook
- [ ] Add Infracost to CI for cost visibility
