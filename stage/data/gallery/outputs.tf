output "photo_bucket_arn" {
  value       = aws_s3_bucket.photo.arn
  description = ""
}

output "upload_bucket_arn" {
  value       = aws_s3_bucket.upload.arn
  description = ""
}

output "table_arn" {
  value       = aws_dynamodb_table.gallery.arn
  description = ""
}
