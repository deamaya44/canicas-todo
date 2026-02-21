#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [ -d "/tmp/node-v18.20.5-linux-x64/bin" ]; then
    export PATH="/tmp/node-v18.20.5-linux-x64/bin:$PATH"
fi

if ! command -v npm &> /dev/null; then
    echo "Error: npm not found in PATH"
    exit 1
fi

rm -rf node_modules package-lock.json
npm install --production --no-package-lock
cd ..
rm -f backend.zip
cd backend
zip -r ../backend.zip . -x "*.git*"
echo "✅ Backend packaged successfully"
