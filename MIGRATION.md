# Safe Terraform Migration Plan

This migration is designed to avoid EKS cluster replacement and avoid downtime.

## Critical Rules

- Do not run `terraform destroy`.
- Do not apply a plan that wants to replace the VPC, EKS cluster, node group, IAM roles, or security groups.
- Do not remove live Helm releases from the cluster during the Terraform migration.
- Remove old runtime resources from Terraform state with `terraform state rm`; do not destroy them.

## 1. Bootstrap Or Adopt The Backend

The backend block cannot create S3 versioning, KMS encryption, or DynamoDB locking. Those are managed in `bootstrap/backend`.

If the existing resources already exist, import them first:

```powershell
cd bootstrap/backend
terraform init
terraform import aws_s3_bucket.terraform_state demo-platform-terraform-state
terraform import aws_s3_bucket_public_access_block.terraform_state demo-platform-terraform-state
terraform import aws_s3_bucket_versioning.terraform_state demo-platform-terraform-state
terraform import aws_dynamodb_table.terraform_locks terraform-locks
terraform plan
```

If the plan is safe, apply it to enable versioning, KMS encryption, and lock-table hardening.

## 2. Copy Existing State To The Prod Environment Key

The old state key was:

```text
demo-platform/eks/terraform.tfstate
```

The new prod key is:

```text
demo-platform/prod/eks/terraform.tfstate
```

Copy the state object before initializing the prod environment:

```powershell
aws s3 cp s3://demo-platform-terraform-state/demo-platform/eks/terraform.tfstate s3://demo-platform-terraform-state/demo-platform/prod/eks/terraform.tfstate
```

Keep the old object until the migration is fully verified.

## 3. Initialize Prod Environment

```powershell
cd environments/prod
terraform init
terraform state list
```

## 4. Remove Runtime Components From Terraform State

These resources must stay live in Kubernetes, but Terraform must stop managing them.

```powershell
terraform state rm 'helm_release.karpenter'
terraform state rm 'helm_release.aws_load_balancer_controller'
terraform state rm 'helm_release.secrets_store_csi'
terraform state rm 'helm_release.secrets_store_csi_aws'
terraform state rm 'aws_eks_addon.ebs_csi'
```

The old EKS module also managed core add-ons. If they are present in state, remove them too:

```powershell
terraform state rm 'module.eks.aws_eks_addon.this["coredns"]'
terraform state rm 'module.eks.aws_eks_addon.this["eks-pod-identity-agent"]'
terraform state rm 'module.eks.aws_eks_addon.this["kube-proxy"]'
terraform state rm 'module.eks.aws_eks_addon.this["vpc-cni"]'
```

Verify with:

```powershell
terraform state list | Select-String 'helm_release|aws_eks_addon'
```

The command should return nothing.

## 5. Let Moved Blocks Re-home Infrastructure State

`environments/prod/moved.tf` maps the old root addresses into the new module wrappers.

Run:

```powershell
terraform plan
```

Expected result:

- no EKS cluster replacement
- no VPC replacement
- no node group replacement
- no IAM role replacement
- no Helm resources in the plan
- only safe in-place metadata drift, if any

Stop if Terraform wants to destroy or replace core infrastructure.

## 6. Move Runtime Components To Argo CD

Create Argo CD Applications for:

- Karpenter Helm chart
- Karpenter NodePool and EC2NodeClass
- AWS Load Balancer Controller Helm chart
- Secrets Store CSI Driver Helm chart
- AWS Secrets Store CSI provider chart
- EBS CSI Driver chart or managed add-on equivalent outside Terraform
- CoreDNS, kube-proxy, VPC CNI, and EKS Pod Identity Agent ownership policy

Use the Terraform outputs from prod:

```powershell
terraform output karpenter_queue_name
terraform output karpenter_node_iam_role_name
terraform output aws_load_balancer_controller_irsa_role_arn
terraform output ebs_csi_irsa_role_arn
terraform output external_api_mtls_irsa_role_arn
```

## 7. Apply Only After Verification

Only apply after a clean plan:

```powershell
terraform apply
```

Then verify:

```powershell
aws eks describe-cluster --name demo-platform-prod-eks --region eu-south-2
kubectl get nodes
kubectl get pods -A
```
