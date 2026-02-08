#!/bin/bash

echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                              ║"
echo "║                    🔥 CONFIGURACIÓN DE FIREBASE                              ║"
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

echo "✅ Autenticado en AWS"
echo "   Cuenta: $AWS_ACCOUNT"
echo "   Región: $(aws configure get region)"
echo ""

# Guía paso a paso
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 PASO 1: Crear proyecto en Firebase"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Abre: https://console.firebase.google.com/"
echo "2. Click en 'Agregar proyecto' o 'Add project'"
echo "3. Ingresa un nombre (ej: tasks-3d-app)"
echo "4. Desactiva Google Analytics (opcional)"
echo "5. Click en 'Crear proyecto'"
echo ""
read -p "Presiona ENTER cuando hayas creado el proyecto..."
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 PASO 2: Habilitar Google Sign-In"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. En tu proyecto, ve a 'Authentication' en el menú lateral"
echo "2. Click en 'Get started'"
echo "3. Click en 'Google' en la lista de proveedores"
echo "4. Activa el toggle 'Enable'"
echo "5. Selecciona un email de soporte"
echo "6. Click en 'Save'"
echo ""
read -p "Presiona ENTER cuando hayas habilitado Google Sign-In..."
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 PASO 3: Registrar aplicación web"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Ve a 'Project settings' (ícono de engranaje)"
echo "2. En la sección 'Your apps', click en el ícono '</>' (Web)"
echo "3. Ingresa un nombre (ej: tasks-3d-web)"
echo "4. NO marques 'Firebase Hosting'"
echo "5. Click en 'Register app'"
echo "6. Verás un código con firebaseConfig"
echo ""
read -p "Presiona ENTER cuando veas el código de configuración..."
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 PASO 4: Copiar credenciales de Firebase"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Copia y pega cada valor del firebaseConfig:"
echo ""

read -p "apiKey: " FIREBASE_API_KEY
read -p "authDomain: " FIREBASE_AUTH_DOMAIN
read -p "projectId: " FIREBASE_PROJECT_ID
read -p "storageBucket: " FIREBASE_STORAGE_BUCKET
read -p "messagingSenderId: " FIREBASE_MESSAGING_SENDER_ID
read -p "appId: " FIREBASE_APP_ID

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 PASO 5: Guardar en AWS SSM Parameter Store"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🔐 Guardando credenciales en AWS SSM..."

AWS_REGION=$(aws configure get region)

aws ssm put-parameter \
  --name "/tasks-3d/firebase/api_key" \
  --value "$FIREBASE_API_KEY" \
  --type String \
  --region "$AWS_REGION" \
  --overwrite > /dev/null

aws ssm put-parameter \
  --name "/tasks-3d/firebase/auth_domain" \
  --value "$FIREBASE_AUTH_DOMAIN" \
  --type String \
  --region "$AWS_REGION" \
  --overwrite > /dev/null

aws ssm put-parameter \
  --name "/tasks-3d/firebase/project_id" \
  --value "$FIREBASE_PROJECT_ID" \
  --type String \
  --region "$AWS_REGION" \
  --overwrite > /dev/null

aws ssm put-parameter \
  --name "/tasks-3d/firebase/storage_bucket" \
  --value "$FIREBASE_STORAGE_BUCKET" \
  --type String \
  --region "$AWS_REGION" \
  --overwrite > /dev/null

aws ssm put-parameter \
  --name "/tasks-3d/firebase/messaging_sender_id" \
  --value "$FIREBASE_MESSAGING_SENDER_ID" \
  --type String \
  --region "$AWS_REGION" \
  --overwrite > /dev/null

aws ssm put-parameter \
  --name "/tasks-3d/firebase/app_id" \
  --value "$FIREBASE_APP_ID" \
  --type String \
  --region "$AWS_REGION" \
  --overwrite > /dev/null

echo "✅ Credenciales guardadas en AWS SSM Parameter Store"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ CONFIGURACIÓN COMPLETA"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Parámetros guardados en:"
echo "  - /tasks-3d/firebase/api_key"
echo "  - /tasks-3d/firebase/auth_domain"
echo "  - /tasks-3d/firebase/project_id"
echo "  - /tasks-3d/firebase/storage_bucket"
echo "  - /tasks-3d/firebase/messaging_sender_id"
echo "  - /tasks-3d/firebase/app_id"
echo ""
echo "🚀 Ahora puedes ejecutar: ./start-with-ssm.sh"
echo ""
