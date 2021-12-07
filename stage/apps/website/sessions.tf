locals {
  sessions_table_name = format("our-wedding-%s-website-sessions", local.stage)
}

resource "aws_dynamodb_table" "sessions" {
  name         = local.sessions_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  ttl {
    attribute_name = "expires"
    enabled        = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = data.terraform_remote_state.security.outputs.dynamodb_kms_key.arn
  }

  tags = local.tags
}

resource "aws_ssm_parameter" "sessions_table_name" {
  type  = "String"
  name  = format("/our-wedding/%s/apps/website/sessions-table-name", local.stage)
  value = aws_dynamodb_table.sessions.id
  tags  = local.tags
}
