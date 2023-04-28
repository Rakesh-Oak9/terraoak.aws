  resource "aws_apigatewayv2_domain_name" "sac_apigwv2_domain" {
  domain_name = "acorncorp.com"

  domain_name_configuration {
    certificate_arn = ""
    endpoint_type   = "REGIONAL"
    security_policy = "tls_1_2"
  }
}

resource "aws_route53_zone" "sac_route_zone" {
  name = "acorncorp.com"
}

resource "aws_route53_record" "sac_route_record" {
  zone_id = aws_route53_zone.sac_route_zone.id
  name    = "acorncorp.com"
  type    = "A"
  ttl     = 300
  records = ["192.0.2.1"]
}