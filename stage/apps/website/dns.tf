data "aws_route53_zone" "app" {
  zone_id = data.terraform_remote_state.network.outputs.dns_app_zone_ids["website"]
}

resource "aws_route53_record" "apex" {
  zone_id = data.aws_route53_zone.app.zone_id
  name    = data.aws_route53_zone.app.name
  records = ["1.1.1.1"]
  type    = "A"
  ttl     = "300"
}
