# -----------------------------------------------------------------------------
# S3 Bucket for Terraform Remote State
#
# This file provisions a secure S3 bucket to store Terraform state remotely,
# including:
#   - The S3 bucket itself
#   - Versioning for rollback of previous state versions
#   - Public access blocking (state must never be public)
#   - Server-side encryption at rest
# -----------------------------------------------------------------------------

# Core S3 bucket that will hold the Terraform state file.
resource "aws_s3_bucket" "terraform_state" {
  bucket = "multi-cloud-tf-state-19"

  tags = { project = "multi-cloud-demo" }
}

# Enable versioning so you can roll back to previous versions of the state file.
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Block all forms of public access to the state bucket.
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable encryption at rest for all objects in the bucket.
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}