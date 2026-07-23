environment = "staging"
project     = "demo-platform"
name        = "demo-platform-staging-eks"
region      = "eu-south-2"

vpc_cidr           = "10.20.0.0/16"
kubernetes_version = "1.34"

endpoint_public_access       = true
endpoint_public_access_cidrs = ["0.0.0.0/0"]

enable_cluster_creator_admin_permissions = true

eks_managed_node_groups = {
  karpenter = {
    ami_type       = "BOTTLEROCKET_x86_64"
    instance_types = ["t3.medium"]

    min_size     = 1
    max_size     = 1
    desired_size = 1

    labels = {
      "karpenter.sh/controller" = "true"
    }
  }
}

external_api_mtls_namespace_service_accounts = [
  "staging:external-api-mtls-sa",
  "staging:staging-external-api-mtls-sa"
]

tags = {
  Owner = "platform"
}
