locals {
  dns_stages = toset(["staging", "prod"])
}

resource "aws_route53_zone" "root" {
  name = var.root_domain_name
  tags = local.tags
}

resource "aws_route53_zone" "stage" {
  for_each = local.dns_stages

  name = format("%s.%s", each.value, var.root_domain_name)
  tags = local.tags
}

resource "aws_route53_record" "stage_ns" {
  for_each = local.dns_stages

  zone_id = aws_route53_zone.root.zone_id
  name    = aws_route53_zone.stage[each.value].name
  records = aws_route53_zone.stage[each.value].name_servers
  type    = "NS"
  ttl     = "300"
}
