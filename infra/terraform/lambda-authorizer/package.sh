#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Find node and npm
if [ -d "/tmp/node-v18.20.5-linux-x64/bin" ]; then
    export PATH="/tmp/node-v18.20.5-linux-x64/bin:$PATH"
fi

if ! command -v npm &> /dev/null; then
    echo "Error: npm not found in PATH"
    exit 1
fi

# Clean and install
rm -rf node_modules package-lock.json
npm install --production --no-package-lock

# Package
cd ..
rm -f lambda-authorizer.zip
cd lambda-authorizer
zip -r ../lambda-authorizer.zip . -x "*.git*"

echo "✅ Authorizer packaged successfully"
