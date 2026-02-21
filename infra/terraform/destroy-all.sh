#!/bin/bash
set -e

cd "$(dirname "$0")"

echo "🗑️  Destroying all resources..."
terraform destroy -auto-approve

echo ""
echo "✅ All resources destroyed"
