locals {
  php_lambdas = toset(["web", "worker", "console"])
}

resource "aws_cloudwatch_log_metric_filter" "php_errors" {
  for_each = local.php_lambdas

  name           = format("OurWedding-%s-Website-%sPHPError", title(local.stage), title(each.key))
  pattern        = "{ $.level >= 300 }"
  log_group_name = format("/aws/lambda/our-wedding-website-%s-%s", local.stage, each.key)

  metric_transformation {
    name      = format("OurWedding-%s-Website-%sPHPErrorCount", title(local.stage), title(each.key))
    namespace = "HealthCheck"
    value     = "1"
  }
}

# OurWedding-{Stage}-Website-{Web,Worker,Console}PHPError > 0
resource "aws_cloudwatch_metric_alarm" "health_check_php_errors" {
  for_each = local.php_lambdas

  alarm_name = format("OurWedding-%s-Website-%sPHPError", title(local.stage), title(each.key))

  namespace           = "HealthCheck"
  metric_name         = format("OurWedding-%s-Website-%sPHPErrorCount", title(local.stage), title(each.key))
  comparison_operator = "GreaterThanThreshold"
  threshold           = "0"
  evaluation_periods  = "1"
  period              = "120"
  statistic           = "Sum"

  alarm_actions   = [data.terraform_remote_state.health.outputs.health_checks_sns_topic_arn]
  actions_enabled = true

  tags = local.tags
}
