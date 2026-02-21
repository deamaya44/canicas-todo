# DynamoDB Table
resource "aws_dynamodb_table" "tasks" {
  name           = "${var.project_name}-${var.environment}-tasks"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  deletion_protection_enabled = false

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "userId"
    type = "S"
  }

  global_secondary_index {
    name            = "UserIdIndex"
    hash_key        = "userId"
    projection_type = "ALL"
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-tasks"
  })
}

# Lambda IAM Role
resource "aws_iam_role" "lambda" {
  name = "${var.project_name}-${var.environment}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = var.common_tags
}

# Lambda Policy
resource "aws_iam_role_policy" "lambda" {
  name = "${var.project_name}-lambda-policy"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Resource = [
          aws_dynamodb_table.tasks.arn,
          "${aws_dynamodb_table.tasks.arn}/index/*"
        ]
      }
    ]
  })
}

# Package backend with dependencies
resource "null_resource" "backend_package" {
  triggers = {
    code_hash    = filemd5("${path.root}/../../backend/index.js")
    package_hash = filemd5("${path.root}/../../backend/package.json")
  }

  provisioner "local-exec" {
    command     = "./package.sh"
    working_dir = "${path.root}/../../backend"
  }
}

data "archive_file" "backend" {
  type        = "zip"
  source_dir  = "${path.root}/../../backend"
  output_path = "${path.root}/../../backend.zip"
  excludes    = [".git", ".gitignore", "package.sh"]

  depends_on = [null_resource.backend_package]
}

# Lambda Function
resource "aws_lambda_function" "tasks" {
  filename         = data.archive_file.backend.output_path
  function_name    = "${var.project_name}-${var.environment}-tasks"
  role            = aws_iam_role.lambda.arn
  handler         = "index.handler"
  source_code_hash = data.archive_file.backend.output_base64sha256
  runtime         = "nodejs18.x"
  timeout         = 30
  memory_size     = 256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.tasks.name
    }
  }

  tags = var.common_tags
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${aws_lambda_function.tasks.function_name}"
  retention_in_days = 7

  tags = var.common_tags
}

# API Gateway HTTP API
resource "aws_apigatewayv2_api" "this" {
  name          = "${var.project_name}-${var.environment}-api"
  protocol_type = "HTTP"
  
  # Note: disable_execute_api_endpoint also affects custom domains in some cases
  # Keeping it enabled but relying on origin validation in authorizer
  # disable_execute_api_endpoint = true

  cors_configuration {
    allow_origins = var.allowed_origins
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = ["content-type", "authorization"]
    max_age       = 300
  }

  tags = var.common_tags
}

# Firebase Lambda Authorizer
# Package authorizer with dependencies
resource "null_resource" "authorizer_package" {
  triggers = {
    code_hash    = filemd5("${path.module}/../../lambda-authorizer/index.js")
    package_hash = filemd5("${path.module}/../../lambda-authorizer/package.json")
  }

  provisioner "local-exec" {
    command     = "./package.sh"
    working_dir = "${path.module}/../../lambda-authorizer"
  }
}

data "archive_file" "authorizer" {
  type        = "zip"
  source_dir  = "${path.module}/../../lambda-authorizer"
  output_path = "${path.module}/../../lambda-authorizer.zip"
  excludes    = [".git", ".gitignore", "package.sh"]

  depends_on = [null_resource.authorizer_package]
}

resource "aws_lambda_function" "authorizer" {
  filename         = data.archive_file.authorizer.output_path
  function_name    = "${var.project_name}-${var.environment}-firebase-authorizer"
  role            = aws_iam_role.authorizer.arn
  handler         = "index.handler"
  source_code_hash = data.archive_file.authorizer.output_base64sha256
  runtime         = "nodejs18.x"
  timeout         = 10

  environment {
    variables = {
      FIREBASE_PROJECT_ID = var.firebase_project_id
      ALLOWED_ORIGINS     = join(",", var.allowed_origins)
    }
  }

  tags = var.common_tags
}

resource "aws_iam_role" "authorizer" {
  name = "${var.project_name}-${var.environment}-authorizer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "authorizer_logs" {
  role       = aws_iam_role.authorizer.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_permission" "authorizer" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.authorizer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}

resource "aws_apigatewayv2_authorizer" "firebase" {
  api_id                            = aws_apigatewayv2_api.this.id
  authorizer_type                   = "REQUEST"
  authorizer_uri                    = aws_lambda_function.authorizer.invoke_arn
  identity_sources                  = ["$request.header.Authorization"]
  name                              = "${var.project_name}-firebase-authorizer"
  authorizer_payload_format_version = "2.0"
  enable_simple_responses           = false
}

data "aws_region" "current" {}

# API Gateway Stage
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "$default"
  auto_deploy = true

  # Throttling settings for security and cost control
  default_route_settings {
    throttling_burst_limit = 100
    throttling_rate_limit  = 50
  }

  tags = var.common_tags
}

# Lambda Permission for API Gateway
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tasks.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}

# API Gateway Integration
resource "aws_apigatewayv2_integration" "tasks" {
  api_id           = aws_apigatewayv2_api.this.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.tasks.invoke_arn
  payload_format_version = "2.0"
}

# Routes
resource "aws_apigatewayv2_route" "list_tasks" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "GET /tasks"
  target    = "integrations/${aws_apigatewayv2_integration.tasks.id}"
  
  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.firebase.id
}

resource "aws_apigatewayv2_route" "create_task" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "POST /tasks"
  target    = "integrations/${aws_apigatewayv2_integration.tasks.id}"
  
  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.firebase.id
}

resource "aws_apigatewayv2_route" "get_task" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "GET /tasks/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.tasks.id}"
  
  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.firebase.id
}

resource "aws_apigatewayv2_route" "update_task" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "PUT /tasks/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.tasks.id}"
  
  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.firebase.id
}

resource "aws_apigatewayv2_route" "delete_task" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "DELETE /tasks/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.tasks.id}"
  
  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.firebase.id
}

# CORS preflight routes (no authorization required)
resource "aws_apigatewayv2_route" "options_tasks" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "OPTIONS /tasks"
  target    = "integrations/${aws_apigatewayv2_integration.tasks.id}"
  
  authorization_type = "NONE"
}

resource "aws_apigatewayv2_route" "options_tasks_id" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "OPTIONS /tasks/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.tasks.id}"
  
  authorization_type = "NONE"
}

# Custom Domain Name
resource "aws_apigatewayv2_domain_name" "this" {
  count       = var.custom_domain_name != "" ? 1 : 0
  domain_name = var.custom_domain_name

  domain_name_configuration {
    certificate_arn = var.acm_certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }

  tags = var.common_tags
}

# API Mapping
resource "aws_apigatewayv2_api_mapping" "this" {
  count       = var.custom_domain_name != "" ? 1 : 0
  api_id      = aws_apigatewayv2_api.this.id
  domain_name = aws_apigatewayv2_domain_name.this[0].id
  stage       = aws_apigatewayv2_stage.default.id
}
