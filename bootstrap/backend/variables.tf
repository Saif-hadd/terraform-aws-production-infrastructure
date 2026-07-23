variable "region" {
  description = "AWS region for Terraform state resources."
  type        = string
  default     = "eu-south-2"
}

variable "state_bucket_name" {
  description = "S3 bucket used for Terraform remote state."
  type        = string
  default     = "demo-platform-terraform-state"
}

variable "lock_table_name" {
  description = "DynamoDB table used for Terraform state locking."
  type        = string
  default     = "terraform-locks"
}

variable "kms_alias_name" {
  description = "KMS alias for Terraform state encryption."
  type        = string
  default     = "alias/demo-platform-terraform-state"
}

variable "tags" {
  description = "Tags for backend resources."
  type        = map(string)
  default = {
    Project     = "demo-platform"
    Environment = "shared"
    ManagedBy   = "terraform"
    Component   = "terraform-state"
  }
}
