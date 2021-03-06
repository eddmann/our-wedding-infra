data "template_file" "viewer_request" {
  template = file("${path.module}/resources/viewer-request.js")

  vars = {
    DOMAIN = local.has_vanity_domain ? data.aws_route53_zone.vanity.name : data.aws_route53_zone.app.name
  }
}

resource "aws_cloudfront_function" "viewer_request" {
  name    = format("our-wedding-website-%s-viewer-request", local.stage)
  runtime = "cloudfront-js-1.0"
  publish = true
  code    = data.template_file.viewer_request.rendered
}

resource "aws_iam_role" "origin_response" {
  name = format("our-wedding-website-%s-origin-response", local.stage)

  assume_role_policy = <<-POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": [
                "lambda.amazonaws.com",
                "edgelambda.amazonaws.com"
            ]
          },
          "Effect": "Allow"
        }
      ]
    }
  POLICY

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "origin_response" {
  role       = aws_iam_role.origin_response.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "origin_response" {
  type        = "zip"
  output_path = "resources/origin-response.zip"

  source {
    filename = "index.js"
    content  = file("resources/origin-response.js")
  }
}

resource "aws_lambda_function" "origin_response" {
  provider = aws.us_east_1

  function_name    = format("our-wedding-website-%s-origin-response", local.stage)
  filename         = "resources/origin-response.zip"
  handler          = "index.handler"
  runtime          = "nodejs14.x"
  role             = aws_iam_role.origin_response.arn
  source_code_hash = data.archive_file.origin_response.output_base64sha256
  publish          = true

  tags = local.tags
}

# Replicates `CachingDisabled` managed cache policies, but includes `Authorization` header
# https://aws.amazon.com/premiumsupport/knowledge-center/cloudfront-authorization-header/
resource "aws_cloudfront_cache_policy" "website" {
  name = format("our-wedding-website-%s", local.stage)

  default_ttl = 0
  max_ttl     = 1 # required to pass `Authorization` header
  min_ttl     = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "none"
    }

    headers_config {
      header_behavior = "whitelist"
      headers {
        items = ["Authorization"]
      }
    }

    enable_accept_encoding_brotli = false
    enable_accept_encoding_gzip   = false
  }
}

resource "aws_cloudfront_origin_request_policy" "website" {
  name = format("our-wedding-website-%s", local.stage)

  cookies_config {
    cookie_behavior = "all"
  }

  headers_config {
    header_behavior = "whitelist"
    headers {
      items = ["Accept", "Accept-Language", "Accept-Datetime", "Accept-Charset", "Origin", "Referer", "User-Agent"]
    }
  }

  query_strings_config {
    query_string_behavior = "all"
  }
}

#tfsec:ignore:aws-cloudfront-enable-waf
#tfsec:ignore:aws-cloudfront-enable-logging
resource "aws_cloudfront_distribution" "website" {
  enabled         = true
  is_ipv6_enabled = true
  price_class     = "PriceClass_100"
  http_version    = "http2"

  aliases = concat(local.app_domains, local.vanity_domains)

  default_cache_behavior {
    target_origin_id           = "Website"
    allowed_methods            = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods             = ["GET", "HEAD"]
    viewer_protocol_policy     = "redirect-to-https"
    cache_policy_id            = aws_cloudfront_cache_policy.website.id
    origin_request_policy_id   = aws_cloudfront_origin_request_policy.website.id
    response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03" # SecurityHeadersPolicy

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.viewer_request.arn
    }

    lambda_function_association {
      event_type = "origin-response"
      lambda_arn = aws_lambda_function.origin_response.qualified_arn
    }
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

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.viewer_request.arn
    }

    lambda_function_association {
      event_type = "origin-response"
      lambda_arn = aws_lambda_function.origin_response.qualified_arn
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

    custom_header {
      name  = var.origin_domain_auth_key_header
      value = random_password.auto_generated["origin-domain-auth-key"].result
    }
  }

  dynamic "custom_error_response" {
    for_each = [400, 403, 404, 405, 414, 416, 500, 501, 502, 503, 504]

    content {
      error_caching_min_ttl = 0
      error_code            = custom_error_response.value
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.app.certificate_arn
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
