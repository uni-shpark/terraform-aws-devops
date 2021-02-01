provider "aws" {
  region = var.region
}

terraform {
  required_version = "0.14.5"

  required_providers {
    aws = ">= 3.22.0"
  }
}
