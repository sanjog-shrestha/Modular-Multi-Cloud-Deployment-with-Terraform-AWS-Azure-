
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