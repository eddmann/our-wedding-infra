locals {
  has_vanity_domain = var.vanity_dns_zone_id != null
}

data "aws_route53_zone" "app" {
  zone_id = data.terraform_remote_state.network.outputs.dns_app_zone_ids["gallery"]
}

data "aws_route53_zone" "vanity" {
  zone_id = local.has_vanity_domain ? var.vanity_dns_zone_id : data.aws_route53_zone.app.zone_id
}

locals {
  app_domains    = [data.aws_route53_zone.app.name]
  vanity_domains = local.has_vanity_domain ? [data.aws_route53_zone.vanity.name] : []
}

#
# Certificate
#
resource "aws_acm_certificate" "app" {
  provider = aws.us_east_1

  domain_name               = data.aws_route53_zone.app.name
  subject_alternative_names = [for domain in concat(local.app_domains, local.vanity_domains) : domain if domain != data.aws_route53_zone.app.name]

  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = local.tags
}

resource "aws_route53_record" "app_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.app.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    } if contains(local.app_domains, dvo.domain_name)
  }

  allow_overwrite = true

  zone_id = data.aws_route53_zone.app.zone_id
  name    = each.value.name
  records = [each.value.record]
  type    = each.value.type
  ttl     = 60
}

resource "aws_route53_record" "vanity_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.app.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    } if contains(local.vanity_domains, dvo.domain_name)
  }

  allow_overwrite = true

  zone_id = data.aws_route53_zone.vanity.zone_id
  name    = each.value.name
  records = [each.value.record]
  type    = each.value.type
  ttl     = 60
}

resource "aws_acm_certificate_validation" "app" {
  provider = aws.us_east_1

  certificate_arn = aws_acm_certificate.app.arn
  validation_record_fqdns = concat(
    [for record in aws_route53_record.app_cert_validation : record.fqdn],
    [for record in aws_route53_record.vanity_cert_validation : record.fqdn]
  )
}

#
# Records
#
resource "aws_route53_record" "app_apex" {
  zone_id = data.aws_route53_zone.app.zone_id
  name    = data.aws_route53_zone.app.name
  type    = "A"

  alias {
    name    = aws_cloudfront_distribution.gallery.domain_name
    zone_id = aws_cloudfront_distribution.gallery.hosted_zone_id

    evaluate_target_health = true
  }
}

resource "aws_route53_record" "vanity_apex" {
  count = local.has_vanity_domain ? 1 : 0

  zone_id = data.aws_route53_zone.vanity.zone_id
  name    = data.aws_route53_zone.vanity.name
  type    = "A"

  alias {
    name    = aws_cloudfront_distribution.gallery.domain_name
    zone_id = aws_cloudfront_distribution.gallery.hosted_zone_id

    evaluate_target_health = true
  }
}

#
# Host
#
resource "aws_ssm_parameter" "host" {
  type  = "String"
  name  = format("/our-wedding/%s/apps/gallery/host", local.stage)
  value = local.has_vanity_domain ? data.aws_route53_zone.vanity.name : data.aws_route53_zone.app.name
  tags  = local.tags
}
