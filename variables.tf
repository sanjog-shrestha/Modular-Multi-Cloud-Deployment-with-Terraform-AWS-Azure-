# -----------------------------------------------------------------------------
# Variable Definitions for Multi-Cloud Deployment with Terraform: AWS & Azure
#
# This file declares essential variables for modular deployments in AWS and Azure.
# Adjust the following variables to control cloud selection and foundational infrastructure parameters.
# -----------------------------------------------------------------------------

# -----------------------------
# AWS REGION
# -----------------------------
# The AWS region where all resources will be deployed.
# Change the 'default' value to deploy to a different AWS region.
variable "aws_region" {
  default = "eu-west-2"
}

# -----------------------------
# AZURE LOCATION
# -----------------------------
# The Azure location/region for resource deployment.
# Change the 'default' to target a different Azure region.
variable "location" {
  type    = string
  default = "UK South"
}

variable "rg_name" {
  type    = string
  default = "multi-cloud-rg"
}

# -----------------------------
# AWS Module Deployment Toggle
# -----------------------------
# Set to 'true' to enable AWS module resource creation, or 'false' to skip AWS deployment.
variable "deploy_aws" {
  default = true
}

# -----------------------------
# Azure Module Deployment Toggle
# -----------------------------
# Set to 'true' to enable Azure module resource creation, or 'false' to skip Azure deployment.
variable "deploy_azure" {
  default = true
}

