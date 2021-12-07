resource "aws_s3_bucket" "assets" {
  bucket_prefix = format("our-wedding-%s-website-assets-", local.stage)
  acl           = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = data.terraform_remote_state.security.outputs.s3_kms_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = local.tags
}

resource "aws_s3_bucket_public_access_block" "assets" {
  bucket = aws_s3_bucket.assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_identity" "assets" {
  comment = format("our-wedding-%s-website-assets", local.stage)
}

# https://aws-blog.de/2020/09/enforcing-encryption-standards-on-s3-objects.html
resource "aws_s3_bucket_policy" "assets" {
  bucket = aws_s3_bucket.assets.id

  policy = <<-POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": "s3:GetObject",
          "Resource": "${aws_s3_bucket.assets.arn}/*",
          "Principal": {
            "AWS": "${aws_cloudfront_origin_access_identity.assets.iam_arn}"
          }
        },
        {
          "Effect": "Deny",
          "Principal": "*",
          "Action": "s3:PutObject",
          "Resource": "${aws_s3_bucket.assets.arn}/*",
          "Condition": {
            "StringNotEquals": {
              "s3:x-amz-server-side-encryption": "aws:kms"
            },
            "Null": {
              "s3:x-amz-server-side-encryption": "false"
            }
          }
        },
        {
          "Effect": "Deny",
          "Principal": "*",
          "Action": "s3:PutObject",
          "Resource": "${aws_s3_bucket.assets.arn}/*",
          "Condition": {
            "StringNotEqualsIfExists": {
              "s3:x-amz-server-side-encryption-aws-kms-key-id": "${data.terraform_remote_state.security.outputs.s3_kms_key.arn}"
            }
          }
        }
      ]
    }
  POLICY
}

resource "aws_ssm_parameter" "assets_bucket_name" {
  type  = "String"
  name  = format("/our-wedding/%s/apps/website/assets-s3-bucket-name", local.stage)
  value = aws_s3_bucket.assets.id
}
