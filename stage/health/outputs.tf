output "health_checks_sns_topic_arn" {
  value = aws_sns_topic.health_checks.arn
}

output "health_checks_us_east_1_sns_topic_arn" {
  value = aws_sns_topic.health_checks_us_east_1.arn
}
