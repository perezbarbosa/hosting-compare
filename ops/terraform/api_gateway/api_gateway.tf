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
resource "aws_api_gateway_method" "quehosting_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.quehosting_rest_api.id
  resource_id   = aws_api_gateway_resource.quehosting_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "quehosting_post_200_response" {
   rest_api_id   = aws_api_gateway_rest_api.quehosting_rest_api.id
   resource_id   = aws_api_gateway_resource.quehosting_resource.id
   http_method   = aws_api_gateway_method.quehosting_post_method.http_method
   status_code   = "200"
   response_parameters = {
      "method.response.header.Access-Control-Allow-Origin" = true
   }
   depends_on = [ aws_api_gateway_method.quehosting_post_method ]
}

# Integration specifies where incoming requests are routed
resource "aws_api_gateway_integration" "search_lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.quehosting_rest_api.id
  resource_id = aws_api_gateway_method.quehosting_post_method.resource_id
  http_method = aws_api_gateway_method.quehosting_post_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = data.aws_lambda_function.search.invoke_arn
  depends_on              = [ aws_api_gateway_method.quehosting_post_method ]
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

#
# Now enable CORS
#   Source: https://medium.com/@MrPonath/terraform-and-aws-api-gateway-a137ee48a8ac
#

resource "aws_api_gateway_method" "quehosting_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.quehosting_rest_api.id
  resource_id   = aws_api_gateway_resource.quehosting_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "quehosting_options_200_response" {
   rest_api_id   = aws_api_gateway_rest_api.quehosting_rest_api.id
   resource_id   = aws_api_gateway_resource.quehosting_resource.id
   http_method   = aws_api_gateway_method.quehosting_options_method.http_method
   status_code   = "200"
   response_models = {
      "application/json" = "Empty"
   }
   response_parameters = {
      "method.response.header.Access-Control-Allow-Headers" = true,
      "method.response.header.Access-Control-Allow-Methods" = true,
      "method.response.header.Access-Control-Allow-Origin" = true
   }
   depends_on = [ aws_api_gateway_method.quehosting_options_method ]
}

# Integration specifies where incoming requests are routed
resource "aws_api_gateway_integration" "search_lambda_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.quehosting_rest_api.id
  resource_id = aws_api_gateway_method.quehosting_options_method.resource_id
  http_method = aws_api_gateway_method.quehosting_options_method.http_method
  type        = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"
  request_templates = {
    "application/json" = "{ 'statusCode': 200 }"
  }
  depends_on  = [ aws_api_gateway_method.quehosting_options_method ]
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
   rest_api_id   = aws_api_gateway_rest_api.quehosting_rest_api.id
   resource_id   = aws_api_gateway_method.quehosting_options_method.resource_id
   http_method   = aws_api_gateway_method.quehosting_options_method.http_method
   status_code   = aws_api_gateway_method_response.quehosting_options_200_response.status_code
   response_parameters = {
      "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
      "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'",
      "method.response.header.Access-Control-Allow-Origin" = "'https://quehosting.es'"
   }
   depends_on = [ aws_api_gateway_method_response.quehosting_options_200_response ]
}