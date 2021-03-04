data "aws_lambda_function" "search" {
  function_name = "search"
}

data "aws_acm_certificate" "quehosting_es" {
  domain   = "quehosting.es"
  statuses = ["ISSUED"]
}
