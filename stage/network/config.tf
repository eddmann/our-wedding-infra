locals {
  stage = trimprefix(var.ATLAS_WORKSPACE_NAME, "our-wedding-network-")

  tags = {
    Service = "OurWedding"
    Env     = title(local.stage)
  }
}

terraform {
  required_version = ">= 1.0.11"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.68.0"
    }
  }

  backend "remote" {
    organization = "EddMann"

    workspaces {
      prefix = "our-wedding-network-"
    }
  }
}

provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = var.aws_region
}
