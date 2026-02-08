module "codecommit" {
  source   = "./modules/codecommit"
  for_each = local.repositories

  repository_name = each.value.name
  description     = each.value.description
  common_tags     = each.value.tags
}

module "s3_buckets" {
  source   = "./modules/s3"
  for_each = local.s3_buckets

  bucket_name = each.value.name
  common_tags = each.value.tags
}

module "codebuild" {
  source   = "./modules/codebuild"
  for_each = local.build_projects

  project_name                = each.value.name
  description                 = each.value.description
  source_type                 = each.value.source_type
  source_location             = each.value.source_location
  buildspec                   = each.value.buildspec
  compute_type                = each.value.compute_type
  image                       = each.value.image
  type                        = each.value.type
  privileged_mode             = each.value.privileged
  artifacts_bucket            = module.s3_buckets["artifacts"].bucket_name
  artifacts_bucket_arn        = each.value.artifacts_bucket_arn
  frontend_bucket_arn         = each.key == "frontend" ? module.s3_buckets["frontend"].arn : ""
  lambda_function_arn         = each.key == "backend" ? module.api_backend.lambda_function_arn : ""
  cloudfront_distribution_arn = each.key == "frontend" ? module.cloudfront.distribution_arn : ""
  common_tags                 = each.value.tags
  
  environment_variables = each.key == "backend" ? {
    ARTIFACTS_BUCKET      = module.s3_buckets["artifacts"].bucket_name
    LAMBDA_FUNCTION_NAME  = module.api_backend.lambda_function_name
    AWS_REGION            = data.aws_region.current.id
  } : {
    FRONTEND_BUCKET       = module.s3_buckets["frontend"].bucket_name
    CLOUDFRONT_DIST_ID    = module.cloudfront.distribution_id
    AWS_REGION            = data.aws_region.current.id
    API_DOMAIN            = "${local.config.api_domain}.${data.aws_ssm_parameter.cloudflare_domain.value}"
    VITE_FIREBASE_API_KEY = data.aws_ssm_parameter.firebase_api_key.value
    VITE_FIREBASE_AUTH_DOMAIN = data.aws_ssm_parameter.firebase_auth_domain.value
    VITE_FIREBASE_PROJECT_ID = data.aws_ssm_parameter.firebase_project_id.value
    VITE_FIREBASE_STORAGE_BUCKET = data.aws_ssm_parameter.firebase_storage_bucket.value
    VITE_FIREBASE_MESSAGING_SENDER_ID = data.aws_ssm_parameter.firebase_messaging_sender_id.value
    VITE_FIREBASE_APP_ID = data.aws_ssm_parameter.firebase_app_id.value
  }

  depends_on = [module.codecommit, module.s3_buckets, module.cloudfront]
}

module "codepipeline" {
  source = "./modules/codepipeline"

  pipeline_name       = "${local.project_name}-${local.environment}-pipeline"
  artifacts_bucket    = module.s3_buckets["artifacts"].bucket_name
  backend_repo_name   = module.codecommit["backend"].repository_name
  frontend_repo_name  = module.codecommit["frontend"].repository_name
  backend_build_name  = module.codebuild["backend"].project_name
  frontend_build_name = module.codebuild["frontend"].project_name
  common_tags         = local.common_tags

  depends_on = [module.codebuild]
}

module "sns_notifications" {
  source = "./modules/sns"
  count  = length(var.notification_emails) > 0 ? 1 : 0

  topic_name = "${local.project_name}-pipeline-notifications"
  emails     = var.notification_emails
  common_tags = local.common_tags
}

module "api_backend" {
  source = "./modules/api-backend"

  project_name         = local.project_name
  lambda_zip_path      = "${path.module}/lambda-placeholder.zip"
  environment          = local.environment
  custom_domain_name   = "${local.config.api_domain}.${data.aws_ssm_parameter.cloudflare_domain.value}"
  acm_certificate_arn  = aws_acm_certificate_validation.backend.certificate_arn
  firebase_project_id  = data.aws_ssm_parameter.firebase_project_id.value
  allowed_origins      = [
    "https://${local.config.frontend_domain}.${data.aws_ssm_parameter.cloudflare_domain.value}"
  ]
  common_tags = local.common_tags

  depends_on = [aws_acm_certificate_validation.backend]
}

module "cloudfront" {
  source = "./modules/cloudfront"

  origin_domain_name  = module.s3_buckets["frontend"].bucket_regional_domain_name
  origin_id           = "S3-${local.project_name}-${local.environment}-frontend"
  default_root_object = "index.html"
  comment             = "${local.project_name} ${local.environment} frontend distribution"
  aliases             = ["${local.config.frontend_domain}.${data.aws_ssm_parameter.cloudflare_domain.value}"]
  acm_certificate_arn = aws_acm_certificate_validation.frontend.certificate_arn
  common_tags         = local.common_tags

  depends_on = [module.s3_buckets, aws_acm_certificate_validation.frontend]
}

# Update frontend bucket policy to allow CloudFront access
resource "aws_s3_bucket_policy" "frontend_cloudfront" {
  bucket = module.s3_buckets["frontend"].bucket_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowCloudFrontServicePrincipal"
      Effect    = "Allow"
      Principal = {
        Service = "cloudfront.amazonaws.com"
      }
      Action   = "s3:GetObject"
      Resource = "${module.s3_buckets["frontend"].arn}/*"
      Condition = {
        StringEquals = {
          "AWS:SourceArn" = module.cloudfront.distribution_arn
        }
      }
    }]
  })

  depends_on = [module.cloudfront]
}
