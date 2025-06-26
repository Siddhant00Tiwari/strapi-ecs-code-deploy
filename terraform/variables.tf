# variables.tf - Input Variables (No defaults - all values from tfvars)

# AWS Configuration
variable "region" {
  description = "AWS region for deployment"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where resources will be deployed"
  type        = string
}

# Existing IAM Role ARNs (created manually)
variable "task_execution_role_arn" {
  description = "ARN of the existing ECS Task Execution Role"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the existing ECS Task Role"
  type        = string
}

variable "codedeploy_role_arn" {
  description = "ARN of the existing CodeDeploy Service Role"
  type        = string
}

# Container Images
variable "strapi_image" {
  description = "Docker image URI for Strapi from ECR"
  type        = string
}

variable "db_image" {
  description = "Docker image for PostgreSQL database"
  type        = string
}

# Database Configuration
variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
}

variable "db_user" {
  description = "PostgreSQL username"
  type        = string
}

variable "db_pass" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}

# Strapi Configuration
variable "app_keys" {
  description = "Strapi APP_KEYS (comma-separated base64 encoded keys)"
  type        = string
  sensitive   = true
}

variable "api_token_salt" {
  description = "Strapi API_TOKEN_SALT for API token generation"
  type        = string
  sensitive   = true
}

variable "admin_jwt_secret" {
  description = "Strapi ADMIN_JWT_SECRET for admin authentication"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "Strapi JWT_SECRET for user authentication"
  type        = string
  sensitive   = true
}

variable "transfer_token_salt" {
  description = "Strapi TRANSFER_TOKEN_SALT for transfer tokens"
  type        = string
  sensitive   = true
}