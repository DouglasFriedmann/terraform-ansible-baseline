locals {
  name = var.project_name
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.50.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "${local.name}-vpc"
    Project = local.name
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${local.name}-igw"
    Project = local.name
  }
}

resource "aws_subnet" "public" {
  count = 2

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name    = "${local.name}-public-${count.index + 1}"
    Project = local.name
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${local.name}-public-rt"
    Project = local.name
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count = 2

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "alb" {
  name        = "${local.name}-alb-sg"
  description = "Allow inbound HTTP to Atlantis ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${local.name}-alb-sg"
    Project = local.name
  }
}

resource "aws_security_group" "atlantis" {
  name        = "${local.name}-ecs-sg"
  description = "Allow ALB to reach Atlantis ECS task"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Atlantis from ALB"
    from_port       = 4141
    to_port         = 4141
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${local.name}-ecs-sg"
    Project = local.name
  }
}

resource "aws_cloudwatch_log_group" "atlantis" {
  name              = "/ecs/${local.name}"
  retention_in_days = 7

  tags = {
    Project = local.name
  }
}

resource "aws_secretsmanager_secret" "github_token" {
  name = "${local.name}/github-token"

  tags = {
    Project = local.name
  }
}

resource "aws_secretsmanager_secret_version" "github_token" {
  secret_id     = aws_secretsmanager_secret.github_token.id
  secret_string = var.github_token
}

resource "aws_secretsmanager_secret" "webhook_secret" {
  name = "${local.name}/github-webhook-secret"

  tags = {
    Project = local.name
  }
}

resource "aws_secretsmanager_secret_version" "webhook_secret" {
  secret_id     = aws_secretsmanager_secret.webhook_secret.id
  secret_string = var.github_webhook_secret
}

resource "aws_secretsmanager_secret" "datadog_api_key" {
  name = "${local.name}/datadog-api-key"

  tags = {
    Project = local.name
  }
}

resource "aws_secretsmanager_secret_version" "datadog_api_key" {
  secret_id     = aws_secretsmanager_secret.datadog_api_key.id
  secret_string = var.datadog_api_key
}

resource "aws_secretsmanager_secret" "datadog_app_key" {
  name = "${local.name}/datadog-app-key"

  tags = {
    Project = local.name
  }
}

resource "aws_secretsmanager_secret_version" "datadog_app_key" {
  secret_id     = aws_secretsmanager_secret.datadog_app_key.id
  secret_string = var.datadog_app_key
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "${local.name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project = local.name
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_task_execution_secrets" {
  name = "${local.name}-read-secrets"
  role = aws_iam_role.ecs_task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          aws_secretsmanager_secret.github_token.arn,
          aws_secretsmanager_secret.webhook_secret.arn,
          aws_secretsmanager_secret.datadog_api_key.arn,
          aws_secretsmanager_secret.datadog_app_key.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role" "atlantis_task" {
  name = "${local.name}-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project = local.name
  }
}

resource "aws_iam_role_policy_attachment" "atlantis_admin" {
  role       = aws_iam_role.atlantis_task.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_lb" "atlantis" {
  name               = "${local.name}-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Project = local.name
  }
}

resource "aws_lb_target_group" "atlantis" {
  name        = "${local.name}-tg"
  port        = 4141
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    path                = "/"
    matcher             = "200,302,405"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Project = local.name
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.atlantis.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.atlantis.arn
  }
}

resource "aws_ecs_cluster" "main" {
  name = "${local.name}-cluster"

  tags = {
    Project = local.name
  }
}

resource "aws_ecs_task_definition" "atlantis" {
  family                   = "${local.name}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.atlantis_task.arn

  container_definitions = jsonencode([
    {
      name      = "atlantis"
      image     = "ghcr.io/runatlantis/atlantis:latest"
      essential = true

      command = ["server"]

      portMappings = [
        {
          containerPort = 4141
          hostPort      = 4141
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "ATLANTIS_REPO_ALLOWLIST"
          value = var.repo_allowlist
        },
        {
          name  = "ATLANTIS_GH_USER"
          value = var.github_user
        },
        {
          name  = "ATLANTIS_ATLANTIS_URL"
          value = "http://${aws_lb.atlantis.dns_name}"
        },
        {
          name  = "TF_VAR_enable_datadog"
          value = "true"
        },
        {
          name  = "TF_VAR_datadog_site"
          value = var.datadog_site
        }
      ]

      secrets = [
        {
          name      = "ATLANTIS_GH_TOKEN"
          valueFrom = aws_secretsmanager_secret.github_token.arn
        },
        {
          name      = "ATLANTIS_GH_WEBHOOK_SECRET"
          valueFrom = aws_secretsmanager_secret.webhook_secret.arn
        },
        {
          name      = "TF_VAR_datadog_api_key"
          valueFrom = aws_secretsmanager_secret.datadog_api_key.arn
        },
        {
          name      = "TF_VAR_datadog_app_key"
          valueFrom = aws_secretsmanager_secret.datadog_app_key.arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.atlantis.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "atlantis"
        }
      }
    }
  ])

  tags = {
    Project = local.name
  }
}

resource "aws_ecs_service" "atlantis" {
  name            = "${local.name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.atlantis.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.atlantis.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.atlantis.arn
    container_name   = "atlantis"
    container_port   = 4141
  }

  depends_on = [
    aws_lb_listener.http
  ]

  tags = {
    Project = local.name
  }
}
