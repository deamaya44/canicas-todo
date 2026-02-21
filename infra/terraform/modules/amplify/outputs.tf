output "app_id" {
  description = "Amplify App ID"
  value       = aws_amplify_app.this.id
}

output "app_arn" {
  description = "Amplify App ARN"
  value       = aws_amplify_app.this.arn
}

output "default_domain" {
  description = "Default Amplify domain"
  value       = aws_amplify_app.this.default_domain
}

output "branch_name" {
  description = "Branch name"
  value       = aws_amplify_branch.main.branch_name
}

output "branch_url" {
  description = "Branch URL"
  value       = "https://${aws_amplify_branch.main.branch_name}.${aws_amplify_app.this.default_domain}"
}

output "custom_domain" {
  description = "Custom domain (if configured)"
  value       = var.custom_domain != "" ? "https://${var.subdomain_prefix != "" ? "${var.subdomain_prefix}." : ""}${var.custom_domain}" : null
}

output "domain_association" {
  description = "Domain association details (if configured)"
  value       = var.custom_domain != "" ? aws_amplify_domain_association.this[0] : null
}

output "cloudfront_domain" {
  description = "CloudFront domain for custom domain (if configured)"
  value       = var.custom_domain != "" ? try(tolist(aws_amplify_domain_association.this[0].sub_domain)[0].dns_record, null) : null
}
