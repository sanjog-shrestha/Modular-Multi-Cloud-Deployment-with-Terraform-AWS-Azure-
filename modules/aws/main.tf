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
    cidr_block = "10.1.1.0/24"        # Defines the subnet's range inside the VPC
    tags       = local.common_tags    # Attach the common project tag
}

# Define a security group to allow HTTP access to the EC2 instance
resource "aws_security_group" "web" {
    vpc_id = aws_vpc.main.id          # Security group is associated with the above VPC

    ingress {
        description = "Allow HTTP traffic from anywhere"
        from_port   = 80               # Open port 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]    # Allow from any IP (not recommended for production)
    }

    tags = local.common_tags           # Attach the common project tag
}

# Launch an EC2 instance running Docker with Nginx
resource "aws_instance" "web" {
    ami                    = "ami-018ff7ece22bf96db"    # Ubuntu AMI; update for your AWS region if needed
    instance_type          = "t2.micro"                  # Free tier/smallest instance for demo/testing
    subnet_id              = aws_subnet.main.id          # Place instance in previously created subnet
    vpc_security_group_ids = [aws_security_group.web.id] # Attach security group allowing HTTP access

    # This user_data script installs Docker and launches an Nginx container, so you'll see a running web server in your instance
    user_data = <<-EOF
                #!/bin/bash
                apt update -y
                apt install docker.io -y
                docker run -d -p 80:80 nginx
                EOF

    tags = local.common_tags            # Attach the common project tag (very important for identification and grouping)
}