resource "aws_route53_zone" "root" {
  name = var.root_domain_name
  tags = local.tags
}

resource "aws_route53_zone" "stage" {
  for_each = var.stages

  name = format("%s.%s", each.value, var.root_domain_name)
  tags = local.tags
}

resource "aws_route53_record" "stage_ns" {
  for_each = var.stages

  zone_id = aws_route53_zone.root.zone_id
  name    = aws_route53_zone.stage[each.value].name
  records = aws_route53_zone.stage[each.value].name_servers
  type    = "NS"
  ttl     = "300"
}

resource "aws_route53_zone" "gallery" {
  name = format("photos.%s", var.root_domain_name)
  tags = local.tags
}

resource "aws_route53_record" "gallery_ns" {
  zone_id = aws_route53_zone.root.zone_id
  name    = aws_route53_zone.gallery.name
  records = aws_route53_zone.gallery.name_servers
  type    = "NS"
  ttl     = "300"
}
