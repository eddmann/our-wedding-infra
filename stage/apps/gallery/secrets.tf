locals {
  auto_generated_secrets = {
    "api-origin-domain-auth-key" : {
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

  name = format("/our-wedding/%s/apps/gallery/%s", local.stage, each.key)
  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "auto_generated" {
  for_each = local.auto_generated_secrets

  secret_id     = aws_secretsmanager_secret.auto_generated[each.key].id
  secret_string = random_password.auto_generated[each.key].result
}
