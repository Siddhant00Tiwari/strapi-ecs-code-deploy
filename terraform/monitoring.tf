# monitoring.tf - CloudWatch Monitoring Resources

# =====================================
# CLOUDWATCH DASHBOARD
# =====================================

resource "aws_cloudwatch_dashboard" "strapi_bluegreen" {
  dashboard_name = "strapi-bluegreen-monitoring"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.strapi_cluster.name, "ServiceName", aws_ecs_service.strapi_bluegreen.name],
            [".", "MemoryUtilization", ".", ".", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = var.region
          title  = "ECS Service CPU & Memory Utilization"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", aws_lb_target_group.blue.arn_suffix],
            [".", ".", ".", aws_lb_target_group.green.arn_suffix]
          ]
          period = 300
          stat   = "Average"
          region = var.region
          title  = "Target Group Health (Blue vs Green)"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", aws_lb.strapi_bluegreen_alb.arn_suffix],
            [".", "TargetResponseTime", ".", "."]
          ]
          period = 300
          stat   = "Sum"
          region = var.region
          title  = "Load Balancer Requests & Response Time"
        }
      }
    ]
  })
}

# =====================================
# CLOUDWATCH ALARMS
# =====================================

# High CPU Alarm
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "strapi-bluegreen-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This alarm triggers if ECS CPU utilization > 80% for 10 minutes."

  dimensions = {
    ClusterName = aws_ecs_cluster.strapi_cluster.name
    ServiceName = aws_ecs_service.strapi_bluegreen.name
  }

  tags = {
    Name = "strapi-bluegreen-high-cpu"
  }
}

# High Memory Alarm
resource "aws_cloudwatch_metric_alarm" "high_memory" {
  alarm_name          = "strapi-bluegreen-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This alarm triggers if ECS Memory utilization > 80% for 10 minutes."

  dimensions = {
    ClusterName = aws_ecs_cluster.strapi_cluster.name
    ServiceName = aws_ecs_service.strapi_bluegreen.name
  }

  tags = {
    Name = "strapi-bluegreen-high-memory"
  }
}

# Target Group Unhealthy Hosts Alarm
resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  alarm_name          = "strapi-bluegreen-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "This alarm triggers if there are unhealthy hosts in target groups."

  dimensions = {
    TargetGroup = aws_lb_target_group.blue.arn_suffix
  }

  tags = {
    Name = "strapi-bluegreen-unhealthy-hosts"
  }
}

# High Response Time Alarm
resource "aws_cloudwatch_metric_alarm" "high_response_time" {
  alarm_name          = "strapi-bluegreen-high-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Average"
  threshold           = 2
  alarm_description   = "This alarm triggers if average response time > 2 seconds for 15 minutes."

  dimensions = {
    LoadBalancer = aws_lb.strapi_bluegreen_alb.arn_suffix
  }

  tags = {
    Name = "strapi-bluegreen-high-response-time"
  }
}