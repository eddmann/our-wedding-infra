locals {
  stage = trimprefix(var.TFC_WORKSPACE_NAME, "our-wedding-security-")

  tags = {
    Service = "OurWedding"
    Env     = title(local.stage)
  }
}

terraform {
  required_version = ">= 1.1.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0"
    }
  }

  backend "remote" {
    organization = "EddMann"

    workspaces {
      prefix = "our-wedding-security-"
    }
  }
}

provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = var.aws_region
}

data "aws_caller_identity" "current" {}
