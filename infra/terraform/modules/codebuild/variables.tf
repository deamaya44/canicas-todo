variable "project_name" {
  description = "CodeBuild project name"
  type        = string
}

variable "description" {
  description = "Project description"
  type        = string
  default     = ""
}

variable "lambda_function_arn" {
  description = "Lambda function ARN for backend builds"
  type        = string
  default     = ""
}

variable "cloudfront_distribution_arn" {
  description = "CloudFront distribution ARN for frontend builds"
  type        = string
  default     = ""
}

variable "source_type" {
  description = "Source type"
  type        = string
  default     = "CODECOMMIT"
}

variable "source_location" {
  description = "Source location"
  type        = string
}

variable "buildspec" {
  description = "Buildspec file path"
  type        = string
  default     = "buildspec.yml"
}

variable "compute_type" {
  description = "Compute type"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "image" {
  description = "Docker image"
  type        = string
  default     = "aws/codebuild/standard:7.0"
}

variable "type" {
  description = "Environment type"
  type        = string
  default     = "LINUX_CONTAINER"
}

variable "privileged_mode" {
  description = "Enable privileged mode for Docker"
  type        = bool
  default     = false
}

variable "artifacts_bucket" {
  description = "S3 bucket for artifacts"
  type        = string
}

variable "artifacts_bucket_arn" {
  description = "S3 bucket ARN for artifacts"
  type        = string
  default     = ""
}

variable "frontend_bucket_arn" {
  description = "S3 bucket ARN for frontend hosting (optional)"
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "environment_variables" {
  description = "Environment variables for CodeBuild"
  type        = map(string)
  default     = {}
}
