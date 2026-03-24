# EC2 instance ID
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web.id
}

# Raw ALB DNS — internal origin used by CloudFront
output "aws_alb_dns" {
  description = "ALB DNS name — internal origin, use aws_https_url to access the app"
  value       = aws_lb.main.dns_name
}

# Primary HTTPS URL — trusted certificate, no browser warning
output "aws_https_url" {
  description = "HTTPS URL via CloudFront — trusted certificate, no browser warning"
  value       = "https://${aws_cloudfront_distribution.app.domain_name}"
}

# Raw CloudFront domain for DNS records or CI/CD pipelines
output "cloudfront_domain" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.app.domain_name
}

# CloudFront distribution ID for cache invalidation
output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.app.id
}