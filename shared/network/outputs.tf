output "root_domain_name_servers" {
  value = aws_route53_zone.root.name_servers
}

output "dns_stage_zone_ids" {
  value = { for stage in local.dns_stages : (stage) => aws_route53_zone.stage[stage].zone_id }
}
