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

resource "azurerm_network_security_group" "main" {
  name                = "multi-cloud-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "allow-lb-health-probe"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-http"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow SSH for management
  security_rule {
    name                       = "allow-ssh"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = { project = "multi-cloud-demo" }
}

# Associate NSG with subnet
resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_network_interface" "main" {
  name                = "multi-cloud-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.vm.id 
  }

  tags = { project = "multi-cloud-demo" }
}

resource "azurerm_public_ip" "vm" {
  name = "multi-cloud-vm-pip"
  location = var.location
  resource_group_name = azurerm_resource_group.main.name 
  allocation_method = "Static"
  sku = "Standard"

  tags = { project = "multi-cloud-demo" }
}

resource "azurerm_linux_virtual_machine" "machine" {
  name = "multi-cloud-vm"
  resource_group_name = azurerm_resource_group.main.name 
  location = var.location
  size = "Standard_B1s"
  admin_username = "azureuser"
  admin_password = "ChangeMe!123456"
  disable_password_authentication = false

  network_interface_ids = [azurerm_network_interface.main.id]

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer = "0001-com-ubuntu-server-jammy"
    sku = "22_04-lts"
    version = "latest"
  }


  custom_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    systemctl start nginx
    systemctl enable nginx
    echo "<h1>nginx running on Azure VM - multi-cloud-demo</h1>" > /var/www/html/index.html
  EOF
  )

  tags = { project = "multi-cloud-demo"}
}