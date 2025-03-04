# ECS Cluster
resource "aws_ecs_cluster" "lamp_cluster" {
  name = "${var.project_name}-ecs-cluster"

  tags = {
    Name = "${var.project_name}-ecs-cluster"
  }
}


# ECS Task Definition
resource "aws_ecs_task_definition" "lamp_task" {
  family                   = "${var.project_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "lamp-app"
      image     = "${aws_ecr_repository.todolamp.repository_url}:latest"
      cpu       = tonumber(var.ecs_task_cpu)
      memory    = tonumber(var.ecs_task_memory)
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
        }
      ]
        environment = [
        { name = "DB_HOST", value = aws_db_instance.lamp_db.endpoint },
        { name = "DB_USER", value = var.db_username },
        { name = "DB_PASSWORD", value = var.db_password },
        { name = "DB_NAME", value = var.db_name }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_log_group.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}


# ECS Service
resource "aws_ecs_service" "lamp_service" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.lamp_cluster.id
  task_definition = aws_ecs_task_definition.lamp_task.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.public_subnet_az1.id, aws_subnet.public_subnet_az2.id]
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lamp_tg.arn
    container_name   = "lamp-app"
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener.listener]

  tags = {
    Name = "${var.project_name}-ecs-service"
  }
}



# Security Group for ECS
resource "aws_security_group" "ecs_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ecs-sg"
  }
}


# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# OUTPUTS

output "ecs_security_group" {
  value = aws_security_group.ecs_sg.id
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.lamp_cluster.name
}

output "ecs_service_name" {
  value = aws_ecs_service.lamp_service.name
}