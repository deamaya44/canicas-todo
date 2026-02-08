#!/bin/bash

echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                              ║"
echo "║                    🚀 SETUP - 3D TASK MANAGER                                ║"
echo "║                                                                              ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

# Función para mostrar menú
show_menu() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📋 MENÚ PRINCIPAL"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "🔧 DESARROLLO LOCAL:"
    echo "  1) Configurar Firebase (primera vez)"
    echo "  2) Iniciar entorno local (Docker + SSM)"
    echo "  3) Detener entorno local"
    echo ""
    echo "☁️  DESPLIEGUE AWS:"
    echo "  4) Desplegar a AWS (dev)"
    echo "  5) Desplegar a AWS (prod)"
    echo ""
    echo "📊 INFORMACIÓN:"
    echo "  6) Ver estado de servicios"
    echo "  7) Ver logs de Docker"
    echo ""
    echo "  0) Salir"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Función para configurar Firebase
configure_firebase() {
    echo ""
    echo "🔥 Configurando Firebase..."
    ./scripts/configure-firebase.sh
}

# Función para iniciar entorno local
start_local() {
    echo ""
    echo "🐳 Iniciando entorno local..."
    ./scripts/start-with-ssm.sh
}

# Función para detener entorno local
stop_local() {
    echo ""
    echo "🛑 Deteniendo entorno local..."
    docker-compose down
    echo "✅ Servicios detenidos"
}

# Función para desplegar a AWS
deploy_aws() {
    local env=$1
    echo ""
    echo "☁️  Desplegando a AWS ($env)..."
    ./scripts/deploy-codecommit.sh "$env"
}

# Función para ver estado
show_status() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📊 ESTADO DE SERVICIOS"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Docker
    if docker ps --format "table {{.Names}}\t{{.Status}}" | grep -q "tasks-"; then
        echo "🐳 Docker:"
        docker ps --format "  ✅ {{.Names}}\t{{.Status}}" | grep "tasks-"
    else
        echo "🐳 Docker: ❌ No hay servicios corriendo"
    fi
    
    echo ""
    
    # AWS
    if command -v aws &> /dev/null; then
        AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
        if [ -n "$AWS_ACCOUNT" ]; then
            echo "☁️  AWS:"
            echo "  ✅ Cuenta: $AWS_ACCOUNT"
            echo "  ✅ Región: $(aws configure get region)"
        else
            echo "☁️  AWS: ❌ No autenticado"
        fi
    else
        echo "☁️  AWS: ❌ AWS CLI no instalado"
    fi
    
    echo ""
    
    # Firebase en SSM
    if [ -n "$AWS_ACCOUNT" ]; then
        FIREBASE_PROJECT=$(aws ssm get-parameter --name "/tasks-3d/firebase/project_id" --query "Parameter.Value" --output text 2>/dev/null)
        if [ -n "$FIREBASE_PROJECT" ]; then
            echo "🔥 Firebase:"
            echo "  ✅ Configurado: $FIREBASE_PROJECT"
        else
            echo "🔥 Firebase: ❌ No configurado en SSM"
        fi
    fi
    
    echo ""
}

# Función para ver logs
show_logs() {
    echo ""
    echo "📋 Últimos logs de Docker..."
    echo ""
    docker-compose logs --tail=50
    echo ""
    echo "💡 Para ver logs en tiempo real: docker-compose logs -f"
}

# Loop principal
while true; do
    show_menu
    read -p "Selecciona una opción: " option
    
    case $option in
        1)
            configure_firebase
            read -p "Presiona ENTER para continuar..."
            ;;
        2)
            start_local
            read -p "Presiona ENTER para continuar..."
            ;;
        3)
            stop_local
            read -p "Presiona ENTER para continuar..."
            ;;
        4)
            deploy_aws "dev"
            read -p "Presiona ENTER para continuar..."
            ;;
        5)
            deploy_aws "prod"
            read -p "Presiona ENTER para continuar..."
            ;;
        6)
            show_status
            read -p "Presiona ENTER para continuar..."
            ;;
        7)
            show_logs
            ;;
        0)
            echo ""
            echo "👋 ¡Hasta luego!"
            echo ""
            exit 0
            ;;
        *)
            echo ""
            echo "❌ Opción inválida"
            read -p "Presiona ENTER para continuar..."
            ;;
    esac
    
    clear
done
