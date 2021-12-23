resource "aws_iam_policy" "website" {
  name_prefix = format("our-wedding-%s-website-", local.stage)

  policy = <<-POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "dynamodb:PutItem",
            "dynamodb:UpdateItem",
            "dynamodb:GetItem",
            "dynamodb:DeleteItem"
          ],
          "Resource": "${aws_dynamodb_table.sessions.arn}"
        },
        {
          "Effect": "Allow",
          "Action": "kms:Decrypt",
          "Resource": "${data.terraform_remote_state.security.outputs.dynamodb_kms_key.arn}"
        },
        {
          "Effect": "Allow",
          "Action": "secretsmanager:GetSecretValue",
          "Resource": [
            "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:/our-wedding/${local.stage}/apps/website/*",
            "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:/our-wedding/${local.stage}/data/website/*"
          ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "sqs:SendMessage",
            "sqs:ReceiveMessage",
            "sqs:DeleteMessage"
          ],
          "Resource": "${aws_sqs_queue.worker.arn}"
        },
        {
          "Effect": "Allow",
          "Action": [
            "kms:Decrypt",
            "kms:GenerateDataKey"
          ],
          "Resource": "${data.terraform_remote_state.security.outputs.sqs_kms_key.arn}"
        }
      ]
    }
  POLICY
}

resource "aws_ssm_parameter" "website_policy_arn" {
  type  = "String"
  name  = format("/our-wedding/%s/apps/website/policy-arn", local.stage)
  value = aws_iam_policy.website.arn
  tags  = local.tags
}
