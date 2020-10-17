locals {
  tenant_name             = "denzi"
  environment             = "qa"
  cidr_block              = "16.255.0.0/16"
  db_username             = "denziuat"
  db_password             = "tenant123$"
  db_identifier           = "denzi-qa-instance"
  db_instance             = "mysql-denzi-qa-instance"
  tf_remote_state_bucket  = "denzi-uat-remote-state"
  region                  = "us-east-2"
  
}

module "cloud_watch" {
  source           = "../modules/cloud_watch"
  name             = local.tenant_name
   tags = {
    Environment = "${local.environment}"
    Tenant = "${local.tenant_name}"
  }
}

module "cloudfront" {
  source = "../modules/cloud_front"

  enable_route53_record = false

  environment = "${local.tenant_name}"
  name        = "${local.tenant_name}-cloud-front"

  load_balancer_arn = module.alb.alb_arn
  bucket_id = module.s3-bucket.s3_bucket_id
  origin_access_identity = module.s3-bucket.origin_access_identity

  min_ttl     = 0
  default_ttl = 0
  max_ttl     = 0

  tags = {
    Environment = "${local.environment}"
    Tenant = "${local.tenant_name}"
  }

  custom_error_response = [
    {
      "error_code"         = 403
      "response_code"      = 200
      "response_page_path" = "/index.html"
    },
    {
      "error_code"         = 404
      "response_code"      = 200
      "response_page_path" = "/index.html"
    },
  ]

  bucket_force_destroy = true
}

module "ecs_fargate" {
  source           = "../modules/ecs_fargate"
  name             = "${local.tenant_name}-task-definition"
  container_name   = local.container_name
  container_port   = local.container_port
  cluster          = aws_ecs_cluster.ecs-cluster.arn
  subnets          = module.vpc.public_subnet_ids
  target_group_arn = module.alb.alb_target_group_arn
  vpc_id           = module.vpc.vpc_id

  container_definitions = jsonencode([
    {
      name      = local.container_name
      #image     = "nginx:latest"
      image     = "437642037048.dkr.ecr.us-east-2.amazonaws.com/denzi-service:latest"
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = module.cloud_watch.log_group_name,
          awslogs-region = local.region,
          awslogs-stream-prefix = "${local.tenant_name}-app"
        }
      }
      portMappings = [
        {
          containerPort = local.container_port
          protocol      = "tcp"
        }
      ]
      environment = [
# CF url is temporary. Route 53 url should come here once it is implemented
        {
          "name": "APPLICATION_DENZI_MFA-SWITCH-ENABLED",
          "value": "false"
        },
        # CF url is temporary. Route 53 url should come here once it is implemented
        {
          name  = "APPLICATION_UI_URL"
          value = "https://${module.cloudfront.cloudfront_dns_record}"
        },
        {
          name  = "AWS_ACCESS_KEY_ID"
          value = "AKIAWLZL7Q44PRBG7GKL"
        },
        {
          name  = "AWS_SECRET_ACCESS_KEY"
          value = "VS8Rrqc9g/3n6W4ISRTXZpDAqCPdtb6Lck57m13l"
        },
           {
          name  = "HIBERNATE_CACHE_USE_QUERY_CACHE"
          value = "*"
        },
           {
          name  = "JHIPSTER_CORS_ALLOWED-HEADER"
          value = "*"
        },
           {
          name  = "JHIPSTER_CORS_ALLOWED-METHODS"
          value = "GET, PUT, POST, DELETE, OPTIONS"
        },
        {
          name  = "JHIPSTER_CORS_ALLOWED-ORIGINS"
          value = "*"
        },
        {
          name  = "JHIPSTER_CORS_MAX-AGE"
          value = "1800"
        },
        # CF url is temporary. Route 53 url should come here once it is implemented
        {
          name  = "JHIPSTER_MAIL_BASE-URL"
          value = "https://${module.cloudfront.cloudfront_dns_record}"
        },
        {
          name  = "JHIPSTER_MAIL_FROM"
          value = "nagendra@velocityworks.io"
        },
        {
          name  = "JHIPSTER_SECURITY_AUTHENTICATION_JWT_SECRET"
          value = "adVS8Rrqc9g/3n6W4ISRTXZpDAqCPdtb6Lck57m13lVS8Rrqc9g/3n6W4ISRTXZpDAqCPdtb6Lck57m13lVS8Rrqc9g/3n6W4ISRTXZpDAqCPdtb6Lck57m13l"
        },
        {
          name  = "JHIPSTER_SLEEP"
          value = "0"
        },
        {
          name  = "LIQUIBASE_ENABLED"
          value = "true"
        },
        {
          name  = "LOGGING_LOGGER_GROUPNAME"
          value = "${local.environment}-${local.tenant_name}-group"
        },
        {
          name  = "LOGGING_LOGGER_STREAMNAME"
          value = "${local.environment}-${local.tenant_name}-app"
        },
        {
          name  = "SPRING_DATASOURCE_PASSWORD"
          value = local.db_password
        },
        {
          name  = "SPRING_DATASOURCE_URL"
          value = "jdbc:mysql://${module.rds.rds-end-point}/${local.tenant_name}dbservice?useUnicode=true&characterEncoding=utf8&useSSL=false"
        },
        {
          name  = "SPRING_DATASOURCE_USERNAME"
          value = local.db_username
        },
        {
          name  = "SPRING_JPA_PROPERTIES_HIBERNATE_CACHE_USE_SECOND_LEVEL_CACHE"
          value = "false"
        },
        {
          name  = "SPRING_MAIL_HOST"
          value = "email-smtp.us-east-1.amazonaws.com"
        },
        {
          name  = "SPRING_MAIL_PASSWORD"
          value = "BLYjRaohGR/xIaDv3BIPnPlTghIbr5+lSg8zHO7j198x"
        },
        {
          name  = "SPRING_MAIL_USERNAME"
          value = "AKIAWLZL7Q44A4YUGA4R"
        },
        {
          name  = "SPRING_PROFILES_ACTIVE"
          value = "prod,swagger"
        }
        

      ]
    }
  ])

  desired_count                      = 1
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  deployment_controller_type         = "ECS"
  assign_public_ip                   = true
  health_check_grace_period_seconds  = 10
  platform_version                   = "LATEST"
  source_cidr_blocks                 = ["0.0.0.0/0"]
  cpu                                = 1024
  memory                             = 4096
  requires_compatibilities           = ["FARGATE"]
  iam_path                           = "/service_role/"
  description                        = "This is ${local.tenant_name}"
  enabled                            = true

  create_ecs_task_execution_role = true
  ecs_task_execution_role_arn    = aws_iam_role.default.arn

  tags = {
    Environment = local.environment
    Tenant = "${local.tenant_name}"
  }
}

resource "aws_iam_role" "default" {
  name               = "${local.tenant_name}-ecs-task-execution-for-ecs-fargate"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com","ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "default" {
  name   = aws_iam_role.default.name
  policy = data.aws_iam_policy.ecs_task_execution.policy
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.default.name
  policy_arn = aws_iam_policy.default.arn
}

data "aws_iam_policy" "ecs_task_execution" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

locals {
  container_name = "${local.tenant_name}-service"
  container_port = tonumber(module.alb.alb_target_group_port)
  #host_port = tonumber(module.alb.http_port)
}

resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${local.tenant_name}-ecs-cluster"
}

module "alb" {
  source                     = "../modules/alb"
  name                       = "${local.tenant_name}-fargate-lb"
  vpc_id                     = module.vpc.vpc_id
  subnets                    = module.vpc.public_subnet_ids
  access_logs_bucket         = module.s3_lb_log.s3_bucket_id
  enable_https_listener      = false
  enable_http_listener       = true
  enable_deletion_protection = false

  internal                    = false
  idle_timeout                = 120
  enable_http2                = false 
  ip_address_type             = "ipv4"
  access_logs_prefix          = "test"
  access_logs_enabled         = true
  ssl_policy                  = "ELBSecurityPolicy-2016-08"
  https_port                  = 443
  http_port                   = 80
  fixed_response_content_type = "text/plain"
  fixed_response_message_body = "ok"
  fixed_response_status_code  = "200"
  source_cidr_blocks          = ["0.0.0.0/0"]

  target_group_port                = 8080
  target_group_protocol            = "HTTP"
  target_type                      = "ip"
  deregistration_delay             = 600
  slow_start                       = 0
  health_check_path                = "/management/health"
  health_check_healthy_threshold   = 5
  health_check_unhealthy_threshold = 3
  health_check_timeout             = 120
  health_check_interval            = 200
  health_check_matcher             = 200
  health_check_port                = "traffic-port"
  health_check_protocol            = "HTTP"
  listener_rule_priority           = 1
  listener_rule_condition_field    = "path-pattern"
  listener_rule_condition_values   = ["/*"]
  enabled                          = true

  tags = {
    Tenant = "${local.tenant_name}"
    Environment = local.environment
  }
}

module "s3_lb_log" {
  source                = "../modules/s3_lb_log"
  name                  = "${local.tenant_name}-s3-lb-log-ecs-fargate-${data.aws_caller_identity.current.account_id}"
  logging_target_bucket = module.s3_access_log.s3_bucket_id
  force_destroy         = true
}

module "s3_access_log" {
  source        = "../modules/s3_access_log"
  name          = "${local.tenant_name}-s3-access-log-ecs-fargate-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

module "vpc" {
  source                    = "../modules/vpc"
  cidr_block                = local.cidr_block
  name                      = "${local.tenant_name}-ecs-fargate"
  public_subnet_cidr_blocks = [cidrsubnet(local.cidr_block, 8, 0), cidrsubnet(local.cidr_block, 8, 1)]
  public_availability_zones = data.aws_availability_zones.available.names
  private_subnet_cidr_blocks = [cidrsubnet(local.cidr_block, 8, 2), cidrsubnet(local.cidr_block, 8, 3)]
  private_availability_zones = data.aws_availability_zones.available.names
  tags = {
    Environment = "${local.environment}"
    Tenant = "${local.tenant_name}"
  }
}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

module "rds" {
  source      = "../modules/rds"
  identifier           = local.db_identifier
  db_instance          = local.db_instance
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.m4.large"
  name                 = "${local.tenant_name}dbservice"
  username             = local.db_username
  password             = local.db_password
  parameter_group_name = "default.mysql5.7"
  publicly_accessible  = "false"
  vpc_id               = module.vpc.vpc_id
  backup_retention_period = 10
  subnet_ids           = module.vpc.private_subnet_ids
    tags = {
    Environment = "${local.environment}"
    Tenant = "${local.tenant_name}"
  }
}


module "s3-terraform-remote-state" {
  source                    = "../modules/s3-terraform-remote-state"
  bucket_name               = local.tf_remote_state_bucket
}

module "s3-bucket" {
  source                    = "../modules/s3"
  bucket_name               = "${local.tenant_name}-admin-portal"
   tags = {
    Environment = "${local.environment}"
    tenant = "${local.tenant_name}"
  }
}

terraform {
  backend "s3" {
    bucket = "denzi-uat-remote-state"
    key    = "terraform/dev/terraform.tfstate"
    region = "us-east-2"
  }
}




