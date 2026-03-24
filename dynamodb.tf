
# -----------------------------------------------------------------------------
# DynamoDB Table for Terraform State Locking
#
# This table is used by the S3 backend to implement state locking so that only
# one `terraform apply` / `terraform plan` can modify the state at a time.
#
# Key details:
# - `billing_mode = "PAY_PER_REQUEST"` keeps costs low for infrequent usage.
# - `hash_key = "LockID"` is the partition key used by Terraform to manage locks.
# - `lifecycle.prevent_destroy = true` protects the table from accidental deletion.
# -----------------------------------------------------------------------------
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "multi-cloud-tf-locks" # Table name referenced by the S3 backend
  billing_mode = "PAY_PER_REQUEST"      # On-demand capacity; no need to manage RCU/WCU
  hash_key     = "LockID"               # Partition key for the lock item

  attribute {
    name = "LockID"
    type = "S" # String type attribute used as the primary key
  }

  lifecycle {
    prevent_destroy = true # Avoid accidental removal of the lock table
  }

  tags = {
    project = "multi-cloud-demo" # Tag to identify this table as part of the demo
  }
}