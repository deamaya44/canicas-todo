#!/bin/bash
set -e

cd "$(dirname "$0")"

echo "🚀 Deploying infrastructure..."
terraform apply -auto-approve

echo ""
echo "✅ Deployment complete!"
terraform output
