# Frontend: app.amxops.com (prod) or dev.amxops.com (dev) → Amplify
resource "cloudflare_record" "frontend" {
  zone_id = data.aws_ssm_parameter.cloudflare_zone_id.value
  name    = local.config.frontend_domain
  content = module.amplify_frontend.default_domain
  type    = "CNAME"
  proxied = false
  ttl     = 1
  comment = "${local.environment} Frontend Amplify Hosting"

  depends_on = [module.amplify_frontend]
}

# Amplify domain certificate validation
# Parse: "_6e744fcbb05f3dbfde944d27aa1a9bc7.amxops.com. CNAME _c5655b3db2c865cc109ac3109ebf9a00.jkddzztszm.acm-validations.aws."
locals {
  cert_record_parts = split(" CNAME ", module.amplify_frontend.domain_association.certificate_verification_dns_record)
  cert_record_name  = trimsuffix(local.cert_record_parts[0], ".")
  cert_record_value = trimsuffix(local.cert_record_parts[1], ".")
}

resource "cloudflare_record" "amplify_cert_validation" {
  zone_id = data.aws_ssm_parameter.cloudflare_zone_id.value
  name    = local.cert_record_name
  content = local.cert_record_value
  type    = "CNAME"
  proxied = false
  ttl     = 1
  comment = "${local.environment} Amplify domain certificate validation"

  depends_on = [module.amplify_frontend]
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
