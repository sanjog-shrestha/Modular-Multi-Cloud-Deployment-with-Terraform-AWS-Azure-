# -----------------------------------------------------------------------------
# Root Module Outputs
#
# These outputs surface key values from the AWS and Azure modules so they can be
# easily consumed after `terraform apply` (e.g. for testing in a browser or for
# wiring into other systems).
# -----------------------------------------------------------------------------

# ID of the AWS EC2 instance created in the AWS module.
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = module.aws[0].instance_id
  sensitive   = true
}

# DNS name of the AWS Application Load Balancer fronting the EC2 instance.
output "aws_alb_dns" {
  description = "AWS ALB DNS name - paste into browser to access the AWS app"
  value       = module.aws[0].aws_alb_dns
}

# Name of the Azure Resource Group created by the Azure module.
output "resource_group_name" {
  description = "Azure Resource Group Name"
  value       = module.azure[0].resource_group_name
}

# Public IP address of the Azure Load Balancer; open this in a browser to test the Azure app.
output "azure_lb_public_ip" {
  description = "Azure Load Balancer public IP - paste into browser to access the Azure app"
  value       = module.azure[0].azure_lb_public_ip
  sensitive   = true
}
