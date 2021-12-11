variable "root_domain_name" {
  type        = string
  description = "The root domain name which hosts the service"
}

variable "stages" {
  type        = list(string)
  default     = ["staging", "prod"]
  description = "The stages that are present for this service"
}
