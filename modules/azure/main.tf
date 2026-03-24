# -----------------------------------------------------------------------------
# Azure Core Infrastructure — Resource Group, VNet, Subnet, NSG, NIC, VM
# [NEW] SSH key pair is generated automatically by Terraform using the tls
# provider. No manual ssh-keygen required. The private key is written to
# azure-key.pem in the module directory. Add it to .gitignore.
# -----------------------------------------------------------------------------

# Generate RSA 2048 key pair in Terraform memory
resource "tls_private_key" "azure_ssh" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Write private key to disk for SSH access
# Add azure-key.pem to .gitignore — never commit this file
resource "local_file" "azure_private_key" {
  content         = tls_private_key.azure_ssh.private_key_pem
  filename        = "${path.module}/azure-key.pem"
  file_permission = "0600"
}

resource "azurerm_resource_group" "main" {
  name     = var.rg_name
  location = var.location
  tags     = { project = "multi-cloud-demo" }
}

resource "azurerm_virtual_network" "main" {
  name                = "multi-cloud-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = { project = "multi-cloud-demo" }
}

resource "azurerm_subnet" "main" {
  name                 = "multi-cloud-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "main" {
  name                = "multi-cloud-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = { project = "multi-cloud-demo" }
}

resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_network_interface" "main" {
  name                = "multi-cloud-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = { project = "multi-cloud-demo" }
}

resource "azurerm_linux_virtual_machine" "main" {
  name                            = "multi-cloud-vm"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = var.location
  size                            = "Standard_B1s"
  admin_username                  = "adminuser"
  disable_password_authentication = true

  network_interface_ids = [azurerm_network_interface.main.id]

  # [NEW] Public key sourced directly from the tls_private_key resource above.
  # No file path, no manual key generation, no platform-specific path issues.
  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.azure_ssh.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  # Installs Nginx + OpenSSL, generates a self-signed certificate,
  # and configures Nginx with HTTPS on port 443 and HTTP → HTTPS redirect.
  custom_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx openssl

    # Generate self-signed certificate (365 days, no passphrase)
    mkdir -p /etc/nginx/ssl
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout /etc/nginx/ssl/nginx.key \
      -out /etc/nginx/ssl/nginx.crt \
      -subj "/C=GB/ST=London/L=London/O=MultiCloudDemo/CN=multi-cloud-demo.local"

    # Configure Nginx: redirect HTTP to HTTPS, serve HTTPS with self-signed cert
    cat > /etc/nginx/sites-available/default <<'NGINX'
    server {
        listen 80;
        server_name _;
        return 301 https://$host$request_uri;
    }

    server {
        listen 443 ssl;
        server_name _;
        ssl_certificate     /etc/nginx/ssl/nginx.crt;
        ssl_certificate_key /etc/nginx/ssl/nginx.key;
        location / {
            root /var/www/html;
            index index.html;
        }
    }
    NGINX

    echo "<h1>Hello from Azure VM over HTTPS (self-signed)</h1>" > /var/www/html/index.html
    systemctl restart nginx
    systemctl enable nginx
  EOF
  )

  tags = { project = "multi-cloud-demo" }
}