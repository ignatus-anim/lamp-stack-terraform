# CloudWatch Log Group for ECS
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/${var.project_name}-task"
  retention_in_days = var.retention_in_days
}

# CloudWatch Log Group for ALB
resource "aws_cloudwatch_log_group" "alb_log_group" {
  name              = "/aws/alb/${var.project_name}-alb"
  retention_in_days = var.retention_in_days

  tags = {
    Name = "${var.project_name}-alb-logs"
  }
}

# CloudWatch Log Groups for RDS
locals {
  rds_log_types = ["audit", "error", "general", "slowquery"]
}

resource "aws_cloudwatch_log_group" "rds_log_groups" {
  count = length(local.rds_log_types)
  
  name              = "/aws/rds/instance/${aws_db_instance.lamp_db.id}/${local.rds_log_types[count.index]}"
  retention_in_days = var.retention_in_days
  
  tags = {
    Name = "${var.project_name}-rds-${local.rds_log_types[count.index]}-logs"
  }
}

# IAM Role for ECS Cloudwatch logs
resource "aws_iam_role_policy" "ecs_cloudwatch_logs" {
  name = "ecs-cloudwatch-logs-policy"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}


# IAM Role for ALB Cloudwatch logs
resource "aws_iam_role" "alb_logs_role" {
  name = "${var.project_name}-alb-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "elasticloadbalancing.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "alb_cloudwatch_logs" {
  name = "alb-cloudwatch-logs-policy"
  role = aws_iam_role.alb_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup"
        ]
        Effect   = "Allow"
        Resource = "${aws_cloudwatch_log_group.alb_log_group.arn}:*"
      }
    ]
  })
}

# IAM Role for RDS Cloudwatch logs
resource "aws_iam_role" "rds_logs_role" {
  name = "${var.project_name}-rds-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "rds_cloudwatch_logs" {
  name = "rds-cloudwatch-logs-policy"
  role = aws_iam_role.rds_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup"
        ]
        Effect   = "Allow"
        Resource = [for log_group in aws_cloudwatch_log_group.rds_log_groups : "${log_group.arn}:*"]
      }
    ]
  })
}

# CloudWatch Alarms
# ECS CPU Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_alarm" {
  alarm_name          = "${var.project_name}-ecs-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This alarm monitors ECS CPU utilization"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms.arn]
  ok_actions          = [aws_sns_topic.cloudwatch_alarms.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.lamp_cluster.name
    ServiceName = aws_ecs_service.lamp_service.name
  }
}

# ECS Memory Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "ecs_memory_alarm" {
  alarm_name          = "${var.project_name}-ecs-memory-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This alarm monitors ECS memory utilization"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms.arn]
  ok_actions          = [aws_sns_topic.cloudwatch_alarms.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.lamp_cluster.name
    ServiceName = aws_ecs_service.lamp_service.name
  }
}

# Output for monitoring resources
output "cloudwatch_dashboard_url" {
  value = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${var.project_name}-dashboard"
}