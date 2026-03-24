# EC2 instance ID
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = module.aws[0].instance_id
  sensitive   = true
}

# Raw ALB DNS — internal origin
output "aws_alb_dns" {
  description = "AWS ALB DNS — internal origin, use aws_https_url to access the app"
  value       = module.aws[0].aws_alb_dns
}

# [NEW - HTTPS] Primary AWS HTTPS URL via CloudFront
output "aws_https_url" {
  description = "AWS HTTPS URL via CloudFront — trusted certificate, no browser warning"
  value       = module.aws[0].aws_https_url
}

# [NEW - HTTPS] CloudFront domain name
output "cloudfront_domain" {
  description = "CloudFront distribution domain name"
  value       = module.aws[0].cloudfront_domain
}

# Azure Resource Group name
output "resource_group_name" {
  description = "Azure Resource Group name"
  value       = module.azure[0].resource_group_name
}

# Azure LB public IP
output "azure_lb_public_ip" {
  description = "Azure Load Balancer public IP"
  value       = module.azure[0].azure_lb_public_ip
}

# [NEW - HTTPS] Azure HTTPS URL via self-signed certificate
output "azure_https_url" {
  description = "Azure HTTPS URL — self-signed cert, click Advanced → Proceed in browser"
  value       = module.azure[0].azure_https_url
}

output "dynamodb_lock_table" {
  description = "DynamoDB table name used for Terraform state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}