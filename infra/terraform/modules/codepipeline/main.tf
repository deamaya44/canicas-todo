data "aws_iam_policy_document" "codepipeline_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.pipeline_name}-role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role.json

  tags = var.common_tags
}

data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:GetObjectVersion"
    ]
    resources = ["arn:aws:s3:::${var.artifacts_bucket}/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "codecommit:GetBranch",
      "codecommit:GetCommit",
      "codecommit:UploadArchive",
      "codecommit:GetUploadArchiveStatus",
      "codecommit:CancelUploadArchive"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "this" {
  role   = aws_iam_role.this.name
  policy = data.aws_iam_policy_document.codepipeline_policy.json
}

resource "aws_codepipeline" "this" {
  name     = var.pipeline_name
  role_arn = aws_iam_role.this.arn

  artifact_store {
    location = var.artifacts_bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Backend-Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["backend_source"]

      configuration = {
        RepositoryName       = var.backend_repo_name
        BranchName           = "main"
        PollForSourceChanges = false
      }
    }

    action {
      name             = "Frontend-Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["frontend_source"]

      configuration = {
        RepositoryName       = var.frontend_repo_name
        BranchName           = "main"
        PollForSourceChanges = false
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Backend-Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["backend_source"]
      output_artifacts = ["backend_build"]

      configuration = {
        ProjectName = var.backend_build_name
      }
    }

    action {
      name             = "Frontend-Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["frontend_source"]
      output_artifacts = ["frontend_build"]

      configuration = {
        ProjectName = var.frontend_build_name
      }
    }
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_event_rule" "backend" {
  name        = "${var.pipeline_name}-backend-trigger"
  description = "Trigger pipeline on backend repository changes"

  event_pattern = jsonencode({
    source      = ["aws.codecommit"]
    detail-type = ["CodeCommit Repository State Change"]
    detail = {
      event         = ["referenceCreated", "referenceUpdated"]
      repositoryName = [var.backend_repo_name]
      referenceName  = ["main"]
    }
  })

  tags = var.common_tags
}

resource "aws_cloudwatch_event_target" "backend" {
  rule      = aws_cloudwatch_event_rule.backend.name
  target_id = "codepipeline"
  arn       = aws_codepipeline.this.arn
  role_arn  = aws_iam_role.eventbridge.arn
}

resource "aws_cloudwatch_event_rule" "frontend" {
  name        = "${var.pipeline_name}-frontend-trigger"
  description = "Trigger pipeline on frontend repository changes"

  event_pattern = jsonencode({
    source      = ["aws.codecommit"]
    detail-type = ["CodeCommit Repository State Change"]
    detail = {
      event         = ["referenceCreated", "referenceUpdated"]
      repositoryName = [var.frontend_repo_name]
      referenceName  = ["main"]
    }
  })

  tags = var.common_tags
}

resource "aws_cloudwatch_event_target" "frontend" {
  rule      = aws_cloudwatch_event_rule.frontend.name
  target_id = "codepipeline"
  arn       = aws_codepipeline.this.arn
  role_arn  = aws_iam_role.eventbridge.arn
}

data "aws_iam_policy_document" "eventbridge_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eventbridge" {
  name               = "${var.pipeline_name}-eventbridge-role"
  assume_role_policy = data.aws_iam_policy_document.eventbridge_assume_role.json

  tags = var.common_tags
}

data "aws_iam_policy_document" "eventbridge_policy" {
  statement {
    effect = "Allow"
    actions = [
      "codepipeline:StartPipelineExecution"
    ]
    resources = [aws_codepipeline.this.arn]
  }
}

resource "aws_iam_role_policy" "eventbridge" {
  role   = aws_iam_role.eventbridge.name
  policy = data.aws_iam_policy_document.eventbridge_policy.json
}
