# -------------------------------------------------------------------
# Input Variables for Azure Module
# These variables allow customization and reusability of the module.
# -------------------------------------------------------------------

# Name of the Azure Resource Group to create (optional: defaults can be set in main.tf if desired)
variable "rg_name" {
  description = "Name of the Azure Resource Group to create"
  type        = string
}

# Azure location/region where resources will be deployed (e.g., 'eastus', 'westeurope')
variable "location" {
  description = "Azure location where the resources will be deployed"
  type        = string
}