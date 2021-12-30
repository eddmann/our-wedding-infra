output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnet_ids" {
  value = aws_subnet.private.*.id
}

output "public_subnet_ids" {
  value = aws_subnet.public.*.id
}

output "default_security_group_id" {
  value = aws_vpc.main.default_security_group_id
}

output "nat_instance_ip" {
  value = aws_eip.nat_instance.public_ip
}

output "dns_app_zone_ids" {
  value = { for app in var.app_names : (app) => aws_route53_zone.app[app].zone_id }
}
