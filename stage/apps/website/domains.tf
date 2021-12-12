data "aws_route53_zone" "app" {
  zone_id = data.terraform_remote_state.network.outputs.dns_app_zone_ids["website"]
}

resource "aws_acm_certificate" "apex" {
  domain_name       = data.aws_route53_zone.app.name
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
  certificate_arn         = aws_acm_certificate.apex.arn
  validation_record_fqdns = [for record in aws_route53_record.apex_cert_validation : record.fqdn]
}
