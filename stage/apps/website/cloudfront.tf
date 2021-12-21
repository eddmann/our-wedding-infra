resource "aws_cloudfront_distribution" "website" {
  enabled         = true
  is_ipv6_enabled = true
  price_class     = "PriceClass_100"
  http_version    = "http2"

  aliases = [
    data.aws_route53_zone.app.name,
    format("www.%s", data.aws_route53_zone.app.name)
  ]

  default_cache_behavior {
    target_origin_id           = "Website"
    allowed_methods            = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods             = ["GET", "HEAD"]
    viewer_protocol_policy     = "redirect-to-https"
    cache_policy_id            = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # CachingDisabled
    origin_request_policy_id   = "216adef6-5c7f-47e4-b989-5492eafa07d3" # AllViewer
    response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03" # SecurityHeadersPolicy
  }

  ordered_cache_behavior {
    target_origin_id           = "Assets"
    path_pattern               = "build/*"
    allowed_methods            = ["GET", "HEAD"]
    cached_methods             = ["GET", "HEAD"]
    viewer_protocol_policy     = "redirect-to-https"
    compress                   = true
    cache_policy_id            = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
    origin_request_policy_id   = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" # CORS-S3Origin
    response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03" # SecurityHeadersPolicy
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

    custom_header {
      name  = var.origin_domain_auth_key_header
      value = random_password.auto_generated["origin-domain-auth-key"].result
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
    acm_certificate_arn      = aws_acm_certificate_validation.apex.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = local.tags
}

resource "aws_ssm_parameter" "origin_domain_auth_key_header" {
  type  = "String"
  name  = format("/our-wedding/%s/apps/website/origin-domain-auth-key-header", local.stage)
  value = var.origin_domain_auth_key_header
  tags  = local.tags
}
