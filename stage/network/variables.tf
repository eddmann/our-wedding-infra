variable "TFC_WORKSPACE_NAME" {
  type        = string
  description = "Provided by Terraform Cloud so as to determine the stage"
}

variable "availability_zones" {
  type        = set(string)
  description = "List of availability zones you wish to provision VPC subnets in"
  default     = ["a", "b"]
}

variable "cidr_block" {
  type        = string
  description = "The IP address range used within the VPC"
}

variable "nat_availability_zone" {
  type        = string
  description = "The AZ you wish to place the NAT instance for private subnet outbound internet access"
  default     = "a"
}

variable "nat_spot_instance_types" {
  type        = set(string)
  description = "Spot-based EC2 instance types used for the NAT instance"
  default     = ["t3.nano", "t3a.nano"]
}

variable "vpc_endpoints" {
  type        = set(string)
  description = "Endpoints you wish to configure within the VPC"
  default     = ["sqs", "secretsmanager", "dynamodb"]
}

variable "app_names" {
  type        = set(string)
  description = "The name of the apps which compose this service stage"
}
