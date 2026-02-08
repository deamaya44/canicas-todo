locals {
  owner        = var.owner
  project_name = var.project_name

  common_tags = {
    Project     = local.project_name
    Terraform   = "true"
    Owner       = local.owner
    ManagedBy   = "Terraform"
    Environment = local.environment
    Workspace   = terraform.workspace
  }

  # CodeCommit repositories
  repositories = {
    backend = {
      name        = "${local.project_name}-${local.environment}-backend"
      description = "${local.environment} Backend API repository"
      tags        = merge(local.common_tags, { Component = "backend" })
    }
    frontend = {
      name        = "${local.project_name}-${local.environment}-frontend"
      description = "${local.environment} Frontend application repository"
      tags        = merge(local.common_tags, { Component = "frontend" })
    }
  }

  # CodeBuild projects
  build_projects = {
    backend = {
      name                = "${local.project_name}-${local.environment}-backend-build"
      description         = "Build ${local.environment} backend API"
      source_type         = "CODECOMMIT"
      source_location     = module.codecommit["backend"].clone_url_http
      buildspec           = "buildspec.yml"
      compute_type        = "BUILD_GENERAL1_SMALL"
      image               = "aws/codebuild/standard:7.0"
      type                = "LINUX_CONTAINER"
      privileged          = true
      artifacts_bucket_arn = module.s3_buckets["artifacts"].arn
      tags                = merge(local.common_tags, { Component = "backend" })
    }
    frontend = {
      name                = "${local.project_name}-${local.environment}-frontend-build"
      description         = "Build ${local.environment} frontend application"
      source_type         = "CODECOMMIT"
      source_location     = module.codecommit["frontend"].clone_url_http
      buildspec           = "buildspec.yml"
      compute_type        = "BUILD_GENERAL1_SMALL"
      image               = "aws/codebuild/standard:7.0"
      type                = "LINUX_CONTAINER"
      privileged          = false
      artifacts_bucket_arn = module.s3_buckets["artifacts"].arn
      tags                = merge(local.common_tags, { Component = "frontend" })
    }
  }

  # S3 buckets
  s3_buckets = {
    artifacts = {
      name = "${local.project_name}-${local.environment}-artifacts-${data.aws_caller_identity.current.account_id}"
      tags = merge(local.common_tags, { Purpose = "artifacts" })
    }
    frontend = {
      name = "${local.project_name}-${local.environment}-frontend-${data.aws_caller_identity.current.account_id}"
      tags = merge(local.common_tags, { Purpose = "frontend-hosting" })
    }
  }
}
