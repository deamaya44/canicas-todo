output "codecommit_repositories" {
  description = "CodeCommit repository URLs"
  value = {
    for k, v in module.codecommit : k => {
      clone_url_http = v.clone_url_http
      clone_url_ssh  = v.clone_url_ssh
    }
  }
}

output "api_endpoint" {
  description = "API Gateway endpoint"
  value       = module.apigateway["main"].api_endpoint
}

output "api_endpoints" {
  description = "API endpoints"
  value = {
    list_tasks  = "${module.apigateway["main"].api_endpoint}/tasks"
    create_task = "${module.apigateway["main"].api_endpoint}/tasks"
    get_task    = "${module.apigateway["main"].api_endpoint}/tasks/{id}"
    update_task = "${module.apigateway["main"].api_endpoint}/tasks/{id}"
    delete_task = "${module.apigateway["main"].api_endpoint}/tasks/{id}"
  }
}

output "dynamodb_table" {
  description = "DynamoDB table name"
  value       = module.dynamodb["tasks"].table_name
}

output "amplify_app_url" {
  description = "Amplify app URL"
  value       = module.amplify["frontend"].default_domain
}

output "lambda_functions" {
  description = "Lambda function names"
  value = {
    for k, v in module.lambda : k => v.function_name
  }
}

output "pipeline_name" {
  description = "CodePipeline name"
  value       = module.codepipeline["main"].pipeline_name
}
