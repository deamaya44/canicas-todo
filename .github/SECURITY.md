# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability, please open a private security advisory on GitHub.

**Please do not open public issues for security vulnerabilities.**

## Security Best Practices

This project follows these security practices:

- ✅ No hardcoded credentials or API keys
- ✅ All sensitive data stored in AWS SSM Parameter Store
- ✅ CORS properly configured per environment
- ✅ S3 buckets are private with CloudFront OAC
- ✅ IAM roles follow least privilege principle
- ✅ Dependencies regularly updated

## Environment Variables

Never commit files containing:
- AWS credentials
- API tokens
- Private keys
- Passwords
- Any sensitive configuration

Use `.env.example` files as templates.

## Infrastructure Security

### Terraform State
- Never commit `terraform.tfstate` files
- Use remote state with S3 + DynamoDB locking in production
- Keep `.tfvars` files out of version control

### AWS Resources
- Lambda functions use IAM roles (no hardcoded credentials)
- DynamoDB tables use on-demand billing
- CloudFront uses OAC for S3 access
- API Gateway has CORS restrictions

### Secrets Management
- Cloudflare API token: AWS SSM Parameter Store (SecureString)
- Domain configuration: AWS SSM Parameter Store
- No secrets in code or environment variables
