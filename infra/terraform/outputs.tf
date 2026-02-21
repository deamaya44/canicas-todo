output "codecommit_repositories" {
  description = "CodeCommit repository URLs"
  value = {
    for k, v in module.codecommit : k => {
      clone_url_http = v.clone_url_http
      clone_url_ssh  = v.clone_url_ssh
      arn            = v.arn
    }
  }
}

output "codebuild_projects" {
  description = "CodeBuild project names"
  value = {
    for k, v in module.codebuild : k => {
      name = v.project_name
      arn  = v.arn
    }
  }
}

output "s3_buckets" {
  description = "S3 bucket names"
  value = {
    for k, v in module.s3_buckets : k => {
      name = v.bucket_name
      arn  = v.arn
    }
  }
}

output "pipeline_name" {
  description = "CodePipeline name"
  value       = module.codepipeline.pipeline_name
}

output "pipeline_arn" {
  description = "CodePipeline ARN"
  value       = module.codepipeline.pipeline_arn
}

output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = module.api_backend.api_endpoint
}

output "api_endpoints" {
  description = "API endpoints"
  value = {
    list_tasks   = "${module.api_backend.api_endpoint}/tasks"
    create_task  = "${module.api_backend.api_endpoint}/tasks"
    get_task     = "${module.api_backend.api_endpoint}/tasks/{id}"
    update_task  = "${module.api_backend.api_endpoint}/tasks/{id}"
    delete_task  = "${module.api_backend.api_endpoint}/tasks/{id}"
  }
}

output "dynamodb_table" {
  description = "DynamoDB table name"
  value       = module.api_backend.dynamodb_table_name
}

output "cloudfront_distribution" {
  description = "CloudFront distribution details"
  value = {
    id          = module.cloudfront.distribution_id
    domain_name = module.cloudfront.domain_name
    url         = "https://${module.cloudfront.domain_name}"
  }
}

output "firebase_config" {
  description = "Firebase configuration"
  sensitive   = true
  value = {
    project_id = data.aws_ssm_parameter.firebase_project_id.value
    note       = "Configure Firebase in your app with this project ID"
  }
}

