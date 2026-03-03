# -----------------------------------------------------------------------------
# Azure Resource Group: Container for All Azure Resources (Single Screenshot View)
# All resources below are created within this resource group, so viewing this RG in the Azure Portal
# will show all provisioned resources in one screenshot for demos or reports.
# The 'project' tag is applied to all key resources for additional filtering or grouping.
# -----------------------------------------------------------------------------
resource "azurerm_resource_group" "main" {
  name     = var.rg_name
  location = var.location

  tags = {
    project = "multi-cloud-demo"  # TAG: Used for filtering/highlighting all demo resources in a single portal view.
  }
}

# -----------------------------------------------------------------------------
# Azure Virtual Network (VNet): Logical Network for Azure Resources
# Placed in the same resource group and tagged for one-shot visual grouping.
# -----------------------------------------------------------------------------
resource "azurerm_virtual_network" "main" {
  name                = "vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    project = "multi-cloud-demo"  # TAG: Ensures VNet is grouped in the same screenshot/portal filter as other demo resources.
  }
}

# -----------------------------------------------------------------------------
# Azure Subnet within VNet: Segment for Specific Resource Placement
# Subnet appears as a child resource of the tagged VNet and resource group,
# so it will be visible along with other resources in the same RG screenshot.
# -----------------------------------------------------------------------------
resource "azurerm_subnet" "subnet" {
  name                 = "multi-cloud-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
  # Subnets inherit grouping via VNet/resource group (not independently taggable in Azure portal).
}