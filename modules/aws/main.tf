# -----------------------------------------------------------------------------
# AWS Networking and Compute Resources Module
#
# This Terraform configuration provisions essential networking and a basic compute instance on AWS:
#   - A Virtual Private Cloud (VPC) for network isolation
#   - A public subnet within the VPC
#   - A security group to allow inbound HTTP (port 80) access
#   - A t2.micro EC2 instance running Docker and an Nginx container
# -----------------------------------------------------------------------------

# Create a VPC for isolating AWS resources
resource "aws_vpc" "main" {
    cidr_block = "10.1.0.0/16"  # This CIDR block defines the internal IP range for the entire VPC
}

# Create a public subnet inside the VPC
resource "aws_subnet" "main" {
    vpc_id     = aws_vpc.main.id   # Associates subnet to previously defined VPC
    cidr_block = "10.1.1.0/24"     # Defines the IP range for this subnet
}

# Create a security group for the web server instance
resource "aws_security_group" "web" {
    vpc_id = aws_vpc.main.id  # Security group is bound to the VPC

    ingress {
        description = "Allow HTTP traffic from anywhere"
        from_port   = 80                # Allow incoming HTTP connections
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]     # Permit from any source (not recommended for production workloads)
    }
}

# Launch an EC2 instance configured for Docker and Nginx
resource "aws_instance" "web" {
    ami                         = "ami-018ff7ece22bf96db"              # Ubuntu AMI; update as appropriate for your region/account
    instance_type               = "t2.micro"     # Smallest EC2 instance type for low-cost testing
    subnet_id                   = aws_subnet.main.id              # Place instance in the earlier defined public subnet
    vpc_security_group_ids      = [aws_security_group.web.id]     # Associate instance with the HTTP-enabled security group

    # User data script installs Docker and launches Nginx as a container on port 80
    user_data = <<-EOF
                #!/bin/bash
                apt update -y
                apt install docker.io -y
                docker run -d -p 80:80 nginx
                EOF
}