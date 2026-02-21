#!/bin/bash

# Terraform Workspace Deployment Script
# Usage: ./deploy.sh [dev|prod] [plan|apply|destroy]

set -e

ENVIRONMENT=${1:-prod}
ACTION=${2:-plan}

echo "🚀 Deploying to: $ENVIRONMENT"
echo "📋 Action: $ACTION"
echo ""

# Initialize if needed
if [ ! -d ".terraform" ]; then
  echo "📦 Initializing Terraform..."
  terraform init
fi

# Create workspace if it doesn't exist
if ! terraform workspace list | grep -q "$ENVIRONMENT"; then
  echo "🌳 Creating workspace: $ENVIRONMENT"
  terraform workspace new "$ENVIRONMENT"
else
  echo "🌳 Switching to workspace: $ENVIRONMENT"
  terraform workspace select "$ENVIRONMENT"
fi

# Show current workspace
echo ""
echo "✅ Current workspace: $(terraform workspace show)"
echo ""

# Execute action
case $ACTION in
  plan)
    terraform plan
    ;;
  apply)
    terraform apply
    ;;
  destroy)
    terraform destroy
    ;;
  *)
    echo "❌ Invalid action: $ACTION"
    echo "Valid actions: plan, apply, destroy"
    exit 1
    ;;
esac
