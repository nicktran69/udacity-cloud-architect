# TODO: Define the terraform for the lambda function.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region = var.aws_region
}

data "archive_file" "greet_lambda" {
    source_file   = "greet_lambda.py"
    type          = "zip"
    output_path   = "greet_lambda.zip"
}

resource "aws_iam_role" "role_aws_lambda_exec" {
  name = "role_aws_lambda_exec"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Sid": "",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_iam_policy" "role_aws_lambda_log_policy" {
  name        = "role_aws_lambda_log_policy"
  path        = "/"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
    "Action": [
        "logs:CreateLogStream",
        "logs:CreateLogGroup",
        "logs:PutLogEvents"
    ],
    "Effect": "Allow",
    "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_group" "aws_lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_name}"
  retention_in_days = 3
}

resource "aws_iam_role_policy_attachment" "role_aws_lambda_log_policy" {
  role       = aws_iam_role.role_aws_lambda_exec.name
  policy_arn = aws_iam_policy.role_aws_lambda_log_policy.arn
}

resource "aws_lambda_function" "greet_lambda" {
  filename         = "greet_lambda.zip"
  function_name    = var.lambda_name
  handler          = "greet_lambda.lambda_handler"
  source_code_hash = data.archive_file.greet_lambda.output_base64sha256
  role             = aws_iam_role.role_aws_lambda_exec.arn
  runtime          = "python3.8"

  depends_on = [aws_iam_role_policy_attachment.role_aws_lambda_log_policy, aws_cloudwatch_log_group.aws_lambda_log_group]

  environment {
    variables = {
      greeting = "Hello Udacity!!!"
    }
  }
}