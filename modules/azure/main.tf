# -----------------------------------------------------------------------------
# Azure Resource Group: Logical grouping container for all Azure resources.
# This will allow us to manage permissions, location, and lifecycle for all Azure objects in this deployment.
# -----------------------------------------------------------------------------
resource "azurerm_resource_group" "main" {
  name     = var.rg_name           # Group name for all Azure resources, sourced from input variable
  location = var.location          # Azure region, provided as module input variable
}

# -----------------------------------------------------------------------------
# Azure Virtual Network (VNet): Provides network isolation and topology control.
# - Defines the internal IP address space for all Azure subnets and resources
# -----------------------------------------------------------------------------
resource "azurerm_virtual_network" "main" {
  name                = "vnet"                                 # Name of the Azure virtual network
  address_space       = ["10.0.0.0/16"]                        # Defines broad internal network range within Azure
  location            = var.location                           # Location matches the resource group (from input variable)
  resource_group_name = azurerm_resource_group.main.name       # Attach to the above resource group for grouping and management
}

# -----------------------------------------------------------------------------
# Azure Subnet: Subdivides the VNet address space, used for deploying resources with controlled network segmentation.
# -----------------------------------------------------------------------------
resource "azurerm_subnet" "subnet" {
  name                 = "multi-cloud-subnet"                      # Name for this subnet within the VNet
  resource_group_name  = azurerm_resource_group.main.name          # Ensure subnet belongs to our main resource group
  virtual_network_name = azurerm_virtual_network.main.name         # Attach subnet to the main VNet above
  address_prefixes     = ["10.0.1.0/24"]                           # Subnet IP range within the VNet (1/256th slice)
}