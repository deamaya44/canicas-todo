variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "tasks-3d"
}

variable "owner" {
  description = "Project owner"
  type        = string
  default     = "devops"
}

variable "notification_emails" {
  description = "List of emails for pipeline notifications"
  type        = list(string)
  default     = []
}

# Environment is derived from workspace
locals {
  environment = terraform.workspace == "default" ? "prod" : terraform.workspace
  
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
}
