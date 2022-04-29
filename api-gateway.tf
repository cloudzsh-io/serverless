# Gateway Definition
resource "aws_apigatewayv2_api" "api_gateway" {
  name          = "${local.application_prefix}_api_gateway"
  protocol_type = "HTTP"
}

# [API_GW : STAGE_DEFINITION]
resource "aws_apigatewayv2_stage" "api_gateway_stage" {
  api_id = aws_apigatewayv2_api.api_gateway.id

  name        = local.api_gateway_stage_name
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

# [API_GW -> AUTHORIZER]
resource "aws_apigatewayv2_authorizer" "api_gateway_authorizer" {
  api_id           = aws_apigatewayv2_api.api_gateway.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "${local.application_prefix}_api_gateway_authorizer"

  jwt_configuration {
    audience = [local.jwt_audience]
    issuer   = local.jwt_issuer
  }
}

# [API_GW -> CLOUDWATCH_LOG_GROUP]
resource "aws_cloudwatch_log_group" "api_gw" {
  name              = "/aws/api_gw/${aws_apigatewayv2_api.api_gateway.name}"
  retention_in_days = 30
}

# -----------------------------------------------------------
#         FUNCTION INTEGRATION(s) - Use Iterations          
# -----------------------------------------------------------

# API Gateway Integration Definition(s) [API_GW -> FUNCTION(s)]
resource "aws_apigatewayv2_integration" "api_gateway_integration" {
  for_each = local.apis
  api_id   = aws_apigatewayv2_api.api_gateway.id

  integration_uri    = aws_lambda_function.lambda_function[each.value.function].invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

# API Route Definition(s) [API_GW -> ROUTE -> INTEGRATION(s)]
resource "aws_apigatewayv2_route" "api_route" {
  api_id = aws_apigatewayv2_api.api_gateway.id

  for_each = local.apis

  route_key = "${each.value.method} ${each.value.route}"
  target    = "integrations/${aws_apigatewayv2_integration.api_gateway_integration[each.key].id}"

  authorizer_id      = aws_apigatewayv2_authorizer.api_gateway_authorizer.id
  authorization_type = each.value.secure ? "JWT" : "NONE"
}

# Permission for API Gateway to Execute Lambda Function(s)
resource "aws_lambda_permission" "api_gw" {
  for_each = local.apis

  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function[each.value.function].function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.api_gateway.execution_arn}/*/*"
}
