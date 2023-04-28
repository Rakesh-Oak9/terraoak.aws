resource "aws_api_gateway_method" "sac_api_gateway_method" {
  rest_api_id = aws_api_gateway_rest_api.sac_api_gateway_rest_api.id
  resource_id = aws_api_gateway_resource.sac_api_gateway.id
  http_method = "GET"
  authorization = "NONE" # oak9: authorization should be set to any of aws_iam, custom, cognito_user_pools
}