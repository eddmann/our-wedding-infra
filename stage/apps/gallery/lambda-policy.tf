resource "aws_iam_policy" "gallery" {
  name_prefix = format("our-wedding-%s-gallery-", local.stage)

  policy = <<-POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "dynamodb:*"
          ],
          "Resource": [
            "${data.terraform_remote_state.data.outputs.table_arn}",
            "${data.terraform_remote_state.data.outputs.table_arn}/index/*"
          ]
        },
        {
          "Effect": "Allow",
          "Action": "kms:Decrypt",
          "Resource": "${data.terraform_remote_state.security.outputs.dynamodb_kms_key.arn}"
        },
        {
          "Effect": "Allow",
          "Action": [
            "s3:*"
          ],
          "Resource": [
            "${data.terraform_remote_state.data.outputs.photo_bucket_arn}",
            "${data.terraform_remote_state.data.outputs.photo_bucket_arn}/*",
            "${data.terraform_remote_state.data.outputs.upload_bucket_arn}",
            "${data.terraform_remote_state.data.outputs.upload_bucket_arn}/*"
          ]
        }
      ]
    }
  POLICY
}

resource "aws_ssm_parameter" "gallery_policy_arn" {
  type  = "String"
  name  = format("/our-wedding/%s/apps/gallery/policy-arn", local.stage)
  value = aws_iam_policy.gallery.arn
  tags  = local.tags
}
