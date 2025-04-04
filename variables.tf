variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
}

# VPC
variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
}

variable "public_subnet_az1_name" {
  description = "Name tag for the public subnet in AZ1"
  type        = string
}

variable "public_subnet_az2_name" {
  description = "Name tag for the public subnet in AZ2"
  type        = string
}

variable "private_subnet_az1_name" {
  description = "Name tag for the private subnet in AZ1"
  type        = string
}

variable "private_subnet_az2_name" {
  description = "Name tag for the private subnet in AZ2"
  type        = string
}

variable "igw_name" {
  description = "Name tag for the Internet Gateway"
  type        = string
}

variable "public_route_table_name" {
  description = "Name tag for the public route table"
  type        = string
}

variable "private_route_table_name" {
  description = "Name tag for the private route table"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_az1_cidr" {
  description = "CIDR block for public subnet in AZ1"
  type        = string
}

variable "public_subnet_az2_cidr" {
  description = "CIDR block for public subnet in AZ2"
  type        = string
}

variable "private_subnet_az1_cidr" {
  description = "CIDR block for private subnet in AZ1"
  type        = string
}

variable "private_subnet_az2_cidr" {
  description = "CIDR block for private subnet in AZ2"
  type        = string
}

# RDS
variable "project_name" {
  type = string
}


variable "db_name" {
  description = "The name of the database to create"
  type        = string
}

variable "db_username" {
  description = "Username for the master DB user"
  type        = string
}

variable "db_password" {
  description = "Password for the master DB user"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
}

variable "allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = number
}

variable "engine_version" {
  description = "The engine version of the MySQL database"
  type        = string
}

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type        = bool
}

variable "storage_type" {
  description = "The storage type for the RDS instance"
  type        = string
}

variable "backup_retention_period" {
  description = "The days to retain backups for"
  type        = number
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted"
  type        = bool
}

variable "container_port" {
  description = "The port on which the container listens"
  type        = number
}

variable "desired_count" {
  description = "Number of ECS tasks to run"
  type        = number
}

variable "ecs_task_cpu" {
  description = "CPU units for the ECS task"
  type        = number
}

variable "ecs_task_memory" {
  description = "Memory for the ECS task"
  type        = number
}

variable "retention_in_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
}

# CloudWatch Alarm Variables
variable "alarm_evaluation_periods" {
  description = "Number of periods to evaluate for the alarm"
  type        = number
}

variable "cpu_alarm_threshold" {
  description = "Threshold for CPU utilization alarms (percentage)"
  type        = number
}

variable "memory_alarm_threshold" {
  description = "Threshold for memory utilization alarms (percentage)"
  type        = number
}

variable "standard_alarm_period" {
  description = "Period in seconds for standard CloudWatch alarms"
  type        = number
}

variable "quick_alarm_period" {
  description = "Period in seconds for quick-response CloudWatch alarms"
  type        = number
}

variable "rds_storage_threshold" {
  description = "Threshold for RDS free storage space alarm in bytes"
  type        = number
}

variable "alb_5xx_threshold" {
  description = "Threshold for ALB 5XX error count alarm"
  type        = number
}

variable "alb_2xx_low_threshold" {
  description = "Lower threshold for ALB 2XX success responses"
  type        = number
}

variable "alb_2xx_high_threshold" {
  description = "Upper threshold for ALB 2XX success responses"
  type        = number
}

# Autoscaling Variables
variable "autoscaling_min_capacity" {
  description = "Minimum number of tasks for the ECS service"
  type        = number
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of tasks for the ECS service"
  type        = number
}

variable "cpu_target_tracking_value" {
  description = "Target CPU utilization percentage for autoscaling"
  type        = number
}

variable "memory_target_tracking_value" {
  description = "Target memory utilization percentage for autoscaling"
  type        = number
}

variable "request_count_target_value" {
  description = "Target request count per target for ALB request count based autoscaling"
  type        = number
}