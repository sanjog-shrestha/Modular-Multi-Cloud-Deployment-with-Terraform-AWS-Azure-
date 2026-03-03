# ------------------------------------------------------------------
# Outputs for AWS Module: Useful information for downstream usage
# - EC2 instance ID for tracking the created VM
# - Public IP for direct access (e.g., to access web service)
# ------------------------------------------------------------------

# Output the ID of the created EC2 instance
output "instance_id" {
    description = "ID of the EC2 instance"
    value       = aws_instance.web.id
}

# Output the public IP address of the EC2 instance
output "public_ip" {
    description = "Public IP of the EC2 instance"
    value       = aws_instance.web.public_ip
}