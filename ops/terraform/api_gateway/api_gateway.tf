# The REST API "container"
# Disabling default endpoint as we are using our own domain
resource "aws_api_gateway_rest_api" "quehosting_rest_api" {
  name                         = "QueHostingRestApi"
  description                  = "QueHosting.es REST API"
  disable_execute_api_endpoint = true
}

# Resource and method to handle all incoming requests
resource "aws_api_gateway_resource" "quehosting_resource" {
  rest_api_id = aws_api_gateway_rest_api.quehosting_rest_api.id
  parent_id   = aws_api_gateway_rest_api.quehosting_rest_api.root_resource_id
  path_part   = "search"
}

# ... And method
resource "aws_api_gateway_method" "quehosting_method" {
  rest_api_id   = aws_api_gateway_rest_api.quehosting_rest_api.id
  resource_id   = aws_api_gateway_resource.quehosting_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# Integration specifies where incoming requests are routed
resource "aws_api_gateway_integration" "search_lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.quehosting_rest_api.id
  resource_id = aws_api_gateway_method.quehosting_method.resource_id
  http_method = aws_api_gateway_method.quehosting_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = data.aws_lambda_function.search.invoke_arn
}

# According to https://learn.hashicorp.com/tutorials/terraform/lambda-api-gateway
# the root path cannot be an empty resource so defining method and integration
resource "aws_api_gateway_method" "quehosting_method_root" {
  rest_api_id   = aws_api_gateway_rest_api.quehosting_rest_api.id
  resource_id   = aws_api_gateway_rest_api.quehosting_rest_api.root_resource_id
  http_method   = "POST"
  authorization = "NONE"
}

# ... And integration
resource "aws_api_gateway_integration" "search_lambda_integration_root" {
  rest_api_id = aws_api_gateway_rest_api.quehosting_rest_api.id
  resource_id = aws_api_gateway_method.quehosting_method_root.resource_id
  http_method = aws_api_gateway_method.quehosting_method_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = data.aws_lambda_function.search.invoke_arn
}

# Exposes the API
resource "aws_api_gateway_deployment" "quehosting_deployment" {
  depends_on = [
    aws_api_gateway_integration.search_lambda_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.quehosting_rest_api.id
  stage_name  = "dev"
}

# Lambda permissions
resource "aws_lambda_permission" "quehosting_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.search.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.quehosting_rest_api.execution_arn}/*/*"
}

# To facilitate to get the API Gateway url to invoke
output "base_url" {
  value = aws_api_gateway_deployment.quehosting_deployment.invoke_url
}