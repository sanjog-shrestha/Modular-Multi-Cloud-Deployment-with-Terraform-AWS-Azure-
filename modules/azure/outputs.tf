output "resource_group_name" {
    description = "Azure Resource Group Name"
    value       = azurerm_resource_group.main.name
}

output "vnet_name" {
    description = "Azure Virtual Network Name"
    value       = azurerm_virtual_network.main.name
}