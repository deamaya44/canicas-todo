#!/bin/bash

echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                              ║"
echo "║                    🧹 LIMPIAR HISTORIAL DE GIT                               ║"
echo "║                                                                              ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

echo "⚠️  ADVERTENCIA"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Este script eliminará TODO el historial de Git y creará un nuevo repositorio"
echo "con un solo commit limpio."
echo ""
echo "Esto es necesario para eliminar credenciales expuestas en commits anteriores."
echo ""
echo "¿Estás seguro de que quieres continuar? (escribe 'SI' para confirmar)"
read -p "> " CONFIRM

if [ "$CONFIRM" != "SI" ]; then
    echo ""
    echo "❌ Operación cancelada"
    exit 1
fi

echo ""
echo "📦 Creando backup del historial actual..."
cp -r .git .git.backup.$(date +%Y%m%d_%H%M%S)
echo "✅ Backup creado"

echo ""
echo "🗑️  Eliminando historial..."
rm -rf .git

echo ""
echo "🆕 Creando nuevo repositorio..."
git init -b main
git add -A
git commit -m "chore: initial clean commit

Complete 3D Task Manager project with:
- React Three.js frontend with Firebase authentication
- Node.js Lambda backend with DynamoDB
- Terraform infrastructure as code
- Complete CI/CD pipeline with AWS CodePipeline
- Interactive setup scripts
- Comprehensive documentation

Security:
- All credentials in AWS SSM Parameter Store
- No hardcoded secrets
- No API keys in code
- No account IDs exposed
- Clean Git history

Structure:
- docs/ - Complete documentation
- scripts/ - Automation scripts
- frontend/ - React Three.js app
- backend/ - Node.js Lambda API
- infra/ - Terraform configs

Quick start: ./setup"

echo ""
echo "✅ Nuevo repositorio creado"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📤 SIGUIENTE PASO: Subir al repositorio remoto"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Ejecuta estos comandos:"
echo ""
echo "  git remote add origin git@github.com:deamaya44/canicas-todo.git"
echo "  git push -u origin main --force"
echo ""
echo "⚠️  IMPORTANTE: Esto sobrescribirá el historial remoto"
echo "   Todos los colaboradores deberán hacer un nuevo clone"
echo ""
echo "Si algo sale mal, puedes restaurar el backup:"
echo "  rm -rf .git"
echo "  mv .git.backup.* .git"
echo ""
