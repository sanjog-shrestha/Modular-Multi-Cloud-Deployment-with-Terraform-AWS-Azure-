
# -----------------------------------------------------------------------------
# Outputs for Azure Module
#
# These outputs expose key Azure resource attributes to the root module or
# consumers of this module, making it easy to reference important values:
#   - The name of the created Resource Group
#   - The public IP address of the Azure Load Balancer (for browser access)
# -----------------------------------------------------------------------------

# Name of the Azure Resource Group created in this module.
output "resource_group_name" {
    description = "Azure Resource Group Name"
    value       = azurerm_resource_group.main.name
}

# Public IP address of the Azure Load Balancer; open this in a browser to test the app.
output "azure_lb_public_ip" {
    description = "Azure Load Balancer public IP - paste into browser to access app"
    value       = azurerm_public_ip.lb.ip_address
}
