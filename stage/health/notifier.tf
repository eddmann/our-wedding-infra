#tfsec:ignore:aws-sns-enable-topic-encryption
resource "aws_sns_topic" "health_checks" {
  name = format("our-wedding-%s-health-checks", local.stage)

  tags = local.tags
}

resource "aws_sns_topic_subscription" "health_checks_email_notifier" {
  topic_arn = aws_sns_topic.health_checks.arn
  protocol  = "email"
  endpoint  = var.notifier_email_address
}

#tfsec:ignore:aws-sns-enable-topic-encryption
resource "aws_sns_topic" "health_checks_us_east_1" {
  provider = aws.us_east_1

  name = format("our-wedding-%s-health-checks", local.stage)

  tags = local.tags
}

resource "aws_sns_topic_subscription" "health_checks_email_notifier_us_east_1" {
  provider = aws.us_east_1

  topic_arn = aws_sns_topic.health_checks_us_east_1.arn
  protocol  = "email"
  endpoint  = var.notifier_email_address
}
