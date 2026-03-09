# =============================================================================
# Root Module: Multi-Cloud Deployment with Terraform (AWS & Azure)
#
# This section orchestrates the high-level deployment of infrastructure 
# by conditionally instantiating AWS and Azure submodules. The use of 
# toggle variables (`deploy_aws` and `deploy_azure`) makes it possible 
# to selectively provision resources in one or both clouds from the root module.
# =============================================================================

# -----------------------------------------------------------------------------
# AWS Module Block
# -----------------------------------------------------------------------------
# Instantiates AWS infrastructure via the local AWS module.
# - The `count` meta-argument uses the value of `var.deploy_aws` to determine 
#   if the AWS module should be deployed (1) or skipped (0).
#   * This enables conditional deployment without manual changes to this file.
# - `source` specifies the relative path to the AWS module.
module "aws" {
  source = "./modules/aws"        # Path to AWS module directory
  count  = var.deploy_aws ? 1 : 0 # Deploy if 'deploy_aws' is true
  aws_region = var.aws_region 
}

# -----------------------------------------------------------------------------
# Azure Module Block
# -----------------------------------------------------------------------------
# Instantiates Azure infrastructure using the local Azure module.
# - The `count` meta-argument toggles module instantiation based on `var.deploy_azure`.
#   * This allows for independent or simultaneous multi-cloud provisioning.
# - Passes resource group name (`rg_name`) and region (`location`) from root variables.
#   * These parameters are required to scope and regionally place all Azure resources.
module "azure" {
  source   = "./modules/azure"        # Path to Azure module directory
  count    = var.deploy_azure ? 1 : 0 # Deploy if 'deploy_azure' is true
  rg_name  = var.rg_name              # Azure Resource Group name
  location = var.location             # Azure region
}
