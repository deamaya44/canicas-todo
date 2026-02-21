#!/bin/bash
set -e

PROFILE="${AWS_PROFILE:-default}"
REGION="${AWS_REGION:-us-east-1}"

echo "🗑️  Destroying all AWS resources..."

cd "$(dirname "$0")"

# Run terraform destroy
terraform destroy -auto-approve

echo ""
echo "🧹 Cleaning up orphaned resources..."

# Delete CodeCommit repos if they still exist
for repo in tasks-3d-prod-backend tasks-3d-prod-frontend; do
    if aws codecommit get-repository --repository-name $repo --profile $PROFILE --region $REGION &>/dev/null; then
        echo "  → Deleting CodeCommit repo: $repo"
        aws codecommit delete-repository --repository-name $repo --profile $PROFILE --region $REGION || true
    fi
done

# Delete S3 bucket if it still exists
ACCOUNT_ID=$(aws sts get-caller-identity --profile $PROFILE --query Account --output text)
BUCKET="tasks-3d-prod-artifacts-$ACCOUNT_ID"
if aws s3api head-bucket --bucket $BUCKET --profile $PROFILE --region $REGION &>/dev/null; then
    echo "  → Emptying and deleting S3 bucket: $BUCKET"
    aws s3 rm s3://$BUCKET --recursive --profile $PROFILE --region $REGION || true
    aws s3api delete-bucket --bucket $BUCKET --profile $PROFILE --region $REGION || true
fi

# Delete DynamoDB table if it still exists
TABLE="tasks-3d-prod-tasks"
if aws dynamodb describe-table --table-name $TABLE --profile $PROFILE --region $REGION &>/dev/null; then
    echo "  → Deleting DynamoDB table: $TABLE"
    aws dynamodb delete-table --table-name $TABLE --profile $PROFILE --region $REGION || true
fi

# Delete Lambda functions if they still exist
for func in tasks-3d-prod-tasks tasks-3d-prod-firebase-authorizer; do
    if aws lambda get-function --function-name $func --profile $PROFILE --region $REGION &>/dev/null; then
        echo "  → Deleting Lambda function: $func"
        aws lambda delete-function --function-name $func --profile $PROFILE --region $REGION || true
    fi
done

# Delete CloudWatch log groups
for log_group in /aws/lambda/tasks-3d-prod-tasks /aws/lambda/tasks-3d-prod-firebase-authorizer; do
    if aws logs describe-log-groups --log-group-name-prefix $log_group --profile $PROFILE --region $REGION --query 'logGroups[0]' --output text &>/dev/null; then
        echo "  → Deleting CloudWatch log group: $log_group"
        aws logs delete-log-group --log-group-name $log_group --profile $PROFILE --region $REGION || true
    fi
done

# Delete IAM roles
for role in tasks-3d-prod-lambda-role tasks-3d-prod-authorizer-role; do
    if aws iam get-role --role-name $role --profile $PROFILE &>/dev/null; then
        echo "  → Detaching policies and deleting IAM role: $role"
        # Detach managed policies
        aws iam list-attached-role-policies --role-name $role --profile $PROFILE --query 'AttachedPolicies[].PolicyArn' --output text | xargs -n1 -I{} aws iam detach-role-policy --role-name $role --policy-arn {} --profile $PROFILE || true
        # Delete inline policies
        aws iam list-role-policies --role-name $role --profile $PROFILE --query 'PolicyNames[]' --output text | xargs -n1 -I{} aws iam delete-role-policy --role-name $role --policy-name {} --profile $PROFILE || true
        # Delete role
        aws iam delete-role --role-name $role --profile $PROFILE || true
    fi
done

# Delete IAM policy
POLICY_ARN="arn:aws:iam::$ACCOUNT_ID:policy/tasks-3d-lambda-policy"
if aws iam get-policy --policy-arn $POLICY_ARN --profile $PROFILE &>/dev/null; then
    echo "  → Deleting IAM policy: tasks-3d-lambda-policy"
    # Delete all policy versions except default
    aws iam list-policy-versions --policy-arn $POLICY_ARN --profile $PROFILE --query 'Versions[?!IsDefaultVersion].VersionId' --output text | xargs -n1 -I{} aws iam delete-policy-version --policy-arn $POLICY_ARN --version-id {} --profile $PROFILE || true
    # Delete policy
    aws iam delete-policy --policy-arn $POLICY_ARN --profile $PROFILE || true
fi

# Delete Amplify app
AMPLIFY_APP_ID=$(aws amplify list-apps --profile $PROFILE --region $REGION --query "apps[?name=='tasks-3d-prod'].appId" --output text 2>/dev/null || echo "")
if [ -n "$AMPLIFY_APP_ID" ]; then
    echo "  → Deleting Amplify app: $AMPLIFY_APP_ID"
    aws amplify delete-app --app-id $AMPLIFY_APP_ID --profile $PROFILE --region $REGION || true
fi

# Delete API Gateway
API_ID=$(aws apigatewayv2 get-apis --profile $PROFILE --region $REGION --query "Items[?Name=='tasks-3d-prod-api'].ApiId" --output text 2>/dev/null || echo "")
if [ -n "$API_ID" ]; then
    echo "  → Deleting API Gateway: $API_ID"
    aws apigatewayv2 delete-api --api-id $API_ID --profile $PROFILE --region $REGION || true
fi

# Delete ACM certificates
DOMAIN=$(aws ssm get-parameter --name /tasks-3d/cloudflare/domain --profile $PROFILE --region $REGION --query Parameter.Value --output text 2>/dev/null || echo "")
if [ -n "$DOMAIN" ]; then
    CERT_ARN=$(aws acm list-certificates --profile $PROFILE --region $REGION --query "CertificateSummaryList[?DomainName=='api.$DOMAIN'].CertificateArn" --output text 2>/dev/null || echo "")
    if [ -n "$CERT_ARN" ]; then
        echo "  → Deleting ACM certificate: $CERT_ARN"
        aws acm delete-certificate --certificate-arn $CERT_ARN --profile $PROFILE --region $REGION || true
    fi
fi

# Delete CodeBuild projects
for project in tasks-3d-prod-backend-build tasks-3d-prod-frontend-build; do
    if aws codebuild batch-get-projects --names $project --profile $PROFILE --region $REGION --query 'projects[0]' --output text &>/dev/null; then
        echo "  → Deleting CodeBuild project: $project"
        aws codebuild delete-project --name $project --profile $PROFILE --region $REGION || true
    fi
done

# Delete CodePipeline
PIPELINE="tasks-3d-prod-pipeline"
if aws codepipeline get-pipeline --name $PIPELINE --profile $PROFILE --region $REGION &>/dev/null; then
    echo "  → Deleting CodePipeline: $PIPELINE"
    aws codepipeline delete-pipeline --name $PIPELINE --profile $PROFILE --region $REGION || true
fi

# Delete EventBridge rules
for rule in tasks-3d-prod-pipeline-backend-trigger tasks-3d-prod-pipeline-frontend-trigger; do
    if aws events describe-rule --name $rule --profile $PROFILE --region $REGION &>/dev/null; then
        echo "  → Removing targets and deleting EventBridge rule: $rule"
        # Remove all targets
        aws events list-targets-by-rule --rule $rule --profile $PROFILE --region $REGION --query 'Targets[].Id' --output text | xargs -n1 -I{} aws events remove-targets --rule $rule --ids {} --profile $PROFILE --region $REGION || true
        # Delete rule
        aws events delete-rule --name $rule --profile $PROFILE --region $REGION || true
    fi
done

echo ""
echo "✅ Cleanup complete - all resources destroyed"
