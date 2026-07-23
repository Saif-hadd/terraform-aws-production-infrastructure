# Minimal VPC + EKS Example

A single-file example that provisions a VPC and EKS cluster using the reusable modules from this repository.

```bash
terraform init
terraform plan
terraform apply
```

Adjust `name`, `region`, `vpc_cidr`, and `kubernetes_version` variables as needed.
