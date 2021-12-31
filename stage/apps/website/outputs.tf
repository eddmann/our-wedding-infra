output "deploy_user" {
  sensitive = true
  value = {
    access_key_id     = aws_iam_access_key.deploy.id
    secret_access_key = aws_iam_access_key.deploy.secret
  }
  description = "Credentials used by Serverless Framework to deploy the application"
}
