terraform {
  backend "s3" {
    bucket         = "demo-platform-terraform-state"
    key            = "demo-platform/dev/eks/terraform.tfstate"
    region         = "eu-south-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
    kms_key_id     = "alias/demo-platform-terraform-state"
  }
}
