output "photo_bucket" {
  value = {
    arn                 = aws_s3_bucket.photo.arn,
    domain_name         = aws_s3_bucket.photo.bucket_regional_domain_name,
    cloudfront_identity = aws_cloudfront_origin_access_identity.photo.cloudfront_access_identity_path
  }
  description = ""
}

output "upload_bucket" {
  value = {
    arn         = aws_s3_bucket.upload.arn,
    domain_name = aws_s3_bucket.upload.bucket_regional_domain_name
  }
  description = ""
}

output "table_arn" {
  value       = aws_dynamodb_table.gallery.arn
  description = ""
}
