# AWS Region
variable "aws_region" { type = string }

# Namespace
variable "application_name" { type = string }
variable "application_prefix" { type = string }

# JWT Variables
variable "jwt_issuer" { type = string }
variable "jwt_audience" { type = string }

# Lambda Variables
variable "lambda_archive_file_path" { type = string }
variable "lambda_archive_bucket_name" { type = string }

# Function Environment Variables
variable "environment_variables" { type = map(any) }

# Functions
variable "functions" {
  type = map(object({
    handler : string,
    layers : list(string),
    memory_size : number,
    timeout : number
  }))
  default = {}
}

# API Gateway
variable "api_gateway_stage_name" {
  type    = string
  default = "prod"
}

# API(s)
variable "apis" {
  type = map(object({
    function = string,
    route    = string,
    method   = string,
    secure   = bool,
  }))
  default = {}
}

# Scheduled Jobs(s)
variable "scheduled_jobs" {
  type = map(object({
    function            = string,
    name                = string,
    description         = string,
    schedule_expression = string,
  }))
  default = {}
}

# Route53
variable "api_gateway_domain" { type = string }
variable "hosted_zone_name" { type = string }
