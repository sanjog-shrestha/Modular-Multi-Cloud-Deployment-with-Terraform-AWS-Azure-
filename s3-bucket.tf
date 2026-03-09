# --- S3 Bucket for Terraform Remote State ---
resource "aws_s3_bucket" "terraform_state" {
  bucket = "multi-cloud-tf-state-19"

  tags = { project = "multi-cloud-demo" }
}

# --- Enable Versioning (so you can roll back state) ---
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# --- Block all public access (state files must never be public) ---
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# --- Enable encryption at rest ---
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}