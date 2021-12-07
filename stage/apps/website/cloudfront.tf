#tfsec:ignore:AWS045
resource "aws_cloudfront_distribution" "website" {
  enabled         = true
  is_ipv6_enabled = true
  price_class     = "PriceClass_100"
  http_version    = "http2"

  default_cache_behavior {
    target_origin_id       = "Website"
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"

    min_ttl     = 0
    max_ttl     = 0
    default_ttl = 0

    forwarded_values {
      query_string = true

      headers = [
        "Accept",
        "Accept-Language",
        "Origin",
        "Referer"
      ]

      cookies {
        forward = "all"
      }
    }
  }

  ordered_cache_behavior {
    target_origin_id       = "Assets"
    path_pattern           = "build/*"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"

    compress    = true
    min_ttl     = 0
    max_ttl     = 31536000
    default_ttl = 86400

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  origin {
    origin_id   = "Assets"
    domain_name = aws_s3_bucket.assets.bucket_regional_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.assets.cloudfront_access_identity_path
    }
  }

  origin {
    origin_id   = "Website"
    domain_name = var.origin_domain_name

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "https-only"
      origin_read_timeout      = 30
      origin_ssl_protocols     = ["TLSv1.2"]
    }
  }

  dynamic "custom_error_response" {
    for_each = [400, 403, 403, 404, 405, 414, 416, 500, 501, 502, 503, 504]

    content {
      error_caching_min_ttl = 0
      error_code            = custom_error_response.value
      response_code         = 0
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = local.tags
}
