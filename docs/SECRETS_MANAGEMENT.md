# 🔐 Secrets Management with AWS SSM Parameter Store

All sensitive credentials are stored in AWS Systems Manager Parameter Store. **NO credentials are stored in code or git.**

## 📋 Required Parameters

### Firebase Configuration (String - Public)

```bash
# Firebase Project ID
aws ssm put-parameter \
  --name "/tasks-3d/firebase/project_id" \
  --value "your-firebase-project-id" \
  --type String \
  --region us-east-1

# Firebase API Key (public, goes in frontend)
aws ssm put-parameter \
  --name "/tasks-3d/firebase/api_key" \
  --value "your-firebase-api-key" \
  --type String \
  --region us-east-1

# Firebase Auth Domain
aws ssm put-parameter \
  --name "/tasks-3d/firebase/auth_domain" \
  --value "your-project.firebaseapp.com" \
  --type String \
  --region us-east-1

# Firebase Storage Bucket
aws ssm put-parameter \
  --name "/tasks-3d/firebase/storage_bucket" \
  --value "your-project.firebasestorage.app" \
  --type String \
  --region us-east-1

# Firebase Messaging Sender ID
aws ssm put-parameter \
  --name "/tasks-3d/firebase/messaging_sender_id" \
  --value "your-sender-id" \
  --type String \
  --region us-east-1

# Firebase App ID
aws ssm put-parameter \
  --name "/tasks-3d/firebase/app_id" \
  --value "your-app-id" \
  --type String \
  --region us-east-1
```

### Cloudflare Configuration (SecureString - Private)

```bash
# Cloudflare API Token (SENSITIVE)
aws ssm put-parameter \
  --name "/tasks-3d/cloudflare/api_token" \
  --value "your-cloudflare-api-token" \
  --type SecureString \
  --region us-east-1

# Cloudflare Zone ID
aws ssm put-parameter \
  --name "/tasks-3d/cloudflare/zone_id" \
  --value "your-zone-id" \
  --type String \
  --region us-east-1

# Cloudflare Domain
aws ssm put-parameter \
  --name "/tasks-3d/cloudflare/domain" \
  --value "amxops.com" \
  --type String \
  --region us-east-1
```

## 🔍 Verify Parameters

```bash
# List all parameters
aws ssm get-parameters-by-path \
  --path "/tasks-3d" \
  --recursive \
  --region us-east-1 \
  --query "Parameters[].Name"

# Get a specific parameter (non-sensitive)
aws ssm get-parameter \
  --name "/tasks-3d/firebase/project_id" \
  --region us-east-1 \
  --query "Parameter.Value" \
  --output text

# Get a SecureString parameter (decrypted)
aws ssm get-parameter \
  --name "/tasks-3d/cloudflare/api_token" \
  --with-decryption \
  --region us-east-1 \
  --query "Parameter.Value" \
  --output text
```

## 🔄 Update Parameters

```bash
# Update existing parameter
aws ssm put-parameter \
  --name "/tasks-3d/firebase/api_key" \
  --value "new-value" \
  --type String \
  --overwrite \
  --region us-east-1
```

## 🗑️ Delete Parameters (if needed)

```bash
# Delete a single parameter
aws ssm delete-parameter \
  --name "/tasks-3d/firebase/api_key" \
  --region us-east-1

# Delete all tasks-3d parameters (DANGEROUS!)
aws ssm get-parameters-by-path \
  --path "/tasks-3d" \
  --recursive \
  --region us-east-1 \
  --query "Parameters[].Name" \
  --output text | xargs -n1 aws ssm delete-parameter --name --region us-east-1
```

## 🏗️ How Terraform Uses These

Terraform reads parameters automatically:

```hcl
# infra/terraform/firebase-data.tf
data "aws_ssm_parameter" "firebase_project_id" {
  name = "/tasks-3d/firebase/project_id"
}

# Used in modules
firebase_project_id = data.aws_ssm_parameter.firebase_project_id.value
```

## 🐳 Local Development

For local development, create `.env.local` files (gitignored):

```bash
# frontend/.env.local
VITE_FIREBASE_API_KEY=your-key
VITE_FIREBASE_AUTH_DOMAIN=your-domain
VITE_FIREBASE_PROJECT_ID=your-project
VITE_FIREBASE_STORAGE_BUCKET=your-bucket
VITE_FIREBASE_MESSAGING_SENDER_ID=your-sender-id
VITE_FIREBASE_APP_ID=your-app-id
VITE_API_URL=http://localhost:3001
```

**These files are NOT committed to git.**

## 🔒 Security Best Practices

1. **Never commit credentials** to git
2. **Use SecureString** for sensitive data (API tokens, passwords)
3. **Use String** for public data (project IDs, domains)
4. **Rotate credentials** regularly
5. **Use IAM roles** to control access to parameters
6. **Enable CloudTrail** to audit parameter access

## 📝 For Contributors

Contributors don't need AWS credentials for local development:
- Use Docker: `docker-compose up`
- Backend works without Firebase (dev mode)
- Frontend can use mock Firebase config

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## 🚨 If Credentials Are Compromised

1. **Immediately rotate** the compromised credential
2. **Update SSM Parameter** with new value
3. **Redeploy** affected services
4. **Review CloudTrail logs** for unauthorized access
5. **Update `.env.local`** files for local development

## 💰 Cost

AWS SSM Parameter Store:
- **Standard parameters**: FREE (up to 10,000)
- **Advanced parameters**: $0.05 per parameter per month
- **API calls**: $0.05 per 10,000 calls

**Estimated cost**: $0/month (using standard parameters)
