resource "aws_vpc_endpoint" "endpoints" {
  for_each = toset(["sqs", "secretsmanager"])

  vpc_id              = aws_vpc.main.id
  service_name        = format("com.amazonaws.%s.%s", var.aws_region, each.value)
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private.*.id
  security_group_ids  = [aws_vpc.main.default_security_group_id]
  private_dns_enabled = true

  tags = local.tags
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = aws_vpc.main.id
  service_name      = format("com.amazonaws.%s.dynamodb", var.aws_region)
  vpc_endpoint_type = "Gateway"

  tags = local.tags
}

resource "aws_vpc_endpoint_route_table_association" "dynamodb" {
  count = length(var.availability_zones)

  vpc_endpoint_id = aws_vpc_endpoint.dynamodb.id
  route_table_id  = element(aws_route_table.private.*.id, count.index)
}
