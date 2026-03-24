output "resource_group_name" {
  description = "Azure Resource Group name"
  value       = azurerm_resource_group.main.name
}

output "azure_lb_public_ip" {
  description = "Azure Load Balancer public IP"
  value       = azurerm_public_ip.lb.ip_address
}

output "azure_https_url" {
  description = "Azure HTTPS URL — self-signed cert, click Advanced → Proceed in browser"
  value       = "https://${azurerm_public_ip.lb.ip_address}"
}

# [NEW] SSH command using the auto-generated key
output "azure_ssh_command" {
  description = "SSH command to connect to the Azure VM"
  value       = "ssh -i ${path.module}/azure-key.pem adminuser@${azurerm_public_ip.lb.ip_address}"
}