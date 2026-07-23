terraform {
  required_version = ">= 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.22.1"
    }
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "../../../modules/vpc"

  name     = var.name
  vpc_cidr = var.vpc_cidr

  tags = {
    Project   = "demo-platform"
    ManagedBy = "terraform"
  }
}

module "eks" {
  source = "../../../modules/eks"

  name               = var.name
  kubernetes_version = var.kubernetes_version

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    default = {
      ami_type       = "BOTTLEROCKET_x86_64"
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 2
      desired_size   = 1
    }
  }

  tags = {
    Project   = "demo-platform"
    ManagedBy = "terraform"
  }
}

variable "name" {
  type    = string
  default = "demo-platform-example-eks"
}

variable "region" {
  type    = string
  default = "eu-south-2"
}

variable "vpc_cidr" {
  type    = string
  default = "10.90.0.0/16"
}

variable "kubernetes_version" {
  type    = string
  default = "1.34"
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
