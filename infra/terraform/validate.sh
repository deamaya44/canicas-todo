#!/bin/bash
# Script de validación pre-deploy

set -e

echo "🔍 Validando configuración de Terraform..."

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para imprimir con color
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# 1. Verificar que terraform.tfvars existe
echo ""
echo "1. Verificando terraform.tfvars..."
if [ -f "terraform.tfvars" ]; then
    print_success "terraform.tfvars existe"
    
    # Verificar que tiene las variables requeridas
    if grep -q "project_name" terraform.tfvars && grep -q "owner" terraform.tfvars; then
        print_success "Variables requeridas encontradas"
    else
        print_error "Faltan variables requeridas (project_name, owner)"
        exit 1
    fi
else
    print_error "terraform.tfvars no existe"
    echo "   Ejecuta: cp terraform.tfvars.example terraform.tfvars"
    exit 1
fi

# 2. Verificar que backend.tf está configurado
echo ""
echo "2. Verificando backend.tf..."
if grep -q "your-terraform-state-bucket" backend.tf; then
    print_warning "backend.tf aún tiene el bucket por defecto"
    echo "   Actualiza el nombre del bucket en backend.tf"
    exit 1
else
    print_success "backend.tf configurado"
fi

# 3. Verificar AWS CLI
echo ""
echo "3. Verificando AWS CLI..."
if command -v aws &> /dev/null; then
    print_success "AWS CLI instalado"
    
    # Verificar credenciales
    if aws sts get-caller-identity &> /dev/null; then
        print_success "Credenciales AWS configuradas"
        ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
        echo "   Account ID: $ACCOUNT_ID"
    else
        print_error "Credenciales AWS no configuradas"
        exit 1
    fi
else
    print_error "AWS CLI no instalado"
    exit 1
fi

# 4. Verificar Terraform
echo ""
echo "4. Verificando Terraform..."
if command -v terraform &> /dev/null; then
    print_success "Terraform instalado"
    TERRAFORM_VERSION=$(terraform version -json | jq -r '.terraform_version')
    echo "   Versión: $TERRAFORM_VERSION"
    
    # Verificar versión mínima (1.0)
    if [ "$(printf '%s\n' "1.0" "$TERRAFORM_VERSION" | sort -V | head -n1)" = "1.0" ]; then
        print_success "Versión de Terraform compatible (>= 1.0)"
    else
        print_warning "Versión de Terraform antigua (< 1.0)"
    fi
else
    print_error "Terraform no instalado"
    exit 1
fi

# 5. Verificar que el bucket de state existe
echo ""
echo "5. Verificando bucket de Terraform state..."
BUCKET_NAME=$(grep 'bucket' backend.tf | grep -v '#' | awk -F'"' '{print $2}')
if aws s3 ls "s3://$BUCKET_NAME" &> /dev/null; then
    print_success "Bucket de state existe: $BUCKET_NAME"
else
    print_error "Bucket de state no existe: $BUCKET_NAME"
    echo "   Ejecuta: aws s3 mb s3://$BUCKET_NAME"
    exit 1
fi

# 6. Validar sintaxis de Terraform
echo ""
echo "6. Validando sintaxis de Terraform..."
if terraform fmt -check -recursive &> /dev/null; then
    print_success "Formato de código correcto"
else
    print_warning "Código necesita formateo"
    echo "   Ejecuta: terraform fmt -recursive"
fi

# 7. Inicializar Terraform si es necesario
echo ""
echo "7. Verificando inicialización de Terraform..."
if [ -d ".terraform" ]; then
    print_success "Terraform ya inicializado"
else
    print_warning "Terraform no inicializado"
    echo "   Ejecuta: terraform init"
fi

# 8. Validar configuración
echo ""
echo "8. Validando configuración de Terraform..."
if terraform validate &> /dev/null; then
    print_success "Configuración válida"
else
    print_error "Configuración inválida"
    terraform validate
    exit 1
fi

# Resumen
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_success "Todas las validaciones pasaron correctamente"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Próximos pasos:"
echo "  1. terraform plan    # Revisar cambios"
echo "  2. terraform apply   # Aplicar infraestructura"
echo ""
