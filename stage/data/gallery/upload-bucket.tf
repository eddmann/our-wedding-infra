#tfsec:ignore:aws-s3-enable-versioning
#tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "upload" {
  bucket_prefix = format("our-wedding-%s-gallery-upload-", local.stage)
  tags          = local.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "upload" {
  bucket = aws_s3_bucket.upload.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_acl" "upload" {
  bucket = aws_s3_bucket.upload.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "upload" {
  bucket = aws_s3_bucket.upload.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_cors_configuration" "upload" {
  bucket = aws_s3_bucket.upload.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "upload" {
  bucket = aws_s3_bucket.upload.id

  rule {
    id = "Cleanup"

    expiration {
      days = 7
    }

    status = "Enabled"
  }
}

resource "aws_ssm_parameter" "upload_bucket_name" {
  type  = "String"
  name  = format("/our-wedding/%s/apps/gallery/upload-s3-bucket-name", local.stage)
  value = aws_s3_bucket.upload.id
}
