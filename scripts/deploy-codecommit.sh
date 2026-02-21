#!/bin/bash

# Deploy to CodeCommit for specific environment
# Usage: ./deploy-codecommit.sh [dev|prod]

set -e

ENVIRONMENT=${1:-prod}

echo "🚀 Deploying to CodeCommit: $ENVIRONMENT"
echo ""

# Configure remotes
git remote add codecommit-backend-${ENVIRONMENT} codecommit::us-east-1://tasks-3d-${ENVIRONMENT}-backend 2>/dev/null || echo "Remote backend-${ENVIRONMENT} already exists"
git remote add codecommit-frontend-${ENVIRONMENT} codecommit::us-east-1://tasks-3d-${ENVIRONMENT}-frontend 2>/dev/null || echo "Remote frontend-${ENVIRONMENT} already exists"

# Deploy backend
echo "📝 Deploying backend to $ENVIRONMENT..."
git subtree split --prefix=backend -b backend-deploy-${ENVIRONMENT}
git push codecommit-backend-${ENVIRONMENT} backend-deploy-${ENVIRONMENT}:main --force
git branch -D backend-deploy-${ENVIRONMENT}
echo "✅ Backend deployed"

# Deploy frontend
echo "📝 Deploying frontend to $ENVIRONMENT..."
git subtree split --prefix=frontend -b frontend-deploy-${ENVIRONMENT}
git push codecommit-frontend-${ENVIRONMENT} frontend-deploy-${ENVIRONMENT}:main --force
git branch -D frontend-deploy-${ENVIRONMENT}
echo "✅ Frontend deployed"

echo ""
echo "🎉 Deployment to $ENVIRONMENT complete!"
echo ""
echo "📊 Check pipeline:"
echo "   aws codepipeline get-pipeline-state --name tasks-3d-${ENVIRONMENT}-pipeline --region us-east-1"
