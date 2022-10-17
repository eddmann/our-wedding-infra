locals {
  stage = trimprefix(var.TFC_WORKSPACE_NAME, "our-wedding-data-website-")

  tags = {
    Service     = "OurWedding"
    Application = "Website"
    Env         = title(local.stage)
  }
}

terraform {
  required_version = ">= 1.3.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.35.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.3.2"
    }
  }

  backend "remote" {
    organization = "EddMann"

    workspaces {
      prefix = "our-wedding-data-website-"
    }
  }
}

provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = var.aws_region
}

data "terraform_remote_state" "network" {
  backend = "remote"

  config = {
    organization = "EddMann"

    workspaces = {
      name = format("our-wedding-network-%s", local.stage)
    }
  }
}

data "terraform_remote_state" "security" {
  backend = "remote"

  config = {
    organization = "EddMann"

    workspaces = {
      name = format("our-wedding-security-%s", local.stage)
    }
  }
}

data "terraform_remote_state" "health" {
  backend = "remote"

  config = {
    organization = "EddMann"

    workspaces = {
      name = format("our-wedding-health-%s", local.stage)
    }
  }
}
