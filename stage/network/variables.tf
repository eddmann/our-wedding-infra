variable "TFC_WORKSPACE_NAME" {
  type        = string
  description = "Provided by Terraform Cloud so as to determine the stage"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones you wish to provision VPC subnets in"
  default     = ["a", "b"]
}

variable "cidr_block" {
  type        = string
  description = "The IP address range used within the VPC"
}

variable "app_names" {
  type        = list(string)
  description = "The name of the apps which compose this service stage"
}
