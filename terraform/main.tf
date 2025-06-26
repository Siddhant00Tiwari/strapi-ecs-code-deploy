# main.tf - Core Infrastructure Resources

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.11.0"
  
  backend "s3" {
    bucket  = "terraform-state-bucket-654654586547"
    key     = "strapi-bluegreen-ecs/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.region
}

# =====================================
# SECURITY GROUPS
# =====================================

# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name        = "strapi-alb-sg"
  description = "Security group for Strapi Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Test traffic for CodeDeploy Blue/Green"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "strapi-alb-sg"
  }
}

# ECS Security Group
resource "aws_security_group" "ecs_sg" {
  name        = "strapi-ecs-sg"
  description = "Security group for Strapi ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Strapi port from ALB only"
    from_port       = 1337
    to_port         = 1337
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "strapi-ecs-sg"
  }
}

# =====================================
# LOAD BALANCER & TARGET GROUPS
# =====================================

# Application Load Balancer
resource "aws_lb" "strapi_bluegreen_alb" {
  name               = "strapi-bluegreen-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.aws_subnets.public.ids

  enable_deletion_protection = false

  tags = {
    Name = "strapi-bluegreen-alb"
  }
}

# Blue Target Group (current production)
resource "aws_lb_target_group" "blue" {
  name        = "strapi-blue-tg"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 5
    unhealthy_threshold = 5
    timeout             = 30
    interval            = 60
    path                = "/health"
    matcher             = "200-399"
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  tags = {
    Name = "strapi-blue-tg"
    Type = "blue"
  }
}

# Green Target Group (for deployments)
resource "aws_lb_target_group" "green" {
  name        = "strapi-green-tg"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 5
    unhealthy_threshold = 5
    timeout             = 30
    interval            = 60
    path                = "/health"
    matcher             = "200-399"
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  tags = {
    Name = "strapi-green-tg"
    Type = "green"
  }
}

# ALB Listener (HTTP)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.strapi_bluegreen_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }

  tags = {
    Name = "strapi-http-listener"
  }
}

# ALB Test Listener (for CodeDeploy Blue/Green testing)
resource "aws_lb_listener" "test" {
  load_balancer_arn = aws_lb.strapi_bluegreen_alb.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.green.arn
  }

  tags = {
    Name = "strapi-test-listener"
  }
}

# =====================================
# CLOUDWATCH LOG GROUP
# =====================================

resource "aws_cloudwatch_log_group" "ecs_strapi" {
  name              = "/ecs/strapi"
  retention_in_days = 14

  tags = {
    Name = "strapi-cloudwatch-logs"
  }
}

# =====================================
# VALIDATION
# =====================================

# Validation to ensure we have adequate subnets
resource "null_resource" "subnet_validation" {
  count = length(data.aws_subnets.public.ids) < 2 ? 1 : 0
  
  provisioner "local-exec" {
    command = "echo 'ERROR: At least 2 public subnets required for ALB. Found: ${length(data.aws_subnets.public.ids)}' && exit 1"
  }
}