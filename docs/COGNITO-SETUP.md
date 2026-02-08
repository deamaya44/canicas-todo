# Cognito Setup with Google OAuth

## 1. Create Google OAuth Credentials

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Navigate to **APIs & Services** → **Credentials**
4. Click **Create Credentials** → **OAuth 2.0 Client ID**
5. Configure consent screen if needed
6. Application type: **Web application**
7. Add authorized redirect URIs:
   ```
   https://tasks-3d-prod-auth.auth.us-east-1.amazoncognito.com/oauth2/idpresponse
   ```
   (Replace region and domain prefix based on your Cognito setup)
8. Save **Client ID** and **Client Secret**

## 2. Store Credentials in AWS SSM

```bash
# Store Google Client ID
aws ssm put-parameter \
  --name "/tasks-3d/google/client_id" \
  --value "YOUR_GOOGLE_CLIENT_ID" \
  --type String \
  --region us-east-1

# Store Google Client Secret
aws ssm put-parameter \
  --name "/tasks-3d/google/client_secret" \
  --value "YOUR_GOOGLE_CLIENT_SECRET" \
  --type SecureString \
  --region us-east-1
```

## 3. Deploy Infrastructure

```bash
cd infra/terraform
terraform init
terraform apply -var-file="terraform.tfvars"
```

## 4. Update Google OAuth Redirect URI

After Terraform creates Cognito:

1. Get the Cognito domain from Terraform output:
   ```bash
   terraform output cognito
   ```

2. Update Google OAuth redirect URI with the actual Cognito domain:
   ```
   https://<cognito-domain>.auth.<region>.amazoncognito.com/oauth2/idpresponse
   ```

## 5. Frontend Integration

The frontend needs to use AWS Amplify or Cognito SDK to handle authentication.

### Install Dependencies

```bash
cd frontend
npm install @aws-amplify/auth
```

### Configure Amplify

```javascript
import { Amplify } from 'aws-amplify';

Amplify.configure({
  Auth: {
    region: 'us-east-1',
    userPoolId: 'YOUR_USER_POOL_ID',
    userPoolWebClientId: 'YOUR_CLIENT_ID',
    oauth: {
      domain: 'YOUR_COGNITO_DOMAIN.auth.us-east-1.amazoncognito.com',
      scope: ['email', 'openid', 'profile'],
      redirectSignIn: 'https://app.yourdomain.com/callback',
      redirectSignOut: 'https://app.yourdomain.com/',
      responseType: 'code'
    }
  }
});
```

## 6. API Calls with Authentication

All API calls must include the JWT token in the Authorization header:

```javascript
const token = (await Auth.currentSession()).getIdToken().getJwtToken();

fetch('https://api.yourdomain.com/tasks', {
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  }
});
```

## Architecture

```
User → Google OAuth → Cognito → JWT Token → API Gateway → Lambda → DynamoDB
                                                                      ↓
                                                              Filter by userId
```

Each user's tasks are isolated by their Cognito `sub` (user ID).
