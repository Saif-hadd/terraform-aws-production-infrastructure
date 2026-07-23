terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  availability_zones = var.availability_zones == null ? slice(data.aws_availability_zones.available.names, 0, var.az_count) : var.availability_zones

  default_public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  default_private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    "karpenter.sh/discovery"          = var.name
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.0.0"

  name = var.name
  cidr = var.vpc_cidr

  azs             = local.availability_zones
  private_subnets = [for index, az in local.availability_zones : cidrsubnet(var.vpc_cidr, var.private_subnet_newbits, index)]
  public_subnets  = [for index, az in local.availability_zones : cidrsubnet(var.vpc_cidr, var.public_subnet_newbits, index + var.public_subnet_offset)]
  intra_subnets   = [for index, az in local.availability_zones : cidrsubnet(var.vpc_cidr, var.intra_subnet_newbits, index + var.intra_subnet_offset)]

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  public_subnet_tags  = merge(local.default_public_subnet_tags, var.public_subnet_tags)
  private_subnet_tags = merge(local.default_private_subnet_tags, var.private_subnet_tags)

  tags = var.tags
}
