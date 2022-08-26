locals {
  tags = {
    Service = "OurWedding"
    Env     = "Shared"
  }
}

terraform {
  required_version = ">= 1.2.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.27.0"
    }
  }

  backend "remote" {
    organization = "EddMann"

    workspaces {
      name = "our-wedding-shared-network"
    }
  }
}

provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = var.aws_region
}
