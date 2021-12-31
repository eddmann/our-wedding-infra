output "root_domain_name_servers" {
  value       = aws_route53_zone.root.name_servers
  description = "NS records which can be supplied to a third-party domain registrar"
}

output "dns_stage_zone_ids" {
  value       = { for stage in var.stages : (stage) => aws_route53_zone.stage[stage].zone_id }
  description = "Route53 zone IDs for each defined stage, delegating provision responsibility to each stage network project"
}
