terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

module "irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.0.0"

  role_name        = var.role_name
  role_name_prefix = var.role_name_prefix

  attach_ebs_csi_policy                  = var.attach_ebs_csi_policy
  attach_load_balancer_controller_policy = var.attach_load_balancer_controller_policy

  oidc_providers = {
    this = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = var.namespace_service_accounts
    }
  }

  tags = var.tags
}
