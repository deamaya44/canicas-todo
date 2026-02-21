locals {
  aws_region   = "us-east-1"
  owner        = "devops"
  project_name = "tasks-3d"
  environment  = terraform.workspace == "default" ? "prod" : terraform.workspace

  common_tags = {
    Project     = local.project_name
    Terraform   = "true"
    Owner       = local.owner
    ManagedBy   = "Terraform"
    Environment = local.environment
    Workspace   = terraform.workspace
  }

  # Environment-specific configuration
  env_config = {
    prod = {
      frontend_domain = "app"
      api_domain      = "api"
    }
    dev = {
      frontend_domain = "dev"
      api_domain      = "api-dev"
    }
  }
  
  config = local.env_config[local.environment]

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

  # S3 buckets
  s3_buckets = {
    artifacts = {
      name = "${local.project_name}-${local.environment}-artifacts-${data.aws_caller_identity.current.account_id}"
      tags = merge(local.common_tags, { Purpose = "artifacts" })
    }
  }

  # CodeBuild projects
  build_projects = {
    backend = {
      name             = "${local.project_name}-${local.environment}-backend-build"
      description      = "Build ${local.environment} backend API"
      source_type      = "CODECOMMIT"
      buildspec        = "buildspec.yml"
      compute_type     = "BUILD_GENERAL1_SMALL"
      image            = "aws/codebuild/standard:7.0"
      type             = "LINUX_CONTAINER"
      privileged       = true
      tags             = merge(local.common_tags, { Component = "backend" })
    }
    frontend = {
      name             = "${local.project_name}-${local.environment}-frontend-build"
      description      = "Build ${local.environment} frontend application"
      source_type      = "CODECOMMIT"
      buildspec        = "buildspec.yml"
      compute_type     = "BUILD_GENERAL1_SMALL"
      image            = "aws/codebuild/standard:7.0"
      type             = "LINUX_CONTAINER"
      privileged       = false
      tags             = merge(local.common_tags, { Component = "frontend" })
    }
  }

  # DynamoDB tables configuration
  dynamodb_tables = {
    tasks = {
      table_name                  = "${local.project_name}-${local.environment}-tasks"
      billing_mode                = "PAY_PER_REQUEST"
      deletion_protection_enabled = false
      hash_key                    = "id"
      attributes = [
        { name = "id", type = "S" },
        { name = "userId", type = "S" }
      ]
      global_secondary_indexes = [{
        name            = "UserIdIndex"
        hash_key        = "userId"
        projection_type = "ALL"
      }]
    }
  }

  # Null resources for packaging
  null_resources = {
    package_authorizer = {
      triggers = {
        code_hash = filemd5("${path.root}/lambda-authorizer/index.js")
        package_hash = filemd5("${path.root}/lambda-authorizer/package.json")
      }
      command     = "bash package.sh"
      working_dir = "${path.root}/lambda-authorizer"
    }
  }

  # Lambda functions configuration
  lambda_functions = {
    backend = {
      function_name = "${local.project_name}-${local.environment}-tasks"
      handler       = "index.handler"
      runtime       = "nodejs18.x"
      timeout       = 30
      memory_size   = 256
      filename      = "${path.root}/backend.zip"
      role_name     = "${local.project_name}-${local.environment}-lambda-role"
      policy_name   = "${local.project_name}-lambda-policy"
      policy_file   = "policies/lambda-backend-policy.json"
      environment_variables = {
        TABLE_NAME = "dynamodb_tasks"  # Reference to module output
      }
    }
    authorizer = {
      function_name = "${local.project_name}-${local.environment}-firebase-authorizer"
      handler       = "index.handler"
      runtime       = "nodejs18.x"
      timeout       = 10
      memory_size   = 128
      filename      = "${path.root}/lambda-authorizer.zip"
      role_name     = "${local.project_name}-${local.environment}-authorizer-role"
      policy_arn    = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
      environment_variables = {
        FIREBASE_PROJECT_ID = "firebase_project_id"  # Reference to SSM
        ALLOWED_ORIGINS     = "frontend_domain"      # Reference to config
      }
      depends_on_null = "package_authorizer"
    }
  }

  # API Gateway configuration
  apigateways = {
    main = {
      api_name               = "${local.project_name}-${local.environment}-api"
      protocol_type          = "HTTP"
      stage_name             = "$default"
      auto_deploy            = true
      throttling_burst_limit = 100
      throttling_rate_limit  = 50
      endpoint_type          = "REGIONAL"
      security_policy        = "TLS_1_2"
      
      cors_configuration = {
        allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
        allow_headers = ["content-type", "authorization"]
        max_age       = 300
      }

      integrations = {
        tasks = {
          integration_type       = "AWS_PROXY"
          payload_format_version = "2.0"
          lambda_key             = "backend"
        }
      }

      authorizers = {
        firebase = {
          authorizer_type         = "REQUEST"
          identity_sources        = ["$request.header.Authorization"]
          name                    = "${local.project_name}-firebase-authorizer"
          payload_format_version  = "2.0"
          enable_simple_responses = false
          lambda_key              = "authorizer"
        }
      }

      routes = {
        list_tasks = {
          route_key          = "GET /tasks"
          integration_key    = "tasks"
          authorization_type = "CUSTOM"
          authorizer_id      = "firebase"
        }
        create_task = {
          route_key          = "POST /tasks"
          integration_key    = "tasks"
          authorization_type = "CUSTOM"
          authorizer_id      = "firebase"
        }
        get_task = {
          route_key          = "GET /tasks/{id}"
          integration_key    = "tasks"
          authorization_type = "CUSTOM"
          authorizer_id      = "firebase"
        }
        update_task = {
          route_key          = "PUT /tasks/{id}"
          integration_key    = "tasks"
          authorization_type = "CUSTOM"
          authorizer_id      = "firebase"
        }
        delete_task = {
          route_key          = "DELETE /tasks/{id}"
          integration_key    = "tasks"
          authorization_type = "CUSTOM"
          authorizer_id      = "firebase"
        }
        options_tasks = {
          route_key          = "OPTIONS /tasks"
          integration_key    = "tasks"
          authorization_type = "NONE"
        }
        options_tasks_id = {
          route_key          = "OPTIONS /tasks/{id}"
          integration_key    = "tasks"
          authorization_type = "NONE"
        }
      }
    }
  }

  # Amplify apps configuration
  amplify_apps = {
    frontend = {
      app_name         = "${local.project_name}-${local.environment}"
      branch_name      = "main"
      subdomain_prefix = local.config.frontend_domain
    }
  }

  # CodePipeline configuration
  codepipelines = {
    main = {
      pipeline_name = "${local.project_name}-${local.environment}-pipeline"
    }
  }

  # Cloudflare DNS records
  cloudflare_records = {
    frontend = {
      zone_id = "cloudflare_zone_id"  # Reference to SSM
      name    = local.config.frontend_domain
      type    = "CNAME"
      proxied = false
      ttl     = 1
      comment = "${local.environment} Frontend Amplify CloudFront"
      content_source = "amplify"
      content_key    = "frontend"
    }
    backend = {
      zone_id = "cloudflare_zone_id"  # Reference to SSM
      name    = local.config.api_domain
      type    = "CNAME"
      proxied = false
      ttl     = 1
      comment = "${local.environment} Backend API Gateway custom domain"
      content_source = "apigateway"
      content_key    = "main"
    }
  }

  # ACM Certificates
  acm_certificates = {
    backend = {
      domain_name       = "${local.config.api_domain}.${data.aws_ssm_parameter.cloudflare_domain.value}"
      validation_method = "DNS"
      provider_alias    = "us_east_1"
    }
  }
}
