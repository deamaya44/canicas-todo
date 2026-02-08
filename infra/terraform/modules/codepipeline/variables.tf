variable "pipeline_name" {
  description = "CodePipeline name"
  type        = string
}

variable "artifacts_bucket" {
  description = "S3 bucket for artifacts"
  type        = string
}

variable "backend_repo_name" {
  description = "Backend repository name"
  type        = string
}

variable "frontend_repo_name" {
  description = "Frontend repository name"
  type        = string
}

variable "backend_build_name" {
  description = "Backend CodeBuild project name"
  type        = string
}

variable "frontend_build_name" {
  description = "Frontend CodeBuild project name"
  type        = string
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
