#!/bin/bash

# Script para subir código a AWS CodeCommit y activar CI/CD
# Proyecto: tasks-3d
# Fecha: 2026-02-06

set -e  # Detener si hay errores

echo "🚀 Iniciando despliegue a AWS CodeCommit..."

# ============================================
# 1. INSTALAR GIT-REMOTE-CODECOMMIT
# ============================================
# Este helper permite usar git con CodeCommit usando credenciales de AWS CLI
echo "📦 Instalando git-remote-codecommit..."
pip3 install git-remote-codecommit --quiet

# ============================================
# 2. CONFIGURAR REPOSITORIOS REMOTOS
# ============================================
# Agregar los repositorios de CodeCommit como remotes
echo "🔗 Configurando repositorios remotos..."

# Agregar remote para backend
git remote add codecommit-backend codecommit::us-east-1://tasks-3d-backend || echo "Remote backend ya existe"

# Agregar remote para frontend  
git remote add codecommit-frontend codecommit::us-east-1://tasks-3d-frontend || echo "Remote frontend ya existe"

# ============================================
# 3. PREPARAR CÓDIGO BACKEND
# ============================================
echo "📝 Preparando código del backend..."

# Crear branch temporal solo con backend
git subtree split --prefix=backend -b backend-deploy

# ============================================
# 4. SUBIR BACKEND A CODECOMMIT
# ============================================
echo "⬆️  Subiendo backend a CodeCommit..."

# Push del backend al repositorio de CodeCommit
# Esto activará automáticamente el pipeline de CI/CD
git push codecommit-backend backend-deploy:main --force

echo "✅ Backend subido! El pipeline se activará automáticamente."

# ============================================
# 5. PREPARAR CÓDIGO FRONTEND
# ============================================
echo "📝 Preparando código del frontend..."

# Crear branch temporal solo con frontend
git subtree split --prefix=frontend -b frontend-deploy

# ============================================
# 6. SUBIR FRONTEND A CODECOMMIT
# ============================================
echo "⬆️  Subiendo frontend a CodeCommit..."

# Push del frontend al repositorio de CodeCommit
# Esto activará automáticamente el pipeline de CI/CD
git push codecommit-frontend frontend-deploy:main --force

echo "✅ Frontend subido! El pipeline se activará automáticamente."

# ============================================
# 7. LIMPIAR BRANCHES TEMPORALES
# ============================================
echo "🧹 Limpiando branches temporales..."
git branch -D backend-deploy frontend-deploy

# ============================================
# 8. VERIFICAR ESTADO DEL PIPELINE
# ============================================
echo ""
echo "🎉 ¡Despliegue iniciado!"
echo ""
echo "📊 Para ver el estado del pipeline:"
echo "   aws codepipeline get-pipeline-state --name tasks-3d-pipeline --region us-east-1"
echo ""
echo "🔍 Para ver los logs de CodeBuild:"
echo "   Backend:  aws codebuild list-builds-for-project --project-name tasks-3d-backend-build --region us-east-1"
echo "   Frontend: aws codebuild list-builds-for-project --project-name tasks-3d-frontend-build --region us-east-1"
echo ""
echo "🌐 Consola AWS:"
echo "   Pipeline:  https://console.aws.amazon.com/codesuite/codepipeline/pipelines/tasks-3d-pipeline/view"
echo "   CodeBuild: https://console.aws.amazon.com/codesuite/codebuild/projects"
echo ""
echo "⏱️  El despliegue tomará aproximadamente 5-10 minutos."
echo ""

# ============================================
# NOTAS IMPORTANTES
# ============================================
# - El pipeline se activa automáticamente con cada push a main
# - EventBridge detecta cambios en CodeCommit y dispara el pipeline
# - CodeBuild ejecuta los buildspec.yml de cada proyecto
# - Backend se despliega como Lambda + API Gateway
# - Frontend se despliega a S3 como sitio estático
# - Recibirás notificaciones por email (confirma la suscripción SNS)
