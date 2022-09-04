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
  acl    = "public-read"
}

resource "aws_s3_bucket_cors_configuration" "photo" {
  bucket = aws_s3_bucket.photo.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}

resource "aws_ssm_parameter" "photo_bucket_name" {
  type  = "String"
  name  = format("/our-wedding/%s/apps/gallery/photo-s3-bucket-name", local.stage)
  value = aws_s3_bucket.photo.id
}
