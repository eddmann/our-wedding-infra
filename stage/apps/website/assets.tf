resource "aws_s3_bucket" "assets" {
  bucket_prefix = format("our-wedding-%s-website-assets-", local.stage)
  acl           = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
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

# We would enforce SSE-KMS here, but S3 buckets fronted by CloudFront require
# a Request function to handle decrypting these assets. As such we have opted
# for SSE-S3.
# Reference: https://aws-blog.de/2020/09/enforcing-encryption-standards-on-s3-objects.html
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
              "s3:x-amz-server-side-encryption": "AES256"
            },
            "Null": {
              "s3:x-amz-server-side-encryption": "false"
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
