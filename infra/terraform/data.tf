data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Firebase SSM Parameters
data "aws_ssm_parameter" "firebase_project_id" {
  name = "/tasks-3d/firebase/project_id"
}

data "aws_ssm_parameter" "firebase_api_key" {
  name = "/tasks-3d/firebase/api_key"
}

data "aws_ssm_parameter" "firebase_auth_domain" {
  name = "/tasks-3d/firebase/auth_domain"
}

data "aws_ssm_parameter" "firebase_storage_bucket" {
  name = "/tasks-3d/firebase/storage_bucket"
}

data "aws_ssm_parameter" "firebase_messaging_sender_id" {
  name = "/tasks-3d/firebase/messaging_sender_id"
}

data "aws_ssm_parameter" "firebase_app_id" {
  name = "/tasks-3d/firebase/app_id"
}

# Cloudflare SSM Parameters
data "aws_ssm_parameter" "cloudflare_api_token" {
  name = "/tasks-3d/cloudflare/api_token"
}

data "aws_ssm_parameter" "cloudflare_zone_id" {
  name = "/tasks-3d/cloudflare/zone_id"
}

data "aws_ssm_parameter" "cloudflare_domain" {
  name = "/tasks-3d/cloudflare/domain"
}
