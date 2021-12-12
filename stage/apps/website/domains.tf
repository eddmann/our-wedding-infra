data "aws_route53_zone" "app" {
  zone_id = data.terraform_remote_state.network.outputs.dns_app_zone_ids["website"]
}

resource "aws_acm_certificate" "apex" {
  provider = aws.us_east_1

  domain_name               = data.aws_route53_zone.app.name
  subject_alternative_names = [format("www.%s", data.aws_route53_zone.app.name)]

  validation_method = "DNS"

  tags = local.tags
}

resource "aws_route53_record" "apex_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.apex.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true

  zone_id = data.aws_route53_zone.app.zone_id
  name    = each.value.name
  records = [each.value.record]
  type    = each.value.type
  ttl     = 60
}

resource "aws_acm_certificate_validation" "apex" {
  provider = aws.us_east_1

  certificate_arn         = aws_acm_certificate.apex.arn
  validation_record_fqdns = [for record in aws_route53_record.apex_cert_validation : record.fqdn]
}

resource "aws_route53_record" "apex" {
  zone_id = data.aws_route53_zone.app.zone_id
  name    = data.aws_route53_zone.app.name
  type    = "A"

  alias {
    name    = aws_cloudfront_distribution.website.domain_name
    zone_id = aws_cloudfront_distribution.website.hosted_zone_id

    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.app.zone_id
  name    = "www"
  type    = "A"

  alias {
    name    = aws_cloudfront_distribution.website.domain_name
    zone_id = aws_cloudfront_distribution.website.hosted_zone_id

    evaluate_target_health = true
  }
}
