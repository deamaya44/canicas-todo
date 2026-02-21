# Data sources para leer los parámetros de SSM
data "aws_ssm_parameter" "cloudflare_api_token" {
  name = "/tasks-3d/cloudflare/api_token"
}

data "aws_ssm_parameter" "cloudflare_zone_id" {
  name = "/tasks-3d/cloudflare/zone_id"
}

data "aws_ssm_parameter" "cloudflare_domain" {
  name = "/tasks-3d/cloudflare/domain"
}
