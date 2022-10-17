# Lambda: Errors > 0
resource "aws_cloudwatch_metric_alarm" "health_check_lambda_errors" {
  alarm_name = "LambdaErrors"

  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  comparison_operator = "GreaterThanThreshold"
  threshold           = "0"
  evaluation_periods  = "1"
  period              = "120"
  statistic           = "Sum"

  dimensions = {}

  alarm_actions   = [aws_sns_topic.health_checks.arn]
  actions_enabled = true

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "health_check_lambda_errors_us_east_1" {
  provider = aws.us_east_1

  alarm_name = "LambdaErrors"

  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  comparison_operator = "GreaterThanThreshold"
  threshold           = "0"
  evaluation_periods  = "1"
  period              = "120"
  statistic           = "Sum"

  dimensions = {}

  alarm_actions   = [aws_sns_topic.health_checks_us_east_1.arn]
  actions_enabled = true

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "health_check_lambda_throttles" {
  alarm_name = "LambdaThrottles"

  namespace           = "AWS/Lambda"
  metric_name         = "Throttles"
  comparison_operator = "GreaterThanThreshold"
  threshold           = "0"
  evaluation_periods  = "1"
  period              = "120"
  statistic           = "Sum"

  dimensions = {}

  alarm_actions   = [aws_sns_topic.health_checks.arn]
  actions_enabled = true

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "health_check_lambda_throttles_us_east_1" {
  provider = aws.us_east_1

  alarm_name = "LambdaThrottles"

  namespace           = "AWS/Lambda"
  metric_name         = "Throttles"
  comparison_operator = "GreaterThanThreshold"
  threshold           = "0"
  evaluation_periods  = "1"
  period              = "120"
  statistic           = "Sum"

  dimensions = {}

  alarm_actions   = [aws_sns_topic.health_checks_us_east_1.arn]
  actions_enabled = true

  tags = local.tags
}
