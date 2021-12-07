resource "aws_kms_key" "secrets_manager" {
  description = format("our-wedding-%s-secrets-manager", local.stage)

  enable_key_rotation = true

  policy = <<-POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "Allow access through AWS Secrets Manager for all principals in the account that are authorized to use AWS Secrets Manager",
          "Effect": "Allow",
          "Principal": {
            "AWS": "*"
          },
          "Action": [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:CreateGrant",
            "kms:DescribeKey"
          ],
          "Resource": "*",
          "Condition": {
            "StringEquals": {
              "kms:ViaService": "secretsmanager.${var.aws_region}.amazonaws.com",
              "kms:CallerAccount": "${data.aws_caller_identity.current.account_id}"
            }
          }
        },
        {
          "Sid": "Allow direct access to key within the account",
          "Effect": "Allow",
          "Principal": {
            "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          },
          "Action": "kms:*",
          "Resource": "*"
        }
      ]
    }
  POLICY

  tags = local.tags
}

resource "aws_kms_alias" "secrets_manager" {
  name          = format("alias/our-wedding/%s/secrets-manager", local.stage)
  target_key_id = aws_kms_key.secrets_manager.key_id
}

resource "aws_ssm_parameter" "secrets_manager_kms_key_arn" {
  type  = "String"
  name  = format("/our-wedding/%s/security/secrets-manager-kms-key-arn", local.stage)
  value = aws_kms_key.secrets_manager.arn
}
