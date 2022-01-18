locals {
  auto_generated_secrets = {
    "app-secret" : {
      "length" : 32
    },
    "origin-domain-auth-key" : {
      "length" : 32
    }
  }
}

resource "random_password" "auto_generated" {
  for_each = local.auto_generated_secrets

  length  = each.value.length
  special = false
}

resource "aws_secretsmanager_secret" "auto_generated" {
  for_each = local.auto_generated_secrets

  kms_key_id = data.terraform_remote_state.security.outputs.secrets_manager_kms_key.id

  name = format("/our-wedding/%s/apps/website/%s", local.stage, each.key)
  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "auto_generated" {
  for_each = local.auto_generated_secrets

  secret_id     = aws_secretsmanager_secret.auto_generated[each.key].id
  secret_string = random_password.auto_generated[each.key].result
}

#
# Admin password
#
resource "aws_secretsmanager_secret" "admin_password" {
  kms_key_id = data.terraform_remote_state.security.outputs.secrets_manager_kms_key.id

  name = format("/our-wedding/%s/apps/website/admin-password", local.stage)
  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "admin_password" {
  secret_id     = aws_secretsmanager_secret.admin_password.id
  secret_string = var.admin_password
}

#
# Mailer DSN
#
resource "aws_secretsmanager_secret" "mailer_dsn" {
  kms_key_id = data.terraform_remote_state.security.outputs.secrets_manager_kms_key.id

  name = format("/our-wedding/%s/apps/website/mailer-dsn", local.stage)
  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "mailer_dsn" {
  secret_id     = aws_secretsmanager_secret.mailer_dsn.id
  secret_string = var.mailer_dsn
}

#
# Page Content
#
resource "aws_secretsmanager_secret" "page_content" {
  kms_key_id = data.terraform_remote_state.security.outputs.secrets_manager_kms_key.id

  name = format("/our-wedding/%s/apps/website/page-content", local.stage)
  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "page_content" {
  secret_id     = aws_secretsmanager_secret.page_content.id
  secret_string = var.page_content
}
