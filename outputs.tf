output "lambda_functions" {
  value = aws_lambda_function.lambda_function
}

output "base_url" {
  value = aws_apigatewayv2_stage.api_gateway_stage.invoke_url
}