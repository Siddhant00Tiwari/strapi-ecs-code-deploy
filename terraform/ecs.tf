# ecs.tf - ECS Resources

# =====================================
# ECS CLUSTER
# =====================================

resource "aws_ecs_cluster" "strapi_cluster" {
  name = "strapi-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "strapi-cluster"
  }
}

# =====================================
# ECS TASK DEFINITION
# =====================================

resource "aws_ecs_task_definition" "strapi_bluegreen" {
  family                   = "strapi-bluegreen-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "postgres"
      image     = var.db_image
      essential = true
      portMappings = [
        {
          containerPort = 5432
          protocol      = "tcp"
          name          = "postgres-port"
        }
      ]
      environment = [
        {
          name  = "POSTGRES_DB"
          value = var.db_name
        },
        {
          name  = "POSTGRES_USER"
          value = var.db_user
        },
        {
          name  = "POSTGRES_PASSWORD"
          value = var.db_pass
        },
        {
          name  = "POSTGRES_INITDB_ARGS"
          value = "--auth-host=md5"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_strapi.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "postgres"
        }
      }
      healthCheck = {
        command = [
          "CMD-SHELL",
          "pg_isready -U ${var.db_user} -d ${var.db_name}"
        ]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    },
    {
      name      = "strapi"
      image     = var.strapi_image
      essential = true
      dependsOn = [
        {
          containerName = "postgres"
          condition     = "HEALTHY"
        }
      ]
      portMappings = [
        {
          containerPort = 1337
          protocol      = "tcp"
          name          = "strapi-port"
          appProtocol   = "http"
        }
      ]
      environment = [
        {
          name  = "NODE_ENV"
          value = "production"
        },
        {
          name  = "HOST"
          value = "0.0.0.0"
        },
        {
          name  = "PORT"
          value = "1337"
        },
        {
          name  = "DATABASE_CLIENT"
          value = "postgres"
        },
        {
          name  = "DATABASE_HOST"
          value = "127.0.0.1"
        },
        {
          name  = "DATABASE_PORT"
          value = "5432"
        },
        {
          name  = "DATABASE_NAME"
          value = var.db_name
        },
        {
          name  = "DATABASE_USERNAME"
          value = var.db_user
        },
        {
          name  = "DATABASE_PASSWORD"
          value = var.db_pass
        },
        {
          name  = "DATABASE_SSL"
          value = "false"
        },
        {
          name  = "APP_KEYS"
          value = var.app_keys
        },
        {
          name  = "API_TOKEN_SALT"
          value = var.api_token_salt
        },
        {
          name  = "ADMIN_JWT_SECRET"
          value = var.admin_jwt_secret
        },
        {
          name  = "JWT_SECRET"
          value = var.jwt_secret
        },
        {
          name  = "TRANSFER_TOKEN_SALT"
          value = var.transfer_token_salt
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_strapi.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "strapi"
        }
      }
    }
  ])

  tags = {
    Name        = "strapi-bluegreen-task"
    Environment = "production"
  }
}

# =====================================
# ECS SERVICE
# =====================================

resource "aws_ecs_service" "strapi_bluegreen" {
  name            = "strapi-bluegreen-service"
  cluster         = aws_ecs_cluster.strapi_cluster.id
  task_definition = aws_ecs_task_definition.strapi_bluegreen.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  # Enable Blue/Green deployment with CodeDeploy
  deployment_controller {
    type = "CODE_DEPLOY"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.blue.arn
    container_name   = "strapi"
    container_port   = 1337
  }

  network_configuration {
    subnets          = data.aws_subnets.public.ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  depends_on = [aws_lb_listener.http]

  # Ignore task definition changes as CodeDeploy will manage this
  lifecycle {
    ignore_changes = [task_definition, load_balancer]
  }

  tags = {
    Name           = "strapi-bluegreen-service"
    Environment    = "production"
    DeploymentType = "blue-green"
  }
}