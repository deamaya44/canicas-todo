# Request SSL certificate for CloudFront (must be in us-east-1)
resource "aws_acm_certificate" "frontend" {
  provider          = aws.us_east_1
  domain_name       = "${local.config.frontend_domain}.${data.aws_ssm_parameter.cloudflare_domain.value}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-${local.environment}-frontend-cert"
  })
}

# Cloudflare DNS validation records
resource "cloudflare_record" "cert_validation_frontend" {
  for_each = {
    for dvo in aws_acm_certificate.frontend.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = data.aws_ssm_parameter.cloudflare_zone_id.value
  name    = each.value.name
  content = each.value.record
  type    = each.value.type
  ttl     = 60
  proxied = false
}

# Wait for certificate validation
resource "aws_acm_certificate_validation" "frontend" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.frontend.arn
  validation_record_fqdns = [for record in cloudflare_record.cert_validation_frontend : record.hostname]
}

# Request SSL certificate for API Gateway (regional)
resource "aws_acm_certificate" "backend" {
  domain_name       = "${local.config.api_domain}.${data.aws_ssm_parameter.cloudflare_domain.value}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-${local.environment}-backend-cert"
  })
}

# Cloudflare DNS validation records for backend
resource "cloudflare_record" "cert_validation_backend" {
  for_each = {
    for dvo in aws_acm_certificate.backend.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = data.aws_ssm_parameter.cloudflare_zone_id.value
  name    = each.value.name
  content = each.value.record
  type    = each.value.type
  ttl     = 60
  proxied = false
}

# Wait for certificate validation
resource "aws_acm_certificate_validation" "backend" {
  certificate_arn         = aws_acm_certificate.backend.arn
  validation_record_fqdns = [for record in cloudflare_record.cert_validation_backend : record.hostname]
}
