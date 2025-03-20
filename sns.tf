# SNS Topic for CloudWatch Alarms
resource "aws_sns_topic" "cloudwatch_alarms" {
  name = "${var.project_name}-cloudwatch-alarms"
}

# SNS Topic Subscription for Email Notifications
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.cloudwatch_alarms.arn
  protocol  = "email"
  endpoint  = "ignatusa3@gmail.com"
}

# IAM Role for CloudWatch to publish to SNS
resource "aws_iam_role" "cloudwatch_sns_role" {
  name = "${var.project_name}-cloudwatch-sns-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for CloudWatch to publish to SNS
resource "aws_iam_role_policy" "cloudwatch_sns_policy" {
  name = "${var.project_name}-cloudwatch-sns-policy"
  role = aws_iam_role.cloudwatch_sns_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sns:Publish"
        ]
        Effect   = "Allow"
        Resource = aws_sns_topic.cloudwatch_alarms.arn
      }
    ]
  })
}