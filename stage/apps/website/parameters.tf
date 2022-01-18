resource "aws_ssm_parameter" "email_notifier_to" {
  type  = "StringList"
  name  = format("/our-wedding/%s/apps/website/email-notifier-to", local.stage)
  value = join(",", var.email_notifier_to)
  tags  = local.tags
}

resource "aws_ssm_parameter" "email_notifier_from" {
  type  = "String"
  name  = format("/our-wedding/%s/apps/website/email-notifier-from", local.stage)
  value = var.email_notifier_from
  tags  = local.tags
}
