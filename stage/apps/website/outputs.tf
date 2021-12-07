output "deploy_role" {
  value = {
    arn         = aws_iam_role.deploy.arn,
    external_id = random_string.deploy_external_id.result
  }
}
