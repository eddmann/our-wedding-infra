output "rds_kms_key" {
  value = {
    id  = aws_kms_key.rds.key_id
    arn = aws_kms_key.rds.arn
  }
}

output "secrets_manager_kms_key" {
  value = {
    id  = aws_kms_key.secrets_manager.key_id
    arn = aws_kms_key.secrets_manager.arn
  }
}

output "dynamodb_kms_key" {
  value = {
    id  = aws_kms_key.dynamodb.key_id
    arn = aws_kms_key.dynamodb.arn
  }
}

output "s3_kms_key" {
  value = {
    id  = aws_kms_key.s3.key_id
    arn = aws_kms_key.s3.arn
  }
}

output "sqs_kms_key" {
  value = {
    id  = aws_kms_key.sqs.key_id
    arn = aws_kms_key.sqs.arn
  }
}
