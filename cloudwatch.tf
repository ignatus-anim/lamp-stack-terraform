# CloudWatch Log Group for ECS
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/${var.project_name}-task"
  retention_in_days = var.retention_in_days
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


# CloudWatch Alarms
# ECS CPU Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_alarm" {
  alarm_name          = "${var.project_name}-ecs-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.standard_alarm_period
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
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
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = var.standard_alarm_period
  statistic           = "Average"
  threshold           = var.memory_alarm_threshold
  alarm_description   = "This alarm monitors ECS memory utilization"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms.arn]
  ok_actions          = [aws_sns_topic.cloudwatch_alarms.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.lamp_cluster.name
    ServiceName = aws_ecs_service.lamp_service.name
  }
}

# RDS CPU Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "rds_cpu_alarm" {
  alarm_name          = "${var.project_name}-rds-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = var.standard_alarm_period
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  alarm_description   = "This alarm monitors RDS CPU utilization"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms.arn]
  ok_actions          = [aws_sns_topic.cloudwatch_alarms.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.lamp_db.id
  }
}

# RDS Free Storage Space Alarm
resource "aws_cloudwatch_metric_alarm" "rds_storage_alarm" {
  alarm_name          = "${var.project_name}-rds-storage-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = var.standard_alarm_period
  statistic           = "Average"
  threshold           = var.rds_storage_threshold
  alarm_description   = "This alarm monitors RDS free storage space"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms.arn]
  ok_actions          = [aws_sns_topic.cloudwatch_alarms.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.lamp_db.id
  }
}

# ALB 5XX Error Count Alarm
resource "aws_cloudwatch_metric_alarm" "alb_5xx_alarm" {
  alarm_name          = "${var.project_name}-alb-5xx-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = var.standard_alarm_period
  statistic           = "Sum"
  threshold           = var.alb_5xx_threshold
  alarm_description   = "This alarm monitors ALB 5XX errors"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms.arn]
  ok_actions          = [aws_sns_topic.cloudwatch_alarms.arn]

  dimensions = {
    LoadBalancer = aws_lb.lamp_alb.arn_suffix
  }
}

# ALB HTTP 200 Status Code Alarm (Success Monitoring)
resource "aws_cloudwatch_metric_alarm" "alb_200_alarm" {
  alarm_name          = "${var.project_name}-alb-200-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "HTTPCode_Target_2XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = var.quick_alarm_period
  statistic           = "Sum"
  threshold           = var.alb_2xx_low_threshold
  alarm_description   = "This alarm monitors for a drop in successful HTTP 200 responses"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms.arn]
  ok_actions          = [aws_sns_topic.cloudwatch_alarms.arn]

  dimensions = {
    LoadBalancer = aws_lb.lamp_alb.arn_suffix
  }
}

# ALB HTTP 201 Status Code Alarm (Created Resources Monitoring)
resource "aws_cloudwatch_metric_alarm" "alb_201_alarm" {
  alarm_name          = "${var.project_name}-todo-creation-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_2XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = var.quick_alarm_period
  statistic           = "Sum"
  threshold           = var.alb_2xx_high_threshold
  alarm_description   = "This alarm triggers when a todo item is created"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms.arn]
  ok_actions          = [aws_sns_topic.cloudwatch_alarms.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.lamp_alb.arn_suffix
  }
}

# Output for monitoring resources
output "cloudwatch_dashboard_url" {
  value = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${var.project_name}-dashboard"
}