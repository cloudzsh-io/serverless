locals {
  aws_region = var.aws_region

  application_prefix = var.application_prefix # snake_case
  application_name   = var.application_name   # PascalCase

  jwt_issuer   = var.jwt_issuer
  jwt_audience = var.jwt_audience

  lambda_archive_file_path = var.lambda_archive_file_path
  lambda_bucket_name       = var.lambda_archive_bucket_name

  environment_variables = var.environment_variables

  functions = var.functions

  api_gateway_stage_name = var.api_gateway_stage_name

  apis = var.apis

  scheduled_jobs = var.scheduled_jobs

  api_gateway_domain = var.api_gateway_domain
  hosted_zone_name   = var.hosted_zone_name
}
