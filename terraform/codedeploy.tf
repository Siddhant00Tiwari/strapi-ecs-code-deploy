# codedeploy.tf - CodeDeploy Resources

# =====================================
# CODEDEPLOY APPLICATION
# =====================================

resource "aws_codedeploy_app" "strapi" {
  compute_platform = "ECS"
  name             = "strapi-bluegreen-app"

  tags = {
    Name = "strapi-bluegreen-app"
  }
}

# =====================================
# CODEDEPLOY DEPLOYMENT GROUP
# =====================================

resource "aws_codedeploy_deployment_group" "strapi" {
  app_name               = aws_codedeploy_app.strapi.name
  deployment_group_name  = "strapi-bluegreen-dg"
  service_role_arn       = var.codedeploy_role_arn
  deployment_config_name = "CodeDeployDefault.ECSCanary10Percent5Minutes"

  # Required: Deployment style for ECS Blue/Green
  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"]
  }

  blue_green_deployment_config {
    terminate_blue_instances_on_deployment_success {
      action                         = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }

    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    # Note: green_fleet_provisioning_option is not supported for ECS platform
    # ECS automatically handles Green fleet provisioning
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.strapi_cluster.name
    service_name = aws_ecs_service.strapi_bluegreen.name
  }

  # Required: Load balancer info with target group pair for ECS Blue/Green
  load_balancer_info {
    target_group_pair_info {
      target_group {
        name = aws_lb_target_group.blue.name
      }
      
      target_group {
        name = aws_lb_target_group.green.name
      }
      
      prod_traffic_route {
        listener_arns = [aws_lb_listener.http.arn]
      }
      
      # Separate test listener for Blue/Green validation
      test_traffic_route {
        listener_arns = [aws_lb_listener.test.arn]
      }
    }
  }

  tags = {
    Name = "strapi-bluegreen-dg"
  }
}