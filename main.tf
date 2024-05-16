terraform {
  required_version = "~> 1.8"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "execution_policy" {
  statement {
    effect = "Allow"

    resources = ["*"]

    actions = [
      "ec2:DescribeNetworkInterfaces",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeInstances",
      "ec2:AttachNetworkInterface"
    ]
  }
}

resource "aws_iam_role" "assume_role" {
  name               = "role-lambda-${var.name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "execution_policy" {
  name   = "policy-lambda-${var.name}"
  policy = data.aws_iam_policy_document.execution_policy.json
}

resource "aws_iam_role_policy_attachment" "execution_policy" {
  role       = aws_iam_role.assume_role.name
  policy_arn = aws_iam_policy.execution_policy.arn
}

locals {
  archive_build = anytrue([
    var.source_dir != null,
    var.source_file != null
  ])
  archive_create = local.archive_build ? 1 : 0

  xor_sources = sum([
    var.image_uri != null ? 1 : 0,
    var.package_file != null ? 1 : 0,
    var.source_dir != null ? 1 : 0,
    var.source_file != null ? 1 : 0
  ]) == 1
}

resource "random_uuid" "package_uuid" {}

data "archive_file" "package" {
  count = local.archive_create
  lifecycle {
    precondition {
      condition     = local.xor_sources
      error_message = "Exactly one of image_uri, package_file, source_dir, or source_file must be provided."
    }
  }

  type        = "zip"
  source_dir  = var.source_dir
  source_file = var.source_file
  output_path = "${path.module}/${random_uuid.package_uuid.result}.zip"
}

locals {
  package = {
    file = local.archive_build && local.xor_sources ? data.archive_file.package[0].output_path : var.package_file
    hash = local.archive_build && local.xor_sources ? data.archive_file.package[0].output_base64sha256 : (
      var.package_file != null ? base64sha256(var.package_file) : null
    )
    type = local.archive_build || var.package_file != null ? "zip" : null
  }
  environment_variables = var.environment_variables != {} ? [1] : []
  vpc_config            = var.vpc_config != {} ? [1] : []
}

resource "aws_lambda_function" "lambda" {
  filename      = local.package.file
  function_name = var.name
  image_uri     = var.image_uri
  package_type  = local.package.type
  role          = aws_iam_role.assume_role.arn

  source_code_hash = local.package.hash

  handler = var.handler
  runtime = var.runtime

  dynamic "environment" {
    for_each = local.environment_variables

    content {
      variables = var.environment_variables
    }
  }

  dynamic "vpc_config" {
    for_each = local.vpc_config

    content {
      ipv6_allowed_for_dual_stack = var.vpc_config.ipv6_allowed_for_dual_stack
      security_group_ids          = var.vpc_config.security_group_ids
      subnet_ids                  = var.vpc_config.subnet_ids
    }
  }
}

locals {
  event_mapping = {
    for k, v in var.event_mapping : k => merge(
      v,
      {
        enable_self_managed_event_source = length(v.kafka_self_managed_source_endpoints) > 0 ? [1] : []
        kafka_bootstrap_servers          = join(",", v.kafka_self_managed_source_endpoints)
      }
    )
  }
}

resource "aws_lambda_event_source_mapping" "lambda" {
  for_each = local.event_mapping

  event_source_arn = each.value.source_arn
  function_name    = aws_lambda_function.lambda.arn

  dynamic "self_managed_event_source" {
    for_each = each.value.enable_self_managed_event_source

    content {
      endpoints = {
        KAFKA_BOOTSTRAP_SERVERS = each.value.kafka_bootstrap_servers
      }
    }
  }
}
