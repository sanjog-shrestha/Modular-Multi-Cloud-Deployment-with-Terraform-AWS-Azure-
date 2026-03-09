# -----------------------------------------------------------------------------
# Provider Configuration
#
# This file configures the cloud providers used in the multi-cloud deployment:
#   - AWS provider for resources in Amazon Web Services
#   - AzureRM provider for resources in Microsoft Azure
# Regions/locations are controlled via variables so they can be changed centrally.
# -----------------------------------------------------------------------------

# AWS provider: region is taken from the root variable `aws_region`.
provider "aws" {
  region = var.aws_region
}

# Azure provider: `features {}` is required to enable the AzureRM provider.
provider "azurerm" {
  features {}
}