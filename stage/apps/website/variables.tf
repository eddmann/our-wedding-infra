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
