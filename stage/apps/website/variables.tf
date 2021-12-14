variable "TFC_WORKSPACE_NAME" {
  type        = string
  description = "Provided by Terraform Cloud so as to determine the stage"
}

variable "origin_domain_name" {
  type        = string
  description = "The API-GW domain name which hosts the Website"
}

variable "origin_domain_auth_key_header" {
  type        = string
  description = "The authentication key header used to proxy requests to origin"
  default     = "X-CloudFront-Auth-Key"
}

variable "admin_password" {
  type        = string
  description = "The password which is used to login to the admin system"
}

variable "mailer_dsn" {
  type        = string
  description = "The desired Symfony Mailer DSN used for sending email"
}

variable "email_notifier_to" {
  type        = list(string)
  description = "The addresses to send email notifications to"
}

variable "email_notifier_from" {
  type        = string
  description = "The address to send email notifications from"
}

variable "page_content" {
  type        = map(string)
  description = "The content displayed within the defined site sections"
}
