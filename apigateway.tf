resource "aws_api_gateway_rest_api" "fxlink-api" {
  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = var.aws_api_gateway_rest_api_title
      version = "1.0"
    }
    paths = {
      "/path1" = {
        get = {
          x-amazon-apigateway-integration = {
            httpMethod           = "GET"
            payloadFormatVersion = "1.0"
            type                 = "HTTP_PROXY"
            uri                  = "https://ip-ranges.amazonaws.com/ip-ranges.json"
          }
        }
      }
    }
  })

  name = "fxlinkAPI-${terraform.workspace}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "fxlink-api-deploy" {
  rest_api_id = aws_api_gateway_rest_api.fxlink-api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.fxlink-api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "fxlink_Stage" {
  deployment_id = aws_api_gateway_deployment.fxlink-api-deploy.id
  rest_api_id   = aws_api_gateway_rest_api.fxlink-api.id
  stage_name    = "v1"
}