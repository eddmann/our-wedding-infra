variable "TFC_WORKSPACE_NAME" {
  type        = string
  description = "Provided by Terraform Cloud so as to determine the stage"
}

variable "api_origin_domain_name" {
  type        = string
  description = "The API-GW domain name which hosts the API"
}

variable "api_origin_domain_auth_key_header" {
  type        = string
  description = "The authentication key header used to proxy requests to the origin API"
  default     = "X-CloudFront-Auth-Key"
}

variable "vanity_dns_zone_id" {
  type        = string
  description = "Optional, primary DNS zone to configure, used for customer-facing domains"
  default     = null
}

variable "gallery_username" {
  type        = string
  description = "The username used to access the gallery"
}

variable "gallery_password" {
  type        = string
  description = "The password used to access the gallery"
}
