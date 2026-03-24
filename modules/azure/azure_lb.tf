
# -----------------------------------------------------------------------------
# Azure Load Balancer & Public IP
#
# This file provisions:
#   - A static public IP for the Azure Load Balancer
#   - The Load Balancer itself with a single frontend configuration
#   - A backend address pool used by downstream resources (e.g. VMs/VMSS)
#   - A health probe and a load-balancing rule for HTTP traffic on port 80
# All resources are tagged with `project = "multi-cloud-demo"` for easy filtering.
# -----------------------------------------------------------------------------

# Public IP address that exposes the Azure Load Balancer to the internet.
resource "azurerm_public_ip" "lb" {
    name                = "multi-cloud-lb-pip"
    location            = var.location
    resource_group_name = azurerm_resource_group.main.name
    allocation_method   = "Static"    # Reserve a static IP so the demo endpoint is stable
    sku                 = "Standard"  # Recommended SKU for production-grade load balancers

    tags = {
        project = "multi-cloud-demo"  # TAG: Ensures Public IP appears with other demo resources.
    }
}

# Core Azure Load Balancer resource that fronts backend resources.
resource "azurerm_lb" "main" {
    name                = "multi-cloud-lb"
    location            = var.location
    resource_group_name = azurerm_resource_group.main.name
    sku                 = "Standard"

    # Frontend configuration associates the LB with the static public IP above.
    frontend_ip_configuration {
      name                 = "frontend"
      public_ip_address_id = azurerm_public_ip.lb.id
    }

    tags = {
        project = "multi-cloud-demo"  # TAG: Ensures LB is grouped with the multi-cloud demo resources.
    }
}

# Backend address pool that will later be associated with VMs/VMSS instances.
resource "azurerm_lb_backend_address_pool" "main" {
    name            = "multi-cloud-backend-pool"
    loadbalancer_id = azurerm_lb.main.id
}

# Health probe to check HTTP availability of backend instances on port 80.
resource "azurerm_lb_probe" "http" {
    name            = "http-probe"
    loadbalancer_id = azurerm_lb.main.id
    protocol        = "Http"   # HTTP probe hitting the path below
    port            = 80
    request_path    = "/"
}

# TCP health probe on port 443
resource "azurerm_lb_probe" "https" {
    name = "https-probe"
    loadbalancer_id = azurerm_lb.main.id 
    protocol = "Tcp"
    port = 443 
}

# Load-balancing rule that maps frontend HTTP traffic to backend pool port 80.
resource "azurerm_lb_rule" "http" {
    name                           = "http-rule"
    loadbalancer_id                = azurerm_lb.main.id
    protocol                       = "Tcp"
    frontend_port                  = 80
    backend_port                   = 80
    frontend_ip_configuration_name = "frontend"
    backend_address_pool_ids       = [azurerm_lb_backend_address_pool.main.id]
    probe_id                       = azurerm_lb_probe.http.id
}

# HTTPS load balancing rule — port 443 → VM port 443.
# Azure Standard LB is Layer 4 only — TLS terminates at Nginx on the VM.
resource "azurerm_lb_rule" "https" {
    name                           = "https-rule"
    loadbalancer_id                = azurerm_lb.main.id
    protocol                       = "Tcp"
    frontend_port                  = 443
    backend_port                   = 443
    frontend_ip_configuration_name = "frontend"
    backend_address_pool_ids       = [azurerm_lb_backend_address_pool.main.id]
    probe_id                       = azurerm_lb_probe.https.id
}
# ✅ Connect Azure VM NIC to the LB backend pool
resource "azurerm_network_interface_backend_address_pool_association" "main" {
  network_interface_id    = azurerm_network_interface.main.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}

# NSG rule — allow HTTP on port 80
resource "azurerm_network_security_rule" "http" {
    name = "allow-http"
    priority = 110
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "80" 
    source_address_prefix = "*"
    destination_address_prefix = "*"
    resource_group_name = azurerm_resource_group.main.name 
    network_security_group_name = azurerm_network_security_group.main.name
}

# NSG rule — allow HTTPS on port 443
resource "azurerm_network_security_rule" "https" {
    name = "allow-https"
    priority = 120
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "443" 
    source_address_prefix = "*"
    destination_address_prefix = "*"
    resource_group_name = azurerm_resource_group.main.name 
    network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_network_security_rule" "lb_health_probe" {
  name                        = "allow-lb-health-probe"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "AzureLoadBalancer"  # ← special Azure service tag
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}