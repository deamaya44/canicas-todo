#!/bin/bash

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║          🚀 3D TASK MANAGER - QUICK START                    ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Choose your environment:"
echo ""
echo "  1) 🐳 Local Development (Docker)"
echo "  2) ☁️  AWS Production (Amplify + Lambda)"
echo ""
read -p "Select option [1-2]: " choice

case $choice in
    1)
        ./scripts/start-local.sh
        ;;
    2)
        ./scripts/menu.sh
        ;;
    *)
        echo "❌ Invalid option"
        exit 1
        ;;
esac
