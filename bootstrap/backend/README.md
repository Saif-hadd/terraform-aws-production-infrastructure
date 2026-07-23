# Terraform Backend Bootstrap

Creates or adopts the shared Terraform backend resources:

- S3 state bucket
- S3 versioning
- SSE-KMS encryption
- public access block
- DynamoDB lock table
- KMS key and alias

If the bucket or lock table already exists, import them before applying this bootstrap configuration. Do not run this with an S3 backend that depends on the same bucket until the bucket has been adopted safely.
