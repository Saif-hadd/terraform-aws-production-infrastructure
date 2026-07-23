moved {
  from = module.vpc
  to   = module.vpc.module.vpc
}

moved {
  from = module.eks
  to   = module.eks.module.eks
}

moved {
  from = module.karpenter
  to   = module.karpenter.module.karpenter
}

moved {
  from = module.ebs_csi_irsa
  to   = module.ebs_csi_irsa.module.irsa
}

moved {
  from = module.aws_load_balancer_controller_irsa
  to   = module.aws_load_balancer_controller_irsa.module.irsa
}

moved {
  from = module.external_api_mtls_irsa
  to   = module.external_api_mtls_irsa.module.irsa
}

moved {
  from = aws_iam_policy.external_api_mtls_read
  to   = module.iam.aws_iam_policy.external_api_mtls_read
}
