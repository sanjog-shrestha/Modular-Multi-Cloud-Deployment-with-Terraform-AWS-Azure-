output "instance_id" {
  description = "ID of the EC2 instance"
  value       = module.aws[0].instance_id
  sensitive   = true
}

output "aws_alb_dns" {
  description = "AWS ALB DNS name"
  value       = module.aws[0].aws_alb_dns
}

output "resource_group_name" {
    description = "Azure Resource Group Name"
    value       = module.azure[0].resource_group_name
}

# Public IP address of the Azure Load Balancer; open this in a browser to test the app.
output "azure_lb_public_ip" {
    description = "Azure Load Balancer public IP - paste into browser to access app"
    value       = module.azure[0].azure_lb_public_ip
}
