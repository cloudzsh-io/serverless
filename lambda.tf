# Configures the Lambda function(s)
resource "aws_lambda_function" "lambda_function" {
  for_each      = local.functions
  function_name = "${local.application_name}${each.key}"

  layers = each.value.layers

  s3_bucket = data.aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_archive.key

  runtime          = "nodejs12.x"
  handler          = each.value.handler
  source_code_hash = base64encode(filesha256(local.lambda_archive_file_path))

  role = aws_iam_role.lambda_exec.arn

  timeout     = each.value.timeout
  memory_size = each.value.memory_size

  environment {
    variables = local.environment_variables
  }
}

# Log group(s) to store log messages from your Lambda function for 30 days
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  for_each = local.functions
  name     = "/aws/lambda/${local.application_name}${each.key}"

  retention_in_days = 30
}

# Functions IAM Role
resource "aws_iam_role" "lambda_exec" {
  name = local.application_prefix

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

# Attaches a Policy to the above IAM role - that allows Lambda function to write to CloudWatch logs.
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# S3 bucket that stores lambda function archives
data "aws_s3_bucket" "lambda_bucket" {
  bucket = local.lambda_bucket_name
}

# Uploads archive to S3 bucket
# once done - aws s3 ls $(terraform output -raw lambda_bucket_name)
resource "aws_s3_object" "lambda_archive" {
  bucket = data.aws_s3_bucket.lambda_bucket.id

  key    = "function.zip"
  source = local.lambda_archive_file_path

  etag = filemd5(local.lambda_archive_file_path)
}