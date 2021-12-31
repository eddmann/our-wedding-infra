output "vpc_id" {
  value       = aws_vpc.main.id
  description = "Identifier for the VPC"
}

output "private_subnet_ids" {
  value       = aws_subnet.private.*.id
  description = "Identifiers for private subnets created within VPC"
}

output "public_subnet_ids" {
  value       = aws_subnet.public.*.id
  description = "Identifiers for public subnets created within VPC"
}

output "default_security_group_id" {
  value       = aws_vpc.main.default_security_group_id
  description = "Default permissive security group created when VPC is provisioned"
}

output "nat_instance_ip" {
  value       = aws_eip.nat_instance.public_ip
  description = "The outbound public IP address used by public subnet resources to access the internet"
}

output "dns_app_zone_ids" {
  value       = { for app in var.app_names : (app) => aws_route53_zone.app[app].zone_id }
  description = "Route53 zone IDs for each defined app, delegating provision responsibility to each stage app project"
}
