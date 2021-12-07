locals {
  queue_name = format("our-wedding-%s-website-worker", local.stage)
}

resource "aws_sqs_queue" "worker" {
  name = local.queue_name

  kms_master_key_id = data.terraform_remote_state.security.outputs.sqs_kms_key.id

  visibility_timeout_seconds = 120 # the worker lambda duration

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.worker_dlq.arn
    maxReceiveCount     = 5
  })

  tags = local.tags
}

resource "aws_sqs_queue" "worker_dlq" {
  name = format("%s-dlq", local.queue_name)

  kms_master_key_id = data.terraform_remote_state.security.outputs.sqs_kms_key.id

  message_retention_seconds = 1209600 # 14 days

  tags = local.tags
}

resource "aws_ssm_parameter" "worker_queue_url" {
  type  = "String"
  name  = format("/our-wedding/%s/apps/website/worker-queue-url", local.stage)
  value = aws_sqs_queue.worker.id
  tags  = local.tags
}

resource "aws_ssm_parameter" "worker_queue_arn" {
  type  = "String"
  name  = format("/our-wedding/%s/apps/website/worker-queue-arn", local.stage)
  value = aws_sqs_queue.worker.arn
  tags  = local.tags
}
