locals {
  stage = trimprefix(var.TFC_WORKSPACE_NAME, "our-wedding-health-")

  tags = {
    Service = "OurWedding"
    Env     = title(local.stage)
  }
}

terraform {
  required_version = ">= 1.3.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.35.0"
    }
  }

  backend "remote" {
    organization = "EddMann"

    workspaces {
      prefix = "our-wedding-health-"
    }
  }
}

provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = var.aws_region
}

provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = "us-east-1"
  alias      = "us_east_1"
}
