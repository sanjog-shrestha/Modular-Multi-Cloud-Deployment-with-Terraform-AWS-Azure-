# ------------------------------------------------------------------
# Outputs for AWS Module: Useful information for downstream usage
# - EC2 instance ID for tracking the created VM
# - Public IP for direct access (e.g., to access web service)
# ------------------------------------------------------------------

# Output the ID of the created EC2 instance
output "instance_id" {
    description = "ID of the EC2 instance"
    value       = aws_instance.web.id
    sensitive = true
}

output "aws_alb_dns" {
    description = "AWS ALB DNS name - paste into browser to access app"
    value = aws_lb.main.dns_name
}