locals {
  name = format("our-wedding-%s", local.stage)
}

resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true

  tags = merge(local.tags, { Name = local.name })
}

#
# Gateways
#
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.tags, { Name = local.name })
}

#
# Public routes
#
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.tags, { Name = format("%s-public", local.name) })
}

resource "aws_route" "internet_gateway" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.main.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public" {
  count = length(var.availability_zones)

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

#
# Private routes
#
resource "aws_route_table" "private" {
  count = length(var.availability_zones)

  vpc_id = aws_vpc.main.id

  tags = merge(local.tags, { Name = format("%s-private-%s", local.name, element(var.availability_zones, count.index)) })
}

resource "aws_route_table_association" "private" {
  count = length(var.availability_zones)

  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

#
# Subnets
#
resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.cidr_block, 8, count.index)
  availability_zone       = "${var.aws_region}${element(var.availability_zones, count.index)}"
  map_public_ip_on_launch = true

  tags = merge(local.tags, { Name = format("%s-public-%s", local.name, element(var.availability_zones, count.index)) })
}

resource "aws_subnet" "private" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, count.index + 100)
  availability_zone = "${var.aws_region}${element(var.availability_zones, count.index)}"

  tags = merge(local.tags, { Name = format("%s-private-%s", local.name, element(var.availability_zones, count.index)) })
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
  value = join(",", aws_subnet.private.*.id)

  tags = local.tags
}
