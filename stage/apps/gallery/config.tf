locals {
  stage = trimprefix(var.TFC_WORKSPACE_NAME, "our-wedding-apps-gallery-")

  tags = {
    Service     = "OurWedding"
    Application = "Gallery"
    Env         = title(local.stage)
  }
}

terraform {
  required_version = ">= 1.2.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.27.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.3.2"
    }
    template = {
      source  = "hashicorp/template"
      version = ">= 2.2"
    }
  }

  backend "remote" {
    organization = "EddMann"

    workspaces {
      prefix = "our-wedding-apps-gallery-"
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

data "terraform_remote_state" "data" {
  backend = "remote"

  config = {
    organization = "EddMann"

    workspaces = {
      name = format("our-wedding-data-gallery-%s", local.stage)
    }
  }
}

data "aws_caller_identity" "current" {}
