# We would enforce SSE-KMS here, but S3 buckets fronted by CloudFront require
# a Request function to handle decrypting these client. As such we have opted
# for SSE-S3.

#tfsec:ignore:aws-s3-enable-versioning
#tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "client" {
  bucket_prefix = format("our-wedding-%s-gallery-client-", local.stage)
  tags          = local.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "client" {
  bucket = aws_s3_bucket.client.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_acl" "client" {
  bucket = aws_s3_bucket.client.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "client" {
  bucket = aws_s3_bucket.client.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_identity" "client" {
  comment = format("our-wedding-%s-gallery-client", local.stage)
}

# Reference: https://aws-blog.de/2020/09/enforcing-encryption-standards-on-s3-objects.html
resource "aws_s3_bucket_policy" "client" {
  bucket = aws_s3_bucket.client.id

  policy = <<-POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": "s3:GetObject",
          "Resource": "${aws_s3_bucket.client.arn}/*",
          "Principal": {
            "AWS": "${aws_cloudfront_origin_access_identity.client.iam_arn}"
          }
        },
        {
          "Effect": "Deny",
          "Principal": "*",
          "Action": "s3:PutObject",
          "Resource": "${aws_s3_bucket.client.arn}/*",
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

resource "aws_ssm_parameter" "client_bucket_name" {
  type  = "String"
  name  = format("/our-wedding/%s/apps/gallery/client-s3-bucket-name", local.stage)
  value = aws_s3_bucket.client.id
}
