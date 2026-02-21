#!/bin/bash
set -e

cd "$(dirname "$0")"

if ! command -v npm &> /dev/null; then
    echo "Error: npm not found in PATH"
    exit 1
fi

if ! command -v zip &> /dev/null; then
    echo "Error: zip not found in PATH"
    exit 1
fi

echo "Installing dependencies..."
npm install --production

echo "Creating deployment package..."
zip -r ../infra/terraform/backend.zip . -x "*.git*" "*.sh" "node_modules/.cache/*" "scripts/*" "server.js"

echo "✅ Backend packaged successfully"
