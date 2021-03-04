# Custom Domain name for our API
resource "aws_api_gateway_domain_name" "quehosting_api_gateway_domain" {
  domain_name = "api.quehosting.es"
  # As endpoint_config is REGIONAL, the certificate should be in our region
  regional_certificate_arn = data.aws_acm_certificate.quehosting_es.arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Connects the custom domain with our deployed API
resource "aws_api_gateway_base_path_mapping" "quehosting_mapping" {
  api_id      = aws_api_gateway_rest_api.quehosting_rest_api.id
  domain_name = aws_api_gateway_domain_name.quehosting_api_gateway_domain.domain_name
}

# DNS Record creation
resource "aws_route53_record" "api_quehosting_es" {
  name    = aws_api_gateway_domain_name.quehosting_api_gateway_domain.domain_name
  type    = "A"
  zone_id = module.vars.hosted_zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.quehosting_api_gateway_domain.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.quehosting_api_gateway_domain.regional_zone_id
  }
}
