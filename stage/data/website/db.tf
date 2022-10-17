locals {
  website_db_subnet_group_name = format("our-wedding-%s-website", local.stage)
}

resource "aws_db_subnet_group" "website" {
  name       = local.website_db_subnet_group_name
  subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids

  tags = local.tags
}

resource "random_password" "website_db_root_password" {
  length  = 32
  special = false
}

resource "aws_rds_cluster" "website" {
  cluster_identifier_prefix = format("our-wedding-%s-website-", local.stage)

  database_name   = format("our_wedding_%s_website", local.stage)
  master_username = "root"
  master_password = random_password.website_db_root_password.result

  vpc_security_group_ids          = [data.terraform_remote_state.network.outputs.default_security_group_id]
  db_subnet_group_name            = aws_db_subnet_group.website.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.website.id

  engine         = "aurora-postgresql"
  engine_mode    = "serverless"
  engine_version = "10.18"

  deletion_protection   = false
  copy_tags_to_snapshot = true
  skip_final_snapshot   = true
  apply_immediately     = true

  #tfsec:ignore:aws-rds-backup-retention-specified
  backup_retention_period = 1

  kms_key_id        = data.terraform_remote_state.security.outputs.rds_kms_key.arn
  storage_encrypted = true

  scaling_configuration {
    auto_pause               = true
    max_capacity             = 2
    min_capacity             = 2
    seconds_until_auto_pause = 300
  }

  tags = local.tags
}

resource "aws_rds_cluster_parameter_group" "website" {
  name_prefix = format("our-wedding-%s-website-", local.stage)
  family      = "aurora-postgresql10"

  parameter {
    name  = "timezone"
    value = "Europe/London"
  }

  tags = local.tags
}

resource "aws_secretsmanager_secret" "website_db_url" {
  kms_key_id = data.terraform_remote_state.security.outputs.secrets_manager_kms_key.id

  name = format("/our-wedding/%s/data/website/db-url", local.stage)

  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "website_db_url" {
  secret_id = aws_secretsmanager_secret.website_db_url.id

  secret_string = format(
    "postgresql://%s:%s@%s:%d/%s?serverVersion=10.14&charset=utf8",
    aws_rds_cluster.website.master_username,
    random_password.website_db_root_password.result,
    aws_rds_cluster.website.endpoint,
    aws_rds_cluster.website.port,
    aws_rds_cluster.website.database_name,
  )
}

#
# Health checks
#

# CPUUtilization > 75%
resource "aws_cloudwatch_metric_alarm" "health_check_website_db_cpu_utilization" {
  alarm_name = format("OurWedding-%s-Website-RdsCpuUtilization", title(local.stage))

  namespace           = "AWS/RDS"
  metric_name         = "CPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  threshold           = "75"
  evaluation_periods  = "1"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.website.id
  }

  alarm_actions   = [data.terraform_remote_state.health.outputs.health_checks_sns_topic_arn]
  actions_enabled = true

  tags = local.tags
}

# FreeableMemory < 128M
resource "aws_cloudwatch_metric_alarm" "health_check_website_db_freeable_memory" {
  alarm_name = format("OurWedding-%s-Website-RdsFreeableMemory", title(local.stage))

  namespace           = "AWS/RDS"
  metric_name         = "FreeableMemory"
  comparison_operator = "LessThanThreshold"
  threshold           = "134217728" # bytes
  evaluation_periods  = "1"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.website.id
  }

  alarm_actions   = [data.terraform_remote_state.health.outputs.health_checks_sns_topic_arn]
  actions_enabled = true

  tags = local.tags
}

# FreeStorageSpace < 5G
resource "aws_cloudwatch_metric_alarm" "health_check_website_db_free_storage_space" {
  alarm_name = format("OurWedding-%s-Website-RdsFreeStorageSpace", title(local.stage))

  namespace           = "AWS/RDS"
  metric_name         = "FreeStorageSpace"
  comparison_operator = "LessThanThreshold"
  threshold           = "5368709120" # bytes
  evaluation_periods  = "1"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.website.id
  }

  alarm_actions   = [data.terraform_remote_state.health.outputs.health_checks_sns_topic_arn]
  actions_enabled = true

  tags = local.tags
}
