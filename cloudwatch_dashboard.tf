
# CloudWatch Dashboard for ALB, ECS, and RDS
resource "aws_cloudwatch_dashboard" "lamp_dashboard" {
  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      # ECS CPU and Memory Utilization
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.lamp_cluster.name, "ServiceName", aws_ecs_service.lamp_service.name, { "stat" = "Average", "label" = "CPU Utilization" }],
            ["AWS/ECS", "MemoryUtilization", "ClusterName", aws_ecs_cluster.lamp_cluster.name, "ServiceName", aws_ecs_service.lamp_service.name, { "stat" = "Average", "label" = "Memory Utilization" }]
          ]
          period = 10
          region = var.aws_region
          title  = "ECS Service CPU and Memory"
          view   = "timeSeries"
          stacked = false
        }
      },
      # ALB Metrics
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", aws_lb.lamp_alb.arn_suffix, { "stat" = "Sum", "label" = "Request Count" }],
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", aws_lb.lamp_alb.arn_suffix, { "stat" = "Average", "label" = "Response Time" }]
          ]
          period = 10
          region = var.aws_region
          title  = "ALB Request Count and Response Time"
          view   = "timeSeries"
          stacked = false
        }
      },
      # ALB HTTP Status Codes
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_2XX_Count", "LoadBalancer", aws_lb.lamp_alb.arn_suffix, { "stat" = "Sum", "label" = "2XX" }],
            ["AWS/ApplicationELB", "HTTPCode_Target_3XX_Count", "LoadBalancer", aws_lb.lamp_alb.arn_suffix, { "stat" = "Sum", "label" = "3XX" }],
            ["AWS/ApplicationELB", "HTTPCode_Target_4XX_Count", "LoadBalancer", aws_lb.lamp_alb.arn_suffix, { "stat" = "Sum", "label" = "4XX" }],
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", aws_lb.lamp_alb.arn_suffix, { "stat" = "Sum", "label" = "5XX" }]
          ]
          period = 10
          region = var.aws_region
          title  = "ALB HTTP Status Codes"
          view   = "timeSeries"
          stacked = false
        }
      },
      # RDS Metrics
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", aws_db_instance.lamp_db.id, { "stat" = "Average", "label" = "CPU Utilization" }],
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", aws_db_instance.lamp_db.id, { "stat" = "Average", "label" = "DB Connections" }]
          ]
          period = 10
          region = var.aws_region
          title  = "RDS CPU and Connections"
          view   = "timeSeries"
          stacked = false
        }
      },
      # RDS Storage and Memory
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", aws_db_instance.lamp_db.id, { "stat" = "Average", "label" = "Free Storage Space" }],
            ["AWS/RDS", "FreeableMemory", "DBInstanceIdentifier", aws_db_instance.lamp_db.id, { "stat" = "Average", "label" = "Freeable Memory" }]
          ]
          period = 10
          region = var.aws_region
          title  = "RDS Storage and Memory"
          view   = "timeSeries"
          stacked = false
        }
      },
      # ECS Service Events
      {
        type   = "log"
        x      = 12
        y      = 12
        width  = 12
        height = 6
        properties = {
          query   = "SOURCE '/ecs/${var.project_name}-task' | fields @timestamp, @message | sort @timestamp desc | limit 20"
          region  = var.aws_region
          title   = "ECS Service Logs"
          view    = "table"
        }
      }
    ]
  })
}