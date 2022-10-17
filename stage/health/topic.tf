#tfsec:ignore:aws-sns-enable-topic-encryption
resource "aws_sns_topic" "health_checks" {
  name = "health-checks"

  tags = local.tags
}

#tfsec:ignore:aws-sns-enable-topic-encryption
resource "aws_sns_topic" "health_checks_us_east_1" {
  provider = aws.us_east_1

  name = "health-checks"

  tags = local.tags
}
