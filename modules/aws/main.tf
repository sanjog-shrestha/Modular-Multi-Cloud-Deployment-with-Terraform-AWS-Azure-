# -----------------------------------------------------------------------------
# AWS Networking and Compute Resources Module
#
# This Terraform configuration provisions essential networking and a basic compute instance on AWS:
#   - A Virtual Private Cloud (VPC) for network isolation
#   - Two public subnets across availability zones
#   - A security group to allow inbound HTTP (port 80) access (from the ALB)
#   - A t3.micro EC2 instance running Nginx
#   - Internet gateway and routes for outbound internet access
#   - All resources are tagged with "project = multi-cloud-demo" for easy identification
# -----------------------------------------------------------------------------

# Define a common tag to be attached to all AWS resources in this module.
# This enables you to easily filter and show all the provisioned resources under a single tag in the AWS console,
# which is especially useful for demonstration, cleanup, and screenshot purposes.
locals {
  common_tags = {
    project = "multi-cloud-demo" # <-- This tag is applied to all resources below
  }
}

# Create a VPC (Virtual Private Cloud) for isolating AWS resources.
resource "aws_vpc" "main" {
    cidr_block = "10.1.0.0/16"     # Defines network range for the VPC
    tags       = local.common_tags # Attach the common project tag
}

# Primary public subnet in AZ "a" for the EC2 instance and ALB.
resource "aws_subnet" "main" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = "10.1.1.0/24"
    availability_zone       = "${var.aws_region}a"
    map_public_ip_on_launch = true           # Automatically assign public IPs
    tags                    = local.common_tags
}

# Secondary public subnet in AZ "b" for multi-AZ ALB deployment.
resource "aws_subnet" "secondary" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = "10.1.2.0/24"
    availability_zone       = "${var.aws_region}b"
    map_public_ip_on_launch = true
    tags                    = local.common_tags
}

# Security group for the web EC2 instance; allows HTTP from the ALB security group.
resource "aws_security_group" "web" {
    vpc_id = aws_vpc.main.id

    ingress {
        description     = "Allow HTTP traffic from ALB"
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        security_groups = [aws_security_group.alb.id] # Restrict inbound HTTP to traffic coming from the ALB SG
    }

    egress {
        from_port   = 0
        to_port     = 0 
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = local.common_tags
}

# Launch an EC2 instance running Nginx for the demo web application.
resource "aws_instance" "web" {
  ami                    = "ami-018ff7ece22bf96db" # Ubuntu image; ensure this is valid in your region
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.web.id]

  # Cloud-init style user data to install and start Nginx with a simple index page.
  user_data = <<-EOF
#!/bin/bash
apt-get update -y
apt-get install -y nginx
systemctl start nginx
systemctl enable nginx 
echo "<h1>nginx on AWS EC2 - multi-cloud-demo</h1>" > /var/www/html/index.html
EOF

  tags = local.common_tags
}

# Internet gateway to provide outbound internet access for resources in the VPC.
resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = local.common_tags
}

# Public route table with a default route to the internet gateway.
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id 

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id 
    }  

    tags = local.common_tags
}

# Associate the primary public subnet with the public route table.
resource "aws_route_table_association" "main" {
    subnet_id      = aws_subnet.main.id 
    route_table_id = aws_route_table.public.id  
}

# Associate the secondary public subnet with the same public route table.
resource "aws_route_table_association" "secondary" {
    subnet_id      = aws_subnet.secondary.id  
    route_table_id = aws_route_table.public.id  
}