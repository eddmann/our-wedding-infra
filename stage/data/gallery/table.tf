locals {
  table_name = format("our-wedding-%s-gallery-table", local.stage)
}

#tfsec:ignore:aws-dynamodb-enable-recovery
resource "aws_dynamodb_table" "gallery" {
  name         = local.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "PK"
  range_key    = "SK"

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  attribute {
    name = "GSI1PK"
    type = "S"
  }

  attribute {
    name = "GSI1SK"
    type = "S"
  }

  global_secondary_index {
    name            = "GSI1"
    hash_key        = "GSI1PK"
    range_key       = "GSI1SK"
    projection_type = "ALL"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = data.terraform_remote_state.security.outputs.dynamodb_kms_key.arn
  }

  tags = local.tags
}

resource "aws_ssm_parameter" "table_name" {
  type  = "String"
  name  = format("/our-wedding/%s/apps/gallery/table-name", local.stage)
  value = aws_dynamodb_table.gallery.id
  tags  = local.tags
}
