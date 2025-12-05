terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "alarms" {
  source = "../.."
}

variable "region" {
  description = "AWS region for the example."
  type        = string
  default     = "eu-west-2"
}

