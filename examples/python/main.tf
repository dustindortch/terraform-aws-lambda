terraform {
  required_version = "~> 1.8"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {}

module "lambda" {
  source = "../.."

  name        = "example"
  handler     = "lambda.lambda_handler"
  runtime     = "python3.12"
  source_file = "${path.module}/lambda.py"
}
