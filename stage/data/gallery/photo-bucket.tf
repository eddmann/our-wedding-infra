#tfsec:ignore:aws-s3-enable-versioning
#tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "photo" {
  bucket_prefix = format("our-wedding-%s-gallery-photo-", local.stage)
  tags          = local.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "photo" {
  bucket = aws_s3_bucket.photo.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_acl" "photo" {
  bucket = aws_s3_bucket.photo.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "photo" {
  bucket = aws_s3_bucket.photo.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_identity" "photo" {
  comment = format("our-wedding-%s-website-photo", local.stage)
}

resource "aws_s3_bucket_policy" "photo" {
  bucket = aws_s3_bucket.photo.id

  policy = <<-POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": "s3:GetObject",
          "Resource": "${aws_s3_bucket.photo.arn}/*",
          "Principal": {
            "AWS": "${aws_cloudfront_origin_access_identity.photo.iam_arn}"
          }
        }
      ]
    }
  POLICY
}

resource "aws_ssm_parameter" "photo_bucket_name" {
  type  = "String"
  name  = format("/our-wedding/%s/apps/gallery/photo-s3-bucket-name", local.stage)
  value = aws_s3_bucket.photo.id
}

resource "aws_ssm_parameter" "photo_bucket_prefix" {
  type  = "String"
  name  = format("/our-wedding/%s/apps/gallery/photo-s3-bucket-prefix", local.stage)
  value = "photo"
}
