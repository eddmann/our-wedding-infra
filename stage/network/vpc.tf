locals {
  vpc_name = format("our-wedding-%s", local.stage)
}

resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true

  tags = merge(local.tags, { Name = local.vpc_name })
}

#
# Gateways
#
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.tags, { Name = local.vpc_name })
}

#
# Public routes
#
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.tags, { Name = format("%s-public", local.vpc_name) })
}

resource "aws_route" "internet_gateway" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.main.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public" {
  for_each = var.availability_zones

  subnet_id      = aws_subnet.public[each.value].id
  route_table_id = aws_route_table.public.id
}

#
# Private routes
#
resource "aws_route_table" "private" {
  for_each = var.availability_zones

  vpc_id = aws_vpc.main.id

  tags = merge(local.tags, { Name = format("%s-private-%s", local.vpc_name, each.value) })
}

resource "aws_route_table_association" "private" {
  for_each = var.availability_zones

  subnet_id      = aws_subnet.private[each.value].id
  route_table_id = aws_route_table.private[each.value].id
}

#
# Subnets
#
resource "aws_subnet" "public" {
  for_each = var.availability_zones

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.cidr_block, 8, index(tolist(var.availability_zones), each.value))
  availability_zone       = "${var.aws_region}${each.value}"
  map_public_ip_on_launch = true

  tags = merge(local.tags, { Name = format("%s-public-%s", local.vpc_name, each.value) })
}

resource "aws_subnet" "private" {
  for_each = var.availability_zones

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, index(tolist(var.availability_zones), each.value) + 100)
  availability_zone = "${var.aws_region}${each.value}"

  tags = merge(local.tags, { Name = format("%s-private-%s", local.vpc_name, each.value) })
}

#
# SSM parameters
#
resource "aws_ssm_parameter" "default_security_group_id" {
  type  = "String"
  name  = format("/our-wedding/%s/network/default-security-group-id", local.stage)
  value = aws_vpc.main.default_security_group_id

  tags = local.tags
}

resource "aws_ssm_parameter" "private_subnet_ids" {
  type  = "StringList"
  name  = format("/our-wedding/%s/network/private-subnet-ids", local.stage)
  value = join(",", [for s in aws_subnet.private : s.id])

  tags = local.tags
}
