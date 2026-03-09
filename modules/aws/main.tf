# -----------------------------------------------------------------------------
# AWS Networking and Compute Resources Module
#
# This Terraform configuration provisions essential networking and a basic compute instance on AWS:
#   - A Virtual Private Cloud (VPC) for network isolation
#   - A public subnet within the VPC
#   - A security group to allow inbound HTTP (port 80) access
#   - A t2.micro EC2 instance running Docker and an Nginx container
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

# Create a VPC (Virtual Private Cloud) for isolating AWS resources
resource "aws_vpc" "main" {
    cidr_block = "10.1.0.0/16"    # Defines network range for the VPC
    tags       = local.common_tags # Attach the common project tag
}

# Create a public subnet inside the above VPC
resource "aws_subnet" "main" {
    vpc_id     = aws_vpc.main.id      # Link subnet to VPC
    cidr_block = "10.1.1.0/24"
    availability_zone = "${var.aws_region}a"        # Defines the subnet's range inside the VPC
    tags       = local.common_tags    # Attach the common project tag
    map_public_ip_on_launch = true
}

resource "aws_subnet" "secondary" {
    vpc_id     = aws_vpc.main.id      # Link subnet to VPC
    cidr_block = "10.1.2.0/24"
    availability_zone = "${var.aws_region}b"        # Defines the subnet's range inside the VPC
    tags       = local.common_tags    # Attach the common project tag
    map_public_ip_on_launch = true
}

# Define a security group to allow HTTP access to the EC2 instance
resource "aws_security_group" "web" {
    vpc_id = aws_vpc.main.id          # Security group is associated with the above VPC

    ingress {
        description = "Allow HTTP traffic from anywhere"
        from_port   = 80               # Open port 80
        to_port     = 80
        protocol    = "tcp"
        security_groups = [aws_security_group.alb.id]    # Allow from any IP (not recommended for production)
    }

    egress {
        from_port = 0
        to_port = 0 
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    

    tags = local.common_tags           # Attach the common project tag
}

# Launch an EC2 instance running Docker with Nginx
resource "aws_instance" "web" {
  ami                    = "ami-018ff7ece22bf96db"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.web.id]

  # ✅ Fixed indentation — original had too much whitespace
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

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = local.common_tags
  
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id 

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id 
    }  

    tags = local.common_tags
}

resource "aws_route_table_association" "main" {
    subnet_id = aws_subnet.main.id 
    route_table_id = aws_route_table.public.id  
}

resource "aws_route_table_association" "secondary" {
    subnet_id = aws_subnet.secondary.id  
    route_table_id = aws_route_table.public.id  
}