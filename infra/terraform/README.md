# Infrastructure

Terraform configuration for AWS resources.

## Quick Start

```bash
cd infra/terraform

# Initialize
terraform init

# Deploy production
terraform apply -var-file="terraform.tfvars"

# Deploy development
terraform apply -var-file="terraform.dev.tfvars"
```

## Configuration

Create `terraform.tfvars`:

```hcl
project_name = "tasks-3d"
environment  = "prod"
aws_region   = "us-east-1"
owner        = "your-name"

notification_emails = [
  "your-email@example.com"
]
```

## Resources Created

- **S3** - Frontend hosting
- **CloudFront** - CDN with OAC
- **Lambda** - Backend API
- **API Gateway** - REST API with custom domain
- **DynamoDB** - Task storage
- **CodePipeline** - CI/CD
- **CodeBuild** - Build projects
- **ACM** - SSL certificates
- **Cloudflare DNS** - Domain records (optional)

## Secrets

Store Cloudflare API token (if using custom domain):

```bash
aws ssm put-parameter \
  --name "/tasks-3d/cloudflare/api_token" \
  --value "your-token" \
  --type SecureString \
  --region us-east-1
```

## Deployment Script

```bash
./deploy.sh prod    # Production
./deploy.sh dev     # Development
```
