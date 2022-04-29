resource "aws_apigatewayv2_domain_name" "api_gw_v2_domain_name" {
  domain_name     = local.api_gateway_domain

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.cert.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_route53_record" "route53_record" {
  name    = aws_apigatewayv2_domain_name.api_gw_v2_domain_name.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.hosted_zone.id

  alias {
    name                   = aws_apigatewayv2_domain_name.api_gw_v2_domain_name.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.api_gw_v2_domain_name.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_apigatewayv2_api_mapping" "domain_mapping" {
  api_id      = aws_apigatewayv2_api.api_gateway.id
  domain_name = aws_apigatewayv2_domain_name.api_gw_v2_domain_name.id
  stage       = aws_apigatewayv2_stage.api_gateway_stage.id
}