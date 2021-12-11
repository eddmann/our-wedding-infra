variable "TFC_WORKSPACE_NAME" {
  type        = string
  description = "Provided by Terraform Cloud so as to determine the stage"
}

variable "origin_domain_name" {
  type        = string
  description = "The API-GW domain name which hosts the Website"
}

variable "origin_domain_auth_key_header" {
  type    = string
  default = "X-CloudFront-Auth-Key"
}