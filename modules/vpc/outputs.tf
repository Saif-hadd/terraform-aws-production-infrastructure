output "vpc_id" {
  description = "VPC ID."
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block."
  value       = module.vpc.vpc_cidr_block
}

output "availability_zones" {
  description = "Availability zones used by the VPC."
  value       = local.availability_zones
}

output "private_subnets" {
  description = "Private subnet IDs."
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "Public subnet IDs."
  value       = module.vpc.public_subnets
}

output "intra_subnets" {
  description = "Intra subnet IDs."
  value       = module.vpc.intra_subnets
}
