#!/bin/bash

echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                              ║"
echo "║                    🐳 INICIANDO ENTORNO DOCKER                               ║"
echo "║                                                                              ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

# Verificar AWS CLI
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI no está instalado"
    echo "   Instala desde: https://aws.amazon.com/cli/"
    exit 1
fi

# Verificar credenciales AWS
echo "🔍 Verificando credenciales de AWS..."
AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)

if [ -z "$AWS_ACCOUNT" ]; then
    echo "❌ No estás autenticado en AWS"
    echo "   Ejecuta: aws configure"
    exit 1
fi

AWS_REGION=$(aws configure get region)
echo "✅ Autenticado en AWS"
echo "   Cuenta: $AWS_ACCOUNT"
echo "   Región: $AWS_REGION"
echo ""

# Verificar si existen las credenciales de Firebase en SSM
echo "🔍 Verificando credenciales de Firebase en SSM..."
FIREBASE_PROJECT_ID=$(aws ssm get-parameter --name "/tasks-3d/firebase/project_id" --query "Parameter.Value" --output text --region "$AWS_REGION" 2>/dev/null)

if [ -z "$FIREBASE_PROJECT_ID" ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "❌ NO SE ENCONTRARON CREDENCIALES DE FIREBASE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "No se encontraron parámetros de Firebase en AWS SSM Parameter Store."
    echo ""
    echo "¿Deseas configurar Firebase ahora? (s/n)"
    read -p "> " CONFIGURE_NOW
    
    if [ "$CONFIGURE_NOW" = "s" ] || [ "$CONFIGURE_NOW" = "S" ]; then
        echo ""
        echo "🚀 Ejecutando configuración de Firebase..."
        ./configure-firebase.sh
        
        if [ $? -ne 0 ]; then
            echo "❌ Error en la configuración de Firebase"
            exit 1
        fi
        
        echo ""
        echo "✅ Configuración completada. Continuando con el inicio de Docker..."
        echo ""
    else
        echo ""
        echo "Para configurar Firebase más tarde, ejecuta:"
        echo "  ./configure-firebase.sh"
        echo ""
        exit 1
    fi
fi

echo "✅ Credenciales de Firebase encontradas"
echo "   Project ID: $FIREBASE_PROJECT_ID"
echo ""

echo "🔐 Obteniendo credenciales de AWS SSM Parameter Store..."

# Obtener parámetros de Firebase
export VITE_FIREBASE_API_KEY=$(aws ssm get-parameter --name "/tasks-3d/firebase/api_key" --query "Parameter.Value" --output text --region "$AWS_REGION")
export VITE_FIREBASE_AUTH_DOMAIN=$(aws ssm get-parameter --name "/tasks-3d/firebase/auth_domain" --query "Parameter.Value" --output text --region "$AWS_REGION")
export VITE_FIREBASE_PROJECT_ID=$(aws ssm get-parameter --name "/tasks-3d/firebase/project_id" --query "Parameter.Value" --output text --region "$AWS_REGION")
export VITE_FIREBASE_STORAGE_BUCKET=$(aws ssm get-parameter --name "/tasks-3d/firebase/storage_bucket" --query "Parameter.Value" --output text --region "$AWS_REGION")
export VITE_FIREBASE_MESSAGING_SENDER_ID=$(aws ssm get-parameter --name "/tasks-3d/firebase/messaging_sender_id" --query "Parameter.Value" --output text --region "$AWS_REGION")
export VITE_FIREBASE_APP_ID=$(aws ssm get-parameter --name "/tasks-3d/firebase/app_id" --query "Parameter.Value" --output text --region "$AWS_REGION")

echo "✅ Credenciales obtenidas"
echo ""
echo "🐳 Iniciando Docker con credenciales de SSM..."
docker-compose up -d

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ SERVICIOS INICIADOS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🌐 Frontend: http://localhost:3000"
echo "🔌 Backend:  http://localhost:3001"
echo "💾 DynamoDB: http://localhost:8000"
echo ""
echo "🔥 Firebase Project: $VITE_FIREBASE_PROJECT_ID"
echo ""
echo "🚀 Abre http://localhost:3000 y haz login con Google!"
echo ""
