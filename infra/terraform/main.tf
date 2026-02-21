# Null Resources for packaging
module "local_exec" {
  source   = "git::https://github.com/deamaya44/aws_modules.git//modules/provisioners/local_exec?ref=main"
  for_each = local.null_resources

  triggers    = each.value.triggers
  command     = each.value.command
  working_dir = try(each.value.working_dir, null)
}

# CodeCommit Repositories
module "codecommit" {
  source   = "git::https://github.com/deamaya44/aws_modules.git//modules/codecommit?ref=main"
  for_each = local.repositories

  repository_name = each.value.name
  description     = each.value.description
  common_tags     = merge(each.value.tags, { Name = each.key })
}

# S3 Buckets
module "s3_buckets" {
  source   = "git::https://github.com/deamaya44/aws_modules.git//modules/s3?ref=main"
  for_each = local.s3_buckets

  bucket_name = each.value.name
  common_tags = merge(each.value.tags, { Name = each.key })
}

# DynamoDB Tables
module "dynamodb" {
  source   = "git::https://github.com/deamaya44/aws_modules.git//modules/dynamodb?ref=main"
  for_each = local.dynamodb_tables

  table_name                  = each.value.table_name
  billing_mode                = each.value.billing_mode
  deletion_protection_enabled = each.value.deletion_protection_enabled
  hash_key                    = each.value.hash_key
  attributes                  = each.value.attributes
  global_secondary_indexes    = each.value.global_secondary_indexes
  common_tags                 = merge(local.common_tags, { Name = each.key })
}

# IAM Roles for Lambda Functions
module "iam_role_lambda" {
  source   = "git::https://github.com/deamaya44/aws_modules.git//modules/iam/roles?ref=main"
  for_each = local.lambda_functions

  role_name          = each.value.role_name
  assume_role_policy = file("${path.module}/policies/lambda-assume-role.json")
  common_tags        = merge(local.common_tags, { Name = each.key })
}

# IAM Policies for Lambda Functions
module "iam_policy_lambda" {
  source   = "git::https://github.com/deamaya44/aws_modules.git//modules/iam/policies?ref=main"
  for_each = { for k, v in local.lambda_functions : k => v if try(v.policy_file, null) != null }

  policy_name = each.value.policy_name
  attach_to_roles = [module.iam_role_lambda[each.key].role_name]
  policy_document = templatefile("${path.module}/${each.value.policy_file}", {
    dynamodb_table_arn = "${module.dynamodb["tasks"].table_arn}"
  })
  common_tags = merge(local.common_tags, { Name = each.key })
}

# IAM Policy Attachments for Lambda Functions  
resource "aws_iam_role_policy_attachment" "lambda" {
  for_each = { for k, v in local.lambda_functions : k => v if try(v.policy_arn, null) != null }

  role       = module.iam_role_lambda[each.key].role_name
  policy_arn = each.value.policy_arn
}

# Lambda Functions
module "lambda" {
  source   = "git::https://github.com/deamaya44/aws_modules.git//modules/lambda?ref=main"
  for_each = local.lambda_functions

  function_name = each.value.function_name
  handler       = each.value.handler
  runtime       = each.value.runtime
  filename      = each.value.filename
  role_arn      = module.iam_role_lambda[each.key].role_arn
  timeout       = each.value.timeout
  memory_size   = try(each.value.memory_size, 128)

  environment_variables = {
    for k, v in each.value.environment_variables : k => (
      v == "dynamodb_tasks" ? module.dynamodb["tasks"].table_name :
      v == "firebase_project_id" ? data.aws_ssm_parameter.firebase_project_id.value :
      v == "frontend_domain" ? "https://${local.config.frontend_domain}.${data.aws_ssm_parameter.cloudflare_domain.value}" :
      v
    )
  }

  depends_on = [
    module.local_exec
  ]

  common_tags = merge(local.common_tags, { Name = each.key })
}

# ACM Certificates
module "acm_certificate" {
  source   = "git::https://github.com/deamaya44/aws_modules.git//modules/acm_certificate?ref=main"
  for_each = local.acm_certificates
  providers = {
    aws = aws.us_east_1
  }

  domain_name       = each.value.domain_name
  validation_method = each.value.validation_method
  common_tags       = merge(local.common_tags, { Name = each.key })
}

# Cloudflare DNS Records for Certificate Validation
resource "cloudflare_record" "cert_validation" {
  for_each = local.acm_certificates

  zone_id = data.aws_ssm_parameter.cloudflare_zone_id.value
  name    = trimsuffix(tolist(module.acm_certificate[each.key].domain_validation_options)[0].resource_record_name, ".")
  type    = tolist(module.acm_certificate[each.key].domain_validation_options)[0].resource_record_type
  content = trimsuffix(tolist(module.acm_certificate[each.key].domain_validation_options)[0].resource_record_value, ".")
  ttl     = 60
  proxied = false
}

# ACM Certificate Validation
resource "aws_acm_certificate_validation" "this" {
  for_each = local.acm_certificates

  provider                = aws.us_east_1
  certificate_arn         = module.acm_certificate[each.key].certificate_arn
  validation_record_fqdns = [cloudflare_record.cert_validation[each.key].hostname]
}

# API Gateway
module "apigateway" {
  source   = "git::https://github.com/deamaya44/aws_modules.git//modules/apigateway?ref=main"
  for_each = local.apigateways

  api_name               = each.value.api_name
  protocol_type          = each.value.protocol_type
  stage_name             = each.value.stage_name
  auto_deploy            = each.value.auto_deploy
  throttling_burst_limit = each.value.throttling_burst_limit
  throttling_rate_limit  = each.value.throttling_rate_limit

  cors_configuration = merge(each.value.cors_configuration, {
    allow_origins = ["https://${local.config.frontend_domain}.${data.aws_ssm_parameter.cloudflare_domain.value}"]
  })

  integrations = {
    for k, v in each.value.integrations : k => merge(v, {
      integration_uri = module.lambda[v.lambda_key].function_invoke_arn
    })
  }

  authorizers = {
    for k, v in each.value.authorizers : k => merge(v, {
      authorizer_uri = module.lambda[v.lambda_key].function_invoke_arn
    })
  }

  routes = each.value.routes

  custom_domain_name = "${local.config.api_domain}.${data.aws_ssm_parameter.cloudflare_domain.value}"
  certificate_arn    = aws_acm_certificate_validation.this["backend"].certificate_arn
  endpoint_type      = each.value.endpoint_type
  security_policy    = each.value.security_policy

  common_tags = merge(local.common_tags, { Name = each.key })

  depends_on = [aws_acm_certificate_validation.this]
}

# Lambda Permissions
resource "aws_lambda_permission" "api_gateway" {
  for_each = local.lambda_functions

  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda[each.key].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.apigateway["main"].execution_arn}/*/*"
}

# Cloudflare DNS Records
module "cloudflare_record" {
  source   = "git::https://github.com/deamaya44/aws_modules.git//modules/cloudflare_record?ref=main"
  for_each = local.cloudflare_records

  zone_id = data.aws_ssm_parameter.cloudflare_zone_id.value
  name    = each.value.name
  type    = each.value.type
  proxied = each.value.proxied
  ttl     = each.value.ttl
  comment = each.value.comment
  
  content = (
    each.value.content_source == "amplify" ? module.amplify[each.value.content_key].default_domain :
    each.value.content_source == "apigateway" ? module.apigateway[each.value.content_key].custom_domain_target :
    ""
  )

  depends_on = [module.amplify, module.apigateway]
}

# CodeBuild Projects
module "codebuild" {
  source   = "git::https://github.com/deamaya44/aws_modules.git//modules/codebuild?ref=main"
  for_each = local.build_projects

  project_name         = each.value.name
  description          = each.value.description
  source_type          = each.value.source_type
  source_location      = module.codecommit[each.key].clone_url_http
  buildspec            = each.value.buildspec
  compute_type         = each.value.compute_type
  image                = each.value.image
  type                 = each.value.type
  privileged_mode      = each.value.privileged
  artifacts_bucket     = module.s3_buckets["artifacts"].bucket_name
  artifacts_bucket_arn = module.s3_buckets["artifacts"].arn
  lambda_function_arn  = each.key == "backend" ? module.lambda["backend"].function_arn : ""
  amplify_app_arn      = each.key == "frontend" ? module.amplify["frontend"].app_arn : ""
  common_tags          = merge(each.value.tags, { Name = each.key })

  environment_variables = each.key == "backend" ? {
    ARTIFACTS_BUCKET     = module.s3_buckets["artifacts"].bucket_name
    LAMBDA_FUNCTION_NAME = module.lambda["backend"].function_name
    AWS_REGION           = data.aws_region.current.id
  } : {
    AMPLIFY_APP_ID                    = module.amplify["frontend"].app_id
    BRANCH_NAME                       = "main"
    AWS_REGION                        = data.aws_region.current.id
    VITE_API_URL                      = "https://${local.config.api_domain}.${data.aws_ssm_parameter.cloudflare_domain.value}"
    VITE_FIREBASE_API_KEY             = data.aws_ssm_parameter.firebase_api_key.value
    VITE_FIREBASE_AUTH_DOMAIN         = data.aws_ssm_parameter.firebase_auth_domain.value
    VITE_FIREBASE_PROJECT_ID          = data.aws_ssm_parameter.firebase_project_id.value
    VITE_FIREBASE_STORAGE_BUCKET      = data.aws_ssm_parameter.firebase_storage_bucket.value
    VITE_FIREBASE_MESSAGING_SENDER_ID = data.aws_ssm_parameter.firebase_messaging_sender_id.value
    VITE_FIREBASE_APP_ID              = data.aws_ssm_parameter.firebase_app_id.value
  }

  depends_on = [module.codecommit, module.s3_buckets, module.amplify]
}

# CodePipeline
module "codepipeline" {
  source   = "git::https://github.com/deamaya44/aws_modules.git//modules/codepipeline?ref=main"
  for_each = local.codepipelines

  pipeline_name       = each.value.pipeline_name
  artifacts_bucket    = module.s3_buckets["artifacts"].bucket_name
  backend_repo_name   = module.codecommit["backend"].repository_name
  frontend_repo_name  = module.codecommit["frontend"].repository_name
  backend_build_name  = module.codebuild["backend"].project_name
  frontend_build_name = module.codebuild["frontend"].project_name
  common_tags         = merge(local.common_tags, { Name = each.key })

  depends_on = [module.codebuild]
}

# Amplify Apps
module "amplify" {
  source   = "git::https://github.com/deamaya44/aws_modules.git//modules/amplify?ref=main"
  for_each = local.amplify_apps

  app_name         = each.value.app_name
  branch_name      = each.value.branch_name
  custom_domain    = data.aws_ssm_parameter.cloudflare_domain.value
  subdomain_prefix = each.value.subdomain_prefix

  environment_variables = {
    VITE_API_URL = "https://${local.config.api_domain}.${data.aws_ssm_parameter.cloudflare_domain.value}"
  }

  common_tags = merge(local.common_tags, { Name = each.key })

  depends_on = [module.apigateway]
}
