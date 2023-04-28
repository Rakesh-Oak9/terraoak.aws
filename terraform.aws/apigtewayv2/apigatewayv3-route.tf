resource "aws_apigatewayv2_route" "sac_apigwv2_route" {
  api_id    = aws_apigatewayv2_api.sac_apigwv2_api.id
  route_key = "GET /hello"
  authorization_type = "NONE"
  # oak9: Enable authorization for API routes
  target    = "integrations/${aws_apigatewayv2_integration.sac_apigwv2_integration.id}"
}