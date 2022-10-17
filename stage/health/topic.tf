#tfsec:ignore:aws-sns-enable-topic-encryption
resource "aws_sns_topic" "health_checks" {
  name = format("our-wedding-%s-health-checks", local.stage)

  tags = local.tags
}

#tfsec:ignore:aws-sns-enable-topic-encryption
resource "aws_sns_topic" "health_checks_us_east_1" {
  provider = aws.us_east_1

  name = format("our-wedding-%s-health-checks", local.stage)

  tags = local.tags
}
