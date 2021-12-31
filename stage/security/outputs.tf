output "rds_kms_key" {
  value = {
    id  = aws_kms_key.rds.key_id
    arn = aws_kms_key.rds.arn
  }
  description = "RDS KMS resource identifiers"
}

output "secrets_manager_kms_key" {
  value = {
    id  = aws_kms_key.secrets_manager.key_id
    arn = aws_kms_key.secrets_manager.arn
  }
  description = "Secrets Manager KMS resource identifiers"
}

output "dynamodb_kms_key" {
  value = {
    id  = aws_kms_key.dynamodb.key_id
    arn = aws_kms_key.dynamodb.arn
  }
  description = "DynamoDB KMS resource identifiers"
}

output "s3_kms_key" {
  value = {
    id  = aws_kms_key.s3.key_id
    arn = aws_kms_key.s3.arn
  }
  description = "S3 KMS resource identifiers"
}

output "sqs_kms_key" {
  value = {
    id  = aws_kms_key.sqs.key_id
    arn = aws_kms_key.sqs.arn
  }
  description = "SQS KMS resource identifiers"
}
