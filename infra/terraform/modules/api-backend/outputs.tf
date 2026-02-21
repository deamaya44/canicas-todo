output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = aws_apigatewayv2_api.this.api_endpoint
}

output "api_id" {
  description = "API Gateway ID"
  value       = aws_apigatewayv2_api.this.id
}

output "custom_domain_target" {
  description = "Custom domain target for DNS"
  value       = var.custom_domain_name != "" ? aws_apigatewayv2_domain_name.this[0].domain_name_configuration[0].target_domain_name : ""
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.tasks.function_name
}

output "lambda_function_arn" {
  description = "Lambda function ARN"
  value       = aws_lambda_function.tasks.arn
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.tasks.name
}

output "dynamodb_table_arn" {
  description = "DynamoDB table ARN"
  value       = aws_dynamodb_table.tasks.arn
}
