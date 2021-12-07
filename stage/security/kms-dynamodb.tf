resource "aws_kms_key" "dynamodb" {
  description = format("our-wedding-%s-dynamodb", local.stage)

  enable_key_rotation = true

  policy = <<-POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "Allow access through Amazon DynamoDB for all principals in the account that are authorized to use Amazon DynamoDB",
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
          "Sid": "Allow administrators to view the CMK and revoke grants",
          "Effect": "Allow",
          "Principal": {
            "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          },
          "Action": "kms:*",
          "Resource": "*"
        },
        {
          "Sid": "Allow DynamoDB to get information about the CMK",
          "Effect": "Allow",
          "Principal": {
            "Service": ["dynamodb.amazonaws.com"]
          },
          "Action": [
            "kms:Describe*",
            "kms:Get*",
            "kms:List*"
          ],
          "Resource": "*"
        }
      ]
    }
  POLICY

  tags = local.tags
}

resource "aws_kms_alias" "dynamodb" {
  name          = format("alias/our-wedding/%s/dynamodb", local.stage)
  target_key_id = aws_kms_key.dynamodb.key_id
}

resource "aws_ssm_parameter" "dynamodb_kms_key_arn" {
  type  = "String"
  name  = format("/our-wedding/%s/security/dynamodb-kms-key-arn", local.stage)
  value = aws_kms_key.dynamodb.arn
}
