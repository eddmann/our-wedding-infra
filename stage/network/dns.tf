data "aws_route53_zone" "stage" {
  zone_id = data.terraform_remote_state.shared_network.outputs.dns_stage_zone_ids[local.stage]
}

resource "aws_route53_zone" "app" {
  for_each = toset(var.app_names)

  name = format("%s.%s", each.value, data.aws_route53_zone.stage.name)
  tags = local.tags
}

resource "aws_route53_record" "app_ns" {
  for_each = toset(var.app_names)

  zone_id = data.aws_route53_zone.stage.zone_id
  name    = aws_route53_zone.app[each.value].name
  records = aws_route53_zone.app[each.value].name_servers
  type    = "NS"
  ttl     = "300"
}
