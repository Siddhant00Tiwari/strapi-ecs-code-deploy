# data.tf - Data Sources

# Get current AWS account information
data "aws_caller_identity" "current" {}

# Data block to discover public subnets in the VPC
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
}

# Data block to get subnet details for validation and information
data "aws_subnet" "public_subnets" {
  for_each = toset(data.aws_subnets.public.ids)
  id       = each.value
}