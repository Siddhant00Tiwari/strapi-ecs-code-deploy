# outputs.tf - Complete Output Values

# =====================================
# APPLICATION ACCESS OUTPUTS
# =====================================

output "application_url" {
  description = "Public URL to access the Strapi application"
  value       = "http://${aws_lb.strapi_bluegreen_alb.dns_name}"
}

output "health_check_url" {
  description = "Health check endpoint URL"
  value       = "http://${aws_lb.strapi_bluegreen_alb.dns_name}/health"
}

output "admin_url" {
  description = "Strapi admin panel URL"
  value       = "http://${aws_lb.strapi_bluegreen_alb.dns_name}/admin"
}

# =====================================
# LOAD BALANCER OUTPUTS
# =====================================

output "load_balancer_dns" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.strapi_bluegreen_alb.dns_name
}

output "load_balancer_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.strapi_bluegreen_alb.arn
}

output "load_balancer_hosted_zone" {
  description = "Hosted Zone ID of the Application Load Balancer (for Route 53)"
  value       = aws_lb.strapi_bluegreen_alb.zone_id
}

output "load_balancer_security_group_id" {
  description = "Security Group ID of the Application Load Balancer"
  value       = aws_security_group.alb_sg.id
}

# =====================================
# TARGET GROUP OUTPUTS
# =====================================

output "blue_target_group_arn" {
  description = "ARN of the Blue target group (production)"
  value       = aws_lb_target_group.blue.arn
}

output "blue_target_group_name" {
  description = "Name of the Blue target group"
  value       = aws_lb_target_group.blue.name
}

output "green_target_group_arn" {
  description = "ARN of the Green target group (deployment)"
  value       = aws_lb_target_group.green.arn
}

output "green_target_group_name" {
  description = "Name of the Green target group"
  value       = aws_lb_target_group.green.name
}

# =====================================
# ECS CLUSTER OUTPUTS
# =====================================

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.strapi_cluster.name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.strapi_cluster.arn
}

output "ecs_cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.strapi_cluster.id
}

# =====================================
# ECS SERVICE OUTPUTS
# =====================================

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.strapi_bluegreen.name
}

output "ecs_service_arn" {
  description = "ARN of the ECS service"
  value       = aws_ecs_service.strapi_bluegreen.id
}

output "ecs_service_security_group_id" {
  description = "Security Group ID of the ECS service"
  value       = aws_security_group.ecs_sg.id
}

# =====================================
# TASK DEFINITION OUTPUTS
# =====================================

output "task_definition_family" {
  description = "Family name of the ECS task definition"
  value       = aws_ecs_task_definition.strapi_bluegreen.family
}

output "task_definition_arn" {
  description = "Full ARN of the ECS task definition (includes revision)"
  value       = aws_ecs_task_definition.strapi_bluegreen.arn
}

output "task_definition_revision" {
  description = "Revision number of the ECS task definition"
  value       = aws_ecs_task_definition.strapi_bluegreen.revision
}

output "task_execution_role_arn" {
  description = "ARN of the task execution role"
  value       = var.task_execution_role_arn
}

output "task_role_arn" {
  description = "ARN of the task role"
  value       = var.task_role_arn
}

# =====================================
# CODEDEPLOY OUTPUTS
# =====================================

output "codedeploy_application_name" {
  description = "Name of the CodeDeploy application"
  value       = aws_codedeploy_app.strapi.name
}

output "codedeploy_application_arn" {
  description = "ARN of the CodeDeploy application"
  value       = aws_codedeploy_app.strapi.arn
}

output "codedeploy_deployment_group_name" {
  description = "Name of the CodeDeploy deployment group"
  value       = aws_codedeploy_deployment_group.strapi.deployment_group_name
}

output "codedeploy_deployment_config" {
  description = "CodeDeploy deployment configuration strategy"
  value       = aws_codedeploy_deployment_group.strapi.deployment_config_name
}

output "codedeploy_role_arn" {
  description = "ARN of the CodeDeploy service role"
  value       = var.codedeploy_role_arn
}

# =====================================
# MONITORING & LOGGING OUTPUTS
# =====================================

output "cloudwatch_dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.strapi_bluegreen.dashboard_name
}

output "cloudwatch_dashboard_url" {
  description = "URL to access the CloudWatch dashboard"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.region}#dashboards:name=${aws_cloudwatch_dashboard.strapi_bluegreen.dashboard_name}"
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.ecs_strapi.name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.ecs_strapi.arn
}

output "cloudwatch_logs_url" {
  description = "URL to access CloudWatch logs"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.region}#logsV2:log-groups/log-group/${replace(aws_cloudwatch_log_group.ecs_strapi.name, "/", "$252F")}"
}

# =====================================
# ALARM OUTPUTS
# =====================================

output "cloudwatch_alarms" {
  description = "CloudWatch alarm details"
  value = {
    high_cpu_alarm = {
      name = aws_cloudwatch_metric_alarm.high_cpu.alarm_name
      arn  = aws_cloudwatch_metric_alarm.high_cpu.arn
    }
    high_memory_alarm = {
      name = aws_cloudwatch_metric_alarm.high_memory.alarm_name
      arn  = aws_cloudwatch_metric_alarm.high_memory.arn
    }
    unhealthy_hosts_alarm = {
      name = aws_cloudwatch_metric_alarm.unhealthy_hosts.alarm_name
      arn  = aws_cloudwatch_metric_alarm.unhealthy_hosts.arn
    }
    high_response_time_alarm = {
      name = aws_cloudwatch_metric_alarm.high_response_time.alarm_name
      arn  = aws_cloudwatch_metric_alarm.high_response_time.arn
    }
  }
}

# =====================================
# NETWORK & SUBNET DISCOVERY OUTPUTS
# =====================================

output "vpc_id" {
  description = "VPC ID where resources are deployed"
  value       = var.vpc_id
}

output "discovered_subnets" {
  description = "Information about discovered public subnets"
  value = {
    total_public_subnets = length(data.aws_subnets.public.ids)
    selected_subnets     = data.aws_subnets.public.ids
    subnet_details = {
      for subnet_id in data.aws_subnets.public.ids : subnet_id => {
        availability_zone = data.aws_subnet.public_subnets[subnet_id].availability_zone
        cidr_block        = data.aws_subnet.public_subnets[subnet_id].cidr_block
        subnet_id         = subnet_id
      }
    }
    availability_zones = distinct([
      for subnet in data.aws_subnet.public_subnets : subnet.availability_zone
    ])
  }
}

# =====================================
# GITHUB ACTIONS CONFIGURATION
# =====================================

output "github_actions_env_vars" {
  description = "Environment variables for GitHub Actions workflow (.env format)"
  value = {
    AWS_REGION                  = var.region
    ECR_REPOSITORY              = "default/strapi-app"
    ECS_CLUSTER                 = aws_ecs_cluster.strapi_cluster.name
    ECS_SERVICE                 = aws_ecs_service.strapi_bluegreen.name
    TASK_DEFINITION_FAMILY      = aws_ecs_task_definition.strapi_bluegreen.family
    ALB_NAME                    = aws_lb.strapi_bluegreen_alb.name
    TARGET_GROUP_NAME           = aws_lb_target_group.blue.name
    CODEDEPLOY_APPLICATION      = aws_codedeploy_app.strapi.name
    CODEDEPLOY_DEPLOYMENT_GROUP = aws_codedeploy_deployment_group.strapi.deployment_group_name
  }
}

output "github_actions_env_file" {
  description = "Environment variables in .env file format for easy copying"
  value       = <<-EOT
    AWS_REGION=${var.region}
    ECR_REPOSITORY=default/strapi-app
    ECS_CLUSTER=${aws_ecs_cluster.strapi_cluster.name}
    ECS_SERVICE=${aws_ecs_service.strapi_bluegreen.name}
    TASK_DEFINITION_FAMILY=${aws_ecs_task_definition.strapi_bluegreen.family}
    ALB_NAME=${aws_lb.strapi_bluegreen_alb.name}
    TARGET_GROUP_NAME=${aws_lb_target_group.blue.name}
    CODEDEPLOY_APPLICATION=${aws_codedeploy_app.strapi.name}
    CODEDEPLOY_DEPLOYMENT_GROUP=${aws_codedeploy_deployment_group.strapi.deployment_group_name}
  EOT
}

# =====================================
# AWS CONSOLE URLS
# =====================================

output "aws_console_urls" {
  description = "Direct links to AWS console resources"
  value = {
    ecs_cluster          = "https://console.aws.amazon.com/ecs/v2/clusters/${aws_ecs_cluster.strapi_cluster.name}/services?region=${var.region}"
    ecs_service          = "https://console.aws.amazon.com/ecs/v2/clusters/${aws_ecs_cluster.strapi_cluster.name}/services/${aws_ecs_service.strapi_bluegreen.name}/configuration?region=${var.region}"
    load_balancer        = "https://console.aws.amazon.com/ec2/home?region=${var.region}#LoadBalancer:loadBalancerArn=${aws_lb.strapi_bluegreen_alb.arn}"
    target_groups        = "https://console.aws.amazon.com/ec2/home?region=${var.region}#TargetGroups:"
    codedeploy_app       = "https://console.aws.amazon.com/codesuite/codedeploy/applications/${aws_codedeploy_app.strapi.name}?region=${var.region}"
    cloudwatch_dashboard = "https://console.aws.amazon.com/cloudwatch/home?region=${var.region}#dashboards:name=${aws_cloudwatch_dashboard.strapi_bluegreen.dashboard_name}"
    cloudwatch_logs      = "https://console.aws.amazon.com/cloudwatch/home?region=${var.region}#logsV2:log-groups/log-group/${replace(aws_cloudwatch_log_group.ecs_strapi.name, "/", "$252F")}"
  }
}

# =====================================
# CONTAINER CONFIGURATION
# =====================================

output "container_images" {
  description = "Container images used in the deployment"
  value = {
    strapi_image = var.strapi_image
    db_image     = var.db_image
  }
}

output "database_configuration" {
  description = "Database configuration (non-sensitive values)"
  value = {
    db_name = var.db_name
    db_user = var.db_user
    db_port = 5432
  }
  sensitive = false
}

# =====================================
# DEPLOYMENT SUMMARY
# =====================================

output "deployment_summary" {
  description = "Complete deployment summary"
  value = {
    # Infrastructure
    region             = var.region
    vpc_id             = var.vpc_id
    availability_zones = distinct([for subnet in data.aws_subnet.public_subnets : subnet.availability_zone])

    # Application Access
    application_url  = "http://${aws_lb.strapi_bluegreen_alb.dns_name}"
    health_check_url = "http://${aws_lb.strapi_bluegreen_alb.dns_name}/health"
    admin_url        = "http://${aws_lb.strapi_bluegreen_alb.dns_name}/admin"

    # Core Services
    ecs_cluster     = aws_ecs_cluster.strapi_cluster.name
    ecs_service     = aws_ecs_service.strapi_bluegreen.name
    task_definition = "${aws_ecs_task_definition.strapi_bluegreen.family}:${aws_ecs_task_definition.strapi_bluegreen.revision}"

    # Blue/Green Deployment
    blue_target_group   = aws_lb_target_group.blue.name
    green_target_group  = aws_lb_target_group.green.name
    codedeploy_app      = aws_codedeploy_app.strapi.name
    deployment_strategy = aws_codedeploy_deployment_group.strapi.deployment_config_name

    # Monitoring
    dashboard_url = "https://console.aws.amazon.com/cloudwatch/home?region=${var.region}#dashboards:name=${aws_cloudwatch_dashboard.strapi_bluegreen.dashboard_name}"
    logs_url      = "https://console.aws.amazon.com/cloudwatch/home?region=${var.region}#logsV2:log-groups/log-group/${replace(aws_cloudwatch_log_group.ecs_strapi.name, "/", "$252F")}"
  }
}

# =====================================
# DEPLOYMENT READINESS CHECKLIST
# =====================================

output "deployment_ready_checklist" {
  description = "Blue/Green deployment readiness checklist and next steps"
  value = {
    status = "✅ Blue/Green deployment infrastructure ready"

    infrastructure_components = {
      ecs_cluster        = "✅ ${aws_ecs_cluster.strapi_cluster.name}"
      ecs_service        = "✅ ${aws_ecs_service.strapi_bluegreen.name}"
      load_balancer      = "✅ ${aws_lb.strapi_bluegreen_alb.name}"
      blue_target_group  = "✅ ${aws_lb_target_group.blue.name}"
      green_target_group = "✅ ${aws_lb_target_group.green.name}"
      codedeploy_app     = "✅ ${aws_codedeploy_app.strapi.name}"
    }

    deployment_configuration = {
      strategy           = "✅ ${aws_codedeploy_deployment_group.strapi.deployment_config_name}"
      auto_rollback      = "✅ Enabled on deployment failure"
      health_checks      = "✅ Configured for /health endpoint"
      monitoring         = "✅ CloudWatch dashboard and 4 alarms"
      container_insights = "✅ Enabled for ECS cluster"
    }

    next_steps = [
      "1. Test application: http://${aws_lb.strapi_bluegreen_alb.dns_name}",
      "2. Verify health endpoint: http://${aws_lb.strapi_bluegreen_alb.dns_name}/health",
      "3. Access admin panel: http://${aws_lb.strapi_bluegreen_alb.dns_name}/admin",
      "4. Set up GitHub Actions with provided environment variables",
      "5. Push new image to ECR to trigger first Blue/Green deployment",
      "6. Monitor deployment progress in CodeDeploy console",
      "7. Set up custom domain with Route 53 (optional)",
      "8. Configure SNS notifications for CloudWatch alarms (optional)"
    ]

    validation_commands = [
      "terraform output application_url",
      "curl $(terraform output -raw health_check_url)",
      "aws ecs describe-services --cluster ${aws_ecs_cluster.strapi_cluster.name} --services ${aws_ecs_service.strapi_bluegreen.name}",
      "aws elbv2 describe-target-health --target-group-arn ${aws_lb_target_group.blue.arn}",
      "aws deploy get-application --application-name ${aws_codedeploy_app.strapi.name}"
    ]
  }
}