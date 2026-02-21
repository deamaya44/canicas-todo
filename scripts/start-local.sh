#!/bin/bash

PROFILE="david-new"
REGION="us-east-1"

echo "🔥 Getting Firebase config from SSM..."

export VITE_FIREBASE_API_KEY=$(aws ssm get-parameter --name /tasks-3d/firebase/api_key --region $REGION --profile $PROFILE --query 'Parameter.Value' --output text)
export VITE_FIREBASE_AUTH_DOMAIN=$(aws ssm get-parameter --name /tasks-3d/firebase/auth_domain --region $REGION --profile $PROFILE --query 'Parameter.Value' --output text)
export VITE_FIREBASE_PROJECT_ID=$(aws ssm get-parameter --name /tasks-3d/firebase/project_id --region $REGION --profile $PROFILE --query 'Parameter.Value' --output text)
export VITE_FIREBASE_STORAGE_BUCKET=$(aws ssm get-parameter --name /tasks-3d/firebase/storage_bucket --region $REGION --profile $PROFILE --query 'Parameter.Value' --output text)
export VITE_FIREBASE_MESSAGING_SENDER_ID=$(aws ssm get-parameter --name /tasks-3d/firebase/messaging_sender_id --region $REGION --profile $PROFILE --query 'Parameter.Value' --output text)
export VITE_FIREBASE_APP_ID=$(aws ssm get-parameter --name /tasks-3d/firebase/app_id --region $REGION --profile $PROFILE --query 'Parameter.Value' --output text)

echo "✅ Firebase config loaded"
echo ""
echo "🐳 Starting Docker containers..."

sudo docker compose up -d --build

echo ""
echo "✅ Containers started!"
echo ""
echo "🌐 URLs:"
echo "   Frontend: http://localhost:3000"
echo "   Backend:  http://localhost:3001"
echo ""
echo "📋 View logs: sudo docker compose logs -f"
echo "🛑 Stop:      sudo docker compose down"
