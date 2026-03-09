
# -----------------------------------------------------------------------------
# Remote Backend Configuration (S3)
#
# This section configures Terraform to store its state remotely in an S3 bucket.
# Benefits:
#   - Centralized state for team collaboration
#   - Safer than local state files that can be accidentally deleted or corrupted
#   - Enables state locking (when combined with DynamoDB) to prevent race conditions
# Adjust the bucket, key, and region according to your AWS environment.
# -----------------------------------------------------------------------------

terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100.0"
    }  
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.117.1"
    }
  }

  backend "s3" {
    bucket = "multi-cloud-tf-state-19" # S3 bucket where the Terraform state file is stored
    key    = "terraform.tfstate"       # Path/key of the state file within the bucket
    region = "eu-west-2"               # AWS region where the S3 bucket resides
  }
}