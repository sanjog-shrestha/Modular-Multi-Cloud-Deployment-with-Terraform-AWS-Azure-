
# -----------------------------------------------------------------------------
# AWS Application Load Balancer (ALB) & Supporting Resources
#
# This file provisions:
#   - A security group to allow HTTP traffic to the ALB
#   - A target group used to register backend instances
#   - The ALB itself, associated with the VPC subnet and security group
#   - A listener on port 80 forwarding traffic to the target group
# All resources are tagged with `project = "multi-cloud-demo"` for easy discovery.
# -----------------------------------------------------------------------------

# Security group that controls inbound/outbound traffic to the ALB.
resource "aws_security_group" "alb" {
    name        = "multi-cloud-alb-sg"
    description = "Allow HTTP to ALB"
    vpc_id      = aws_vpc.main.id
    
    # Allow inbound HTTP traffic from anywhere (0.0.0.0/0) on port 80.
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Allow all outbound traffic so the ALB can reach backends and the internet.
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        project = "multi-cloud-demo"  # TAG: Ensures ALB security group is grouped with demo resources.
    }
}


# Target group representing the HTTP backend (EC2 instances in this module).
resource "aws_lb_target_group" "main" {
    name     = "multi-cloud-tg"
    port     = 80
    protocol = "HTTP"
    vpc_id   = aws_vpc.main.id

    # Health check configuration to monitor backend instance health via HTTP.
    health_check {
      enabled             = true
      path                = "/"
      interval            = 30
      timeout             = 5
      healthy_threshold   = 2
      unhealthy_threshold = 3
      matcher             = "200"
    }

    tags = {
        project = "multi-cloud-demo"  # TAG: Ensures target group shows under the project tag.
    }
}

# Application Load Balancer that fronts the web instance(s).
resource "aws_lb" "main" {
    name               = "multi-cloud-alb"
    internal           = false                       # Internet-facing ALB
    load_balancer_type = "application"
    security_groups    = [aws_security_group.alb.id] # Attach ALB security group
    subnets            = [
        aws_subnet.main.id, 
        aws_subnet.secondary.id 
    ]        # Place ALB in the public subnet

    tags = {
        project = "multi-cloud-demo"  # TAG: Ensures ALB is grouped with multi-cloud demo resources.
    }
}

# Listener that accepts HTTP traffic on port 80 and forwards it to the target group.
resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.main.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.main.arn
    }
}

resource "aws_lb_target_group_attachment" "web" {
    target_group_arn = aws_lb_target_group.main.arn 
    target_id = aws_instance.web.id 
    port = 80
}

# [NEW - HTTPS] CloudFront distribution — free trusted HTTPS on *.cloudfront.net.
# No domain, no ACM certificate, no browser warning.
resource "aws_cloudfront_distribution" "app" {
  enabled             = true
  comment             = "multi-cloud-demo AWS HTTPS distribution"
  default_root_object = ""

  # Origin — ALB receives HTTP from CloudFront on port 80
  origin {
    domain_name = aws_lb.main.dns_name
    origin_id   = "multi-cloud-alb-origin"

    custom_origin_config {
      http_port  = 80
      https_port = 443
      # CRITICAL: must be http-only — ALB has no HTTPS listener.
      # Using https-only causes a 504 Gateway Timeout.
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "multi-cloud-alb-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods  = ["GET", "HEAD"]

    # Disable caching — pass all requests through to EC2 in real time
    forwarded_values {
      query_string = true
      headers      = ["*"]
      cookies { forward = "all" }
    }

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
    compress    = true
  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  # Free AWS-managed certificate on *.cloudfront.net — globally trusted
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  depends_on = [aws_lb_listener.http]

  tags = { project = "multi-cloud-demo" }
}