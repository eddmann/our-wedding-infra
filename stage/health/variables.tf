variable "TFC_WORKSPACE_NAME" {
  type        = string
  description = "Provided by Terraform Cloud so as to determine the stage"
}

variable "notifier_email_address" {
  type        = string
  description = "Email address to send health check notifications to"
}
