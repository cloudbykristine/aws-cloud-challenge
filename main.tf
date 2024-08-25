provider "aws" {
  region = var.region
}

terraform {
    required_version = ">= 0.12"
    backend "s3" {
      bucket = "crc-tf-bucket-25082024-proj01"
      key = "crc-backend/state.tfstate"
      region = "ap-southeast-2"
    }
}
####################################### Lambda Function Creation #######################################

resource "aws_lambda_function" "visitor-counter" {
  filename         = "lambda/lambda_function_payload.zip"
  function_name    = "myVisitorCounter"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "lambda_counter.lambda_handler"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime          = "python3.12"
}

# Create an IAM role for the Lambda function
resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = file("lambda-policy.json")
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda/lambda_counter.py"
  output_path = "lambda/lambda_function_payload.zip" # created by TF.
}

# Attach two policies to the lambda role
resource "aws_iam_role_policy_attachment" "lambda-exec-role" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"

}
resource "aws_iam_role_policy_attachment" "lambda-dynamoDB" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::${var.account}:policy/lambda_dynamoDB_policy"
}

####################################### API Gateway Creation ####################################### 

resource "aws_api_gateway_rest_api" "crc-api" {
  name        = "api-crc"
  description = "api for cloud resume"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "crc-api-resource" {
  parent_id   = aws_api_gateway_rest_api.crc-api.root_resource_id
  path_part   = "{proxy+}"
  rest_api_id = aws_api_gateway_rest_api.crc-api.id
}

# Create API Gateway Methods 

resource "aws_api_gateway_method" "crc-api-any" {
  authorization = "NONE"
  http_method   = "ANY"
  resource_id   = aws_api_gateway_resource.crc-api-resource.id
  rest_api_id   = aws_api_gateway_rest_api.crc-api.id
}

resource "aws_api_gateway_method" "crc-api-options" {
  authorization = "NONE"
  http_method   = "OPTIONS"
  resource_id   = aws_api_gateway_resource.crc-api-resource.id
  rest_api_id   = aws_api_gateway_rest_api.crc-api.id
}

resource "aws_api_gateway_integration" "proxy-lambda-any" {
  http_method             = aws_api_gateway_method.crc-api-any.http_method
  resource_id             = aws_api_gateway_resource.crc-api-resource.id
  rest_api_id             = aws_api_gateway_rest_api.crc-api.id
  type                    = "AWS_PROXY"
  integration_http_method = "ANY"
  uri                     = aws_lambda_function.visitor-counter.invoke_arn
}

resource "aws_api_gateway_integration" "proxy-lambda-options" {
  http_method             = aws_api_gateway_method.crc-api-options.http_method
  resource_id             = aws_api_gateway_resource.crc-api-resource.id
  rest_api_id             = aws_api_gateway_rest_api.crc-api.id
  type                    = "MOCK" # for CORS Configuration
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_response" {
  rest_api_id = aws_api_gateway_rest_api.crc-api.id
  resource_id = aws_api_gateway_resource.crc-api-resource.id
  http_method = aws_api_gateway_method.crc-api-options.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.crc-api.id
  resource_id = aws_api_gateway_resource.crc-api-resource.id
  http_method = aws_api_gateway_method.crc-api-options.http_method
  status_code = aws_api_gateway_method_response.options_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

resource "aws_api_gateway_deployment" "crc-api-deploy" {
  rest_api_id = aws_api_gateway_rest_api.crc-api.id
  stage_name  = var.stagename

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.crc-api-resource.id,
      aws_api_gateway_method.crc-api-any.id,
      aws_api_gateway_integration.proxy-lambda-any.id,
      aws_api_gateway_integration.proxy-lambda-options.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true # to minimize downtime
  }

  depends_on = [
    aws_api_gateway_integration.proxy-lambda-any,
    aws_api_gateway_integration.proxy-lambda-options,
  ]
}

resource "aws_lambda_permission" "apigw_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor-counter.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.crc-api.execution_arn}/*/*/*"
}

####################################### Dynamo DB Table Creation ####################################### 

resource "aws_dynamodb_table" "crc-table" {
  name           = "crc-table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name        = var.env_prefix
    Environment = var.stagename
  }
}


