data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.project_name}-codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json

  tags = var.common_tags
}

data "aws_iam_policy_document" "codebuild_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = ["${var.artifacts_bucket_arn}/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "codecommit:GitPull"
    ]
    resources = ["*"]
  }

  # Permisos para frontend: subir archivos a S3 bucket de hosting
  # Permisos para frontend: deploy a Amplify
  dynamic "statement" {
    for_each = var.amplify_app_arn != "" ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "amplify:CreateDeployment",
        "amplify:StartDeployment",
        "amplify:GetJob"
      ]
      resources = [
        var.amplify_app_arn,
        "${var.amplify_app_arn}/*"
      ]
    }
  }

  # Permisos para backend: actualizar código Lambda
  dynamic "statement" {
    for_each = var.lambda_function_arn != "" ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "lambda:UpdateFunctionCode"
      ]
      resources = [var.lambda_function_arn]
    }
  }

  dynamic "statement" {
    for_each = var.privileged_mode ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage"
      ]
      resources = ["*"]
    }
  }
}

resource "aws_iam_role_policy" "this" {
  role   = aws_iam_role.this.name
  policy = data.aws_iam_policy_document.codebuild_policy.json
}

resource "aws_codebuild_project" "this" {
  name          = var.project_name
  description   = var.description
  service_role  = aws_iam_role.this.arn
  build_timeout = 60

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = var.compute_type
    image                       = var.image
    type                        = var.type
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = var.privileged_mode

    dynamic "environment_variable" {
      for_each = var.environment_variables
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.buildspec
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.common_tags
}
