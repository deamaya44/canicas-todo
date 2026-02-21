#!/bin/bash
set -e

PROFILE="${AWS_PROFILE:-default}"
REGION="${AWS_REGION:-us-east-1}"

echo "🔍 Checking for existing resources to import..."

# Function to check and import resource
import_if_exists() {
    local resource_address=$1
    local resource_id=$2
    local check_command=$3
    
    if eval "$check_command" &>/dev/null; then
        echo "  ✓ Found: $resource_address"
        if ! terraform state show "$resource_address" &>/dev/null; then
            echo "    → Importing..."
            terraform import "$resource_address" "$resource_id" || true
        else
            echo "    → Already in state"
        fi
    fi
}

# CodeCommit repositories
import_if_exists \
    'module.codecommit["backend"].aws_codecommit_repository.this' \
    'tasks-3d-prod-backend' \
    "aws codecommit get-repository --repository-name tasks-3d-prod-backend --profile $PROFILE --region $REGION"

import_if_exists \
    'module.codecommit["frontend"].aws_codecommit_repository.this' \
    'tasks-3d-prod-frontend' \
    "aws codecommit get-repository --repository-name tasks-3d-prod-frontend --profile $PROFILE --region $REGION"

# S3 bucket
ACCOUNT_ID=$(aws sts get-caller-identity --profile $PROFILE --query Account --output text)
import_if_exists \
    'module.s3_buckets["artifacts"].aws_s3_bucket.this' \
    "tasks-3d-prod-artifacts-$ACCOUNT_ID" \
    "aws s3api head-bucket --bucket tasks-3d-prod-artifacts-$ACCOUNT_ID --profile $PROFILE --region $REGION"

# DynamoDB table
import_if_exists \
    'module.dynamodb["tasks"].aws_dynamodb_table.this' \
    'tasks-3d-prod-tasks' \
    "aws dynamodb describe-table --table-name tasks-3d-prod-tasks --profile $PROFILE --region $REGION"

# Lambda functions
import_if_exists \
    'module.lambda["backend"].aws_lambda_function.this' \
    'tasks-3d-prod-tasks' \
    "aws lambda get-function --function-name tasks-3d-prod-tasks --profile $PROFILE --region $REGION"

import_if_exists \
    'module.lambda["authorizer"].aws_lambda_function.this' \
    'tasks-3d-prod-firebase-authorizer' \
    "aws lambda get-function --function-name tasks-3d-prod-firebase-authorizer --profile $PROFILE --region $REGION"

# CloudWatch Log Groups
import_if_exists \
    'module.lambda["backend"].aws_cloudwatch_log_group.this[0]' \
    '/aws/lambda/tasks-3d-prod-tasks' \
    "aws logs describe-log-groups --log-group-name-prefix /aws/lambda/tasks-3d-prod-tasks --profile $PROFILE --region $REGION"

import_if_exists \
    'module.lambda["authorizer"].aws_cloudwatch_log_group.this[0]' \
    '/aws/lambda/tasks-3d-prod-firebase-authorizer' \
    "aws logs describe-log-groups --log-group-name-prefix /aws/lambda/tasks-3d-prod-firebase-authorizer --profile $PROFILE --region $REGION"

# IAM roles
import_if_exists \
    'module.iam_role_lambda["backend"].aws_iam_role.this' \
    'tasks-3d-prod-lambda-role' \
    "aws iam get-role --role-name tasks-3d-prod-lambda-role --profile $PROFILE"

import_if_exists \
    'module.iam_role_lambda["authorizer"].aws_iam_role.this' \
    'tasks-3d-prod-authorizer-role' \
    "aws iam get-role --role-name tasks-3d-prod-authorizer-role --profile $PROFILE"

# IAM policies
import_if_exists \
    'module.iam_policy_lambda["backend"].aws_iam_policy.this' \
    "arn:aws:iam::$ACCOUNT_ID:policy/tasks-3d-lambda-policy" \
    "aws iam get-policy --policy-arn arn:aws:iam::$ACCOUNT_ID:policy/tasks-3d-lambda-policy --profile $PROFILE"

# API Gateway
API_ID=$(aws apigatewayv2 get-apis --profile $PROFILE --region $REGION --query "Items[?Name=='tasks-3d-prod-api'].ApiId" --output text 2>/dev/null || echo "")
if [ -n "$API_ID" ]; then
    import_if_exists \
        'module.apigateway["main"].aws_apigatewayv2_api.this' \
        "$API_ID" \
        "aws apigatewayv2 get-api --api-id $API_ID --profile $PROFILE --region $REGION"
fi

# Amplify App
AMPLIFY_APP_ID=$(aws amplify list-apps --profile $PROFILE --region $REGION --query "apps[?name=='tasks-3d-prod'].appId" --output text 2>/dev/null || echo "")
if [ -n "$AMPLIFY_APP_ID" ]; then
    import_if_exists \
        'module.amplify["frontend"].aws_amplify_app.this' \
        "$AMPLIFY_APP_ID" \
        "aws amplify get-app --app-id $AMPLIFY_APP_ID --profile $PROFILE --region $REGION"
    
    import_if_exists \
        'module.amplify["frontend"].aws_amplify_branch.main' \
        "$AMPLIFY_APP_ID/main" \
        "aws amplify get-branch --app-id $AMPLIFY_APP_ID --branch-name main --profile $PROFILE --region $REGION"
    
    # Check for domain association
    DOMAIN=$(aws ssm get-parameter --name /tasks-3d/cloudflare/domain --profile $PROFILE --region $REGION --query Parameter.Value --output text 2>/dev/null || echo "")
    if [ -n "$DOMAIN" ]; then
        import_if_exists \
            'module.amplify["frontend"].aws_amplify_domain_association.this[0]' \
            "$AMPLIFY_APP_ID/$DOMAIN" \
            "aws amplify get-domain-association --app-id $AMPLIFY_APP_ID --domain-name $DOMAIN --profile $PROFILE --region $REGION"
    fi
fi

# ACM Certificate
CERT_ARN=$(aws acm list-certificates --profile $PROFILE --region $REGION --query "CertificateSummaryList[?DomainName=='api.$DOMAIN'].CertificateArn" --output text 2>/dev/null || echo "")
if [ -n "$CERT_ARN" ]; then
    import_if_exists \
        'module.acm_certificate["backend"].aws_acm_certificate.this' \
        "$CERT_ARN" \
        "aws acm describe-certificate --certificate-arn $CERT_ARN --profile $PROFILE --region $REGION"
fi

echo ""
echo "✅ Import check complete"
