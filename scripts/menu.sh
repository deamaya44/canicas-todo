#!/bin/bash

PROFILE="david-new"
REGION="us-east-1"

show_menu() {
    clear
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║          🚀 3D TASK MANAGER - DEPLOYMENT MENU                ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "🐳 LOCAL:"
    echo "  1) Start local environment (Docker)"
    echo "  2) Stop local environment"
    echo "  3) View Docker logs"
    echo ""
    echo "📦 AWS DEPLOYMENT:"
    echo "  4) Deploy Backend + Frontend"
    echo "  5) Deploy Backend only"
    echo "  6) Deploy Frontend only"
    echo ""
    echo "🔧 TERRAFORM:"
    echo "  7) Terraform init"
    echo "  8) Terraform plan"
    echo "  9) Terraform apply"
    echo "  10) Terraform destroy"
    echo ""
    echo "📊 STATUS:"
    echo "  11) Check AWS deployment status"
    echo "  12) View Lambda logs"
    echo ""
    echo "  0) Exit"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

deploy_backend() {
    echo "🔧 Deploying backend..."
    cd backend
    npm install --production
    zip -r /tmp/lambda-tasks.zip . -q
    aws lambda update-function-code \
      --function-name tasks-3d-prod-tasks \
      --zip-file fileb:///tmp/lambda-tasks.zip \
      --region $REGION \
      --profile $PROFILE \
      --query 'LastModified' \
      --output text
    cd ..
    echo "✅ Backend deployed"
}

deploy_frontend() {
    echo "🎨 Building frontend..."
    
    export VITE_FIREBASE_API_KEY=$(aws ssm get-parameter --name /tasks-3d/firebase/api_key --region $REGION --profile $PROFILE --query 'Parameter.Value' --output text)
    export VITE_FIREBASE_AUTH_DOMAIN=$(aws ssm get-parameter --name /tasks-3d/firebase/auth_domain --region $REGION --profile $PROFILE --query 'Parameter.Value' --output text)
    export VITE_FIREBASE_PROJECT_ID=$(aws ssm get-parameter --name /tasks-3d/firebase/project_id --region $REGION --profile $PROFILE --query 'Parameter.Value' --output text)
    export VITE_FIREBASE_STORAGE_BUCKET=$(aws ssm get-parameter --name /tasks-3d/firebase/storage_bucket --region $REGION --profile $PROFILE --query 'Parameter.Value' --output text)
    export VITE_FIREBASE_MESSAGING_SENDER_ID=$(aws ssm get-parameter --name /tasks-3d/firebase/messaging_sender_id --region $REGION --profile $PROFILE --query 'Parameter.Value' --output text)
    export VITE_FIREBASE_APP_ID=$(aws ssm get-parameter --name /tasks-3d/firebase/app_id --region $REGION --profile $PROFILE --query 'Parameter.Value' --output text)
    export VITE_API_URL=$(aws apigatewayv2 get-apis --region $REGION --profile $PROFILE --query 'Items[?Name==`tasks-3d-prod-api`].ApiEndpoint' --output text)
    
    cd frontend
    npm install
    npm run build
    
    echo "📤 Deploying to Amplify..."
    cd dist
    zip -r /tmp/frontend.zip . -q
    
    AMPLIFY_APP_ID=$(aws amplify list-apps --region $REGION --profile $PROFILE --query 'apps[?name==`tasks-3d-prod`].appId' --output text)
    
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
      --output text > /dev/null
    
    echo "⏳ Waiting for deployment..."
    sleep 15
    
    cd ../../..
    echo "✅ Frontend deployed"
}

check_status() {
    echo "📊 Checking status..."
    echo ""
    
    AMPLIFY_APP_ID=$(aws amplify list-apps --region $REGION --profile $PROFILE --query 'apps[?name==`tasks-3d-prod`].appId' --output text)
    AMPLIFY_DOMAIN=$(aws amplify list-apps --region $REGION --profile $PROFILE --query 'apps[?name==`tasks-3d-prod`].defaultDomain' --output text)
    API_URL=$(aws apigatewayv2 get-apis --region $REGION --profile $PROFILE --query 'Items[?Name==`tasks-3d-prod-api`].ApiEndpoint' --output text)
    
    echo "🌐 Frontend: https://main.$AMPLIFY_DOMAIN"
    curl -s https://main.$AMPLIFY_DOMAIN -o /dev/null -w "   Status: %{http_code}\n"
    
    echo ""
    echo "🔌 API: $API_URL"
    curl -s $API_URL/tasks -o /dev/null -w "   Status: %{http_code} (401 = OK)\n"
    
    echo ""
    aws lambda list-functions --region $REGION --profile $PROFILE --query 'Functions[?starts_with(FunctionName, `tasks-3d-prod`)].FunctionName' --output text | tr '\t' '\n' | sed 's/^/✅ /'
}

view_logs() {
    echo "📋 Lambda logs (last 5 minutes)..."
    echo ""
    aws logs tail /aws/lambda/tasks-3d-prod-tasks --region $REGION --profile $PROFILE --since 5m --format short | tail -30
}

terraform_init() {
    cd infra/terraform
    terraform init
    cd ../..
}

terraform_plan() {
    cd infra/terraform
    terraform plan
    cd ../..
}

terraform_apply() {
    cd infra/terraform
    terraform apply
    cd ../..
}

terraform_destroy() {
    echo "⚠️  This will destroy all AWS resources!"
    read -p "Are you sure? (yes/no): " confirm
    if [ "$confirm" = "yes" ]; then
        cd infra/terraform
        terraform destroy
        cd ../..
    fi
}

while true; do
    show_menu
    read -p "Select option: " option
    
    case $option in
        1)
            ./scripts/start-local.sh
            ;;
        2)
            echo "🛑 Stopping Docker..."
            sudo docker compose down
            echo "✅ Stopped"
            ;;
        3)
            sudo docker compose logs -f
            ;;
        4)
            deploy_backend
            echo ""
            deploy_frontend
            echo ""
            check_status
            ;;
        5)
            deploy_backend
            ;;
        6)
            deploy_frontend
            ;;
        7)
            terraform_init
            ;;
        8)
            terraform_plan
            ;;
        9)
            terraform_apply
            ;;
        10)
            terraform_destroy
            ;;
        11)
            check_status
            ;;
        12)
            view_logs
            ;;
        0)
            echo ""
            echo "👋 Bye!"
            exit 0
            ;;
        *)
            echo "❌ Invalid option"
            ;;
    esac
    
    echo ""
    read -p "Press ENTER to continue..."
done
