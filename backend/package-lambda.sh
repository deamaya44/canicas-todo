#!/bin/bash
# Script para empaquetar Lambda localmente

set -e

echo "📦 Empaquetando Lambda function..."

# Limpiar build anterior
rm -rf dist
rm -f lambda.zip

# Crear directorio dist
mkdir -p dist

# Instalar dependencias
echo "📥 Instalando dependencias..."
npm ci --production

# Copiar archivos
echo "📋 Copiando archivos..."
cp -r src dist/
cp -r node_modules dist/
cp index.js dist/
cp package.json dist/

# Crear zip
echo "🗜️  Creando archivo zip..."
cd dist
zip -r ../lambda.zip . -q
cd ..

# Limpiar
rm -rf dist

echo "✅ Lambda empaquetado: lambda.zip"
echo "📊 Tamaño: $(du -h lambda.zip | cut -f1)"
