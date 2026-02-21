#!/bin/bash
set -e

PROFILE="david-new"
REGION="us-east-1"
AMPLIFY_APP_ID="d3t6aq2bhqs97t"
LAMBDA_TASKS="tasks-3d-prod-tasks"
API_URL="https://e7xuui6dqf.execute-api.us-east-1.amazonaws.com"

echo "🚀 Starting deployment..."

# Get Firebase config from SSM
echo "📦 Getting Firebase config..."
export VITE_FIREBASE_API_KEY=$(aws ssm get-parameter --name /tasks-3d/firebase/api_key --region $REGION --profile $PROFILE --query 'Parameter.Value' --output text)
export VITE_FIREBASE_AUTH_DOMAIN=$(aws ssm get-parameter --name /tasks-3d/firebase/auth_domain --region $REGION --profile $PROFILE --query 'Parameter.Value' --output text)
export VITE_FIREBASE_PROJECT_ID=$(aws ssm get-parameter --name /tasks-3d/firebase/project_id --region $REGION --profile $PROFILE --query 'Parameter.Value' --output text)
export VITE_FIREBASE_STORAGE_BUCKET=$(aws ssm get-parameter --name /tasks-3d/firebase/storage_bucket --region $REGION --profile $PROFILE --query 'Parameter.Value' --output text)
export VITE_FIREBASE_MESSAGING_SENDER_ID=$(aws ssm get-parameter --name /tasks-3d/firebase/messaging_sender_id --region $REGION --profile $PROFILE --query 'Parameter.Value' --output text)
export VITE_FIREBASE_APP_ID=$(aws ssm get-parameter --name /tasks-3d/firebase/app_id --region $REGION --profile $PROFILE --query 'Parameter.Value' --output text)
export VITE_API_URL=$API_URL

# Deploy Backend
echo "🔧 Deploying backend..."
cd backend
npm install --production
zip -r /tmp/lambda-tasks.zip . -q
aws lambda update-function-code \
  --function-name $LAMBDA_TASKS \
  --zip-file fileb:///tmp/lambda-tasks.zip \
  --region $REGION \
  --profile $PROFILE \
  --query 'LastModified' \
  --output text
echo "✅ Backend deployed"

# Deploy Frontend
echo "🎨 Building frontend..."
cd ../frontend
npm install
npm run build

echo "📤 Deploying to Amplify..."
cd dist
zip -r /tmp/frontend.zip . -q

RESULT=$(aws amplify create-deployment \
  --app-id $AMPLIFY_APP_ID \
  --branch-name main \
  --region $REGION \
  --profile $PROFILE \
  --output json)

UPLOAD_URL=$(echo $RESULT | jq -r '.zipUploadUrl')
JOB_ID=$(echo $RESULT | jq -r '.jobId')

curl -X PUT -T /tmp/frontend.zip "$UPLOAD_URL" -s -o /dev/null

aws amplify start-deployment \
  --app-id $AMPLIFY_APP_ID \
  --branch-name main \
  --job-id $JOB_ID \
  --region $REGION \
  --profile $PROFILE \
  --output text

echo "⏳ Waiting for deployment..."
sleep 15

STATUS=$(aws amplify get-job \
  --app-id $AMPLIFY_APP_ID \
  --branch-name main \
  --job-id $JOB_ID \
  --region $REGION \
  --profile $PROFILE \
  --query 'job.summary.status' \
  --output text)

echo "✅ Frontend deployed: $STATUS"
echo ""
echo "🌐 URLs:"
echo "   Frontend: https://app.amxops.com"
echo "   API: $API_URL"
