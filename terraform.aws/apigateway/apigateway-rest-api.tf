resource "aws_api_gateway_rest_api" "sac_api_gateway_rest_api" {
  # oak9: Define resource based policies
  name = "sac-testing-apigw-rest-api"   

  endpoint_configuration {
    types = ["EDGE"]
  }
}
