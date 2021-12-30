#
# SQS
#
resource "aws_vpc_endpoint" "sqs" {
  count = contains(var.vpc_endpoints, "sqs") ? 1 : 0

  vpc_id              = aws_vpc.main.id
  service_name        = format("com.amazonaws.%s.sqs", var.aws_region)
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private.*.id
  security_group_ids  = [aws_vpc.main.default_security_group_id]
  private_dns_enabled = true

  tags = local.tags
}

#
# Secrets Manager
#
resource "aws_vpc_endpoint" "secretsmanager" {
  count = contains(var.vpc_endpoints, "secretsmanager") ? 1 : 0

  vpc_id              = aws_vpc.main.id
  service_name        = format("com.amazonaws.%s.secretsmanager", var.aws_region)
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private.*.id
  security_group_ids  = [aws_vpc.main.default_security_group_id]
  private_dns_enabled = true

  tags = local.tags
}

#
# DynamoDB
#
resource "aws_vpc_endpoint" "dynamodb" {
  count = contains(var.vpc_endpoints, "dynamodb") ? 1 : 0

  vpc_id            = aws_vpc.main.id
  service_name      = format("com.amazonaws.%s.dynamodb", var.aws_region)
  vpc_endpoint_type = "Gateway"

  tags = local.tags
}

resource "aws_vpc_endpoint_route_table_association" "dynamodb" {
  count = contains(var.vpc_endpoints, "dynamodb") ? length(var.availability_zones) : 0

  vpc_endpoint_id = aws_vpc_endpoint.dynamodb[0].id
  route_table_id  = element(aws_route_table.private.*.id, count.index)
}
