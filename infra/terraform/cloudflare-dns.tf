# Frontend: app.amxops.com (prod) or dev.amxops.com (dev) → CloudFront
resource "cloudflare_record" "frontend" {
  zone_id = data.aws_ssm_parameter.cloudflare_zone_id.value
  name    = local.config.frontend_domain
  content = module.cloudfront.domain_name
  type    = "CNAME"
  proxied = false
  ttl     = 1
  comment = "${local.environment} Frontend CloudFront distribution"

  depends_on = [module.cloudfront]
}

# Backend API: api.amxops.com (prod) or api-dev.amxops.com (dev) → API Gateway Custom Domain
resource "cloudflare_record" "backend" {
  zone_id = data.aws_ssm_parameter.cloudflare_zone_id.value
  name    = local.config.api_domain
  content = module.api_backend.custom_domain_target
  type    = "CNAME"
  proxied = false
  ttl     = 1
  comment = "${local.environment} Backend API Gateway custom domain"

  depends_on = [module.api_backend]
}
