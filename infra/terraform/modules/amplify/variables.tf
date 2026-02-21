variable "app_name" {
  description = "Name of the Amplify app"
  type        = string
}

variable "branch_name" {
  description = "Branch name for deployment"
  type        = string
  default     = "main"
}

variable "build_spec" {
  description = "Custom build specification (YAML). Leave empty for manual deployment"
  type        = string
  default     = ""
}

variable "environment_variables" {
  description = "Environment variables for the app"
  type        = map(string)
  default     = {}
}

variable "custom_domain" {
  description = "Custom domain name (leave empty for default amplifyapp.com domain)"
  type        = string
  default     = ""
}

variable "subdomain_prefix" {
  description = "Subdomain prefix for custom domain"
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
