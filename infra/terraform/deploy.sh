#!/bin/bash
set -e

PROFILE="${AWS_PROFILE:-default}"
REGION="${AWS_REGION:-us-east-1}"

cd "$(dirname "$0")"

echo "🚀 Deploying infrastructure..."

# Step 1: Auto-import existing resources
echo ""
echo "📦 Step 1: Checking for existing resources..."
./auto-import.sh

# Step 2: Apply terraform
echo ""
echo "🏗️  Step 2: Applying Terraform configuration..."
terraform apply -auto-approve

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📋 Outputs:"
terraform output
