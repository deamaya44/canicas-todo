# 🐳 Local Development with Docker

## Quick Start

```bash
# Start all services
docker-compose up

# Access the application
# Frontend: http://localhost:3000
# Backend API: http://localhost:3001
# DynamoDB Admin: http://localhost:8000
```

## Development Mode

En modo desarrollo local:

### ✅ Funciona SIN Firebase Auth
- No necesitas configurar Firebase
- No necesitas Google Sign-In
- Usa un `userId` dummy: `local-dev-user`

### ✅ Funciona SIN Lambda Authorizer
- El backend detecta `NODE_ENV=development`
- Bypasea la validación de `userId` del authorizer
- Todas las tareas se guardan con el mismo usuario local

### ✅ DynamoDB Local
- Base de datos en memoria
- Se inicializa automáticamente con el script `init-db.js`
- Los datos se pierden al detener el contenedor

## Diferencias con Producción

| Feature | Local (Docker) | AWS (Producción) |
|---------|----------------|------------------|
| Auth | ❌ Deshabilitado | ✅ Firebase + Google |
| Authorizer | ❌ Bypass | ✅ Lambda con validación |
| Multi-user | ❌ Usuario único | ✅ Aislamiento por usuario |
| DynamoDB | 🐳 Local | ☁️ AWS DynamoDB |
| Origin validation | ❌ No | ✅ Sí |

## Estructura de Servicios

```
┌─────────────────┐
│   Frontend      │  http://localhost:3000
│   (React)       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Backend       │  http://localhost:3001
│   (Node.js)     │  NODE_ENV=development
└────────┬────────┘  DEV_USER_ID=local-dev-user
         │
         ▼
┌─────────────────┐
│  DynamoDB Local │  http://localhost:8000
│   (In-Memory)   │
└─────────────────┘
```

## Variables de Entorno

### Backend (docker-compose.yml)
```yaml
environment:
  - NODE_ENV=development          # Habilita modo dev
  - DEV_USER_ID=local-dev-user   # Usuario dummy
  - TABLE_NAME=tasks
  - DYNAMODB_ENDPOINT=http://dynamodb:8000
```

### Frontend (.env.local)
```bash
VITE_API_URL=http://localhost:3001
# No necesitas variables de Firebase para desarrollo local
```

## Comandos Útiles

```bash
# Ver logs
docker-compose logs -f backend
docker-compose logs -f frontend

# Reiniciar un servicio
docker-compose restart backend

# Reconstruir imágenes
docker-compose up --build

# Detener todo
docker-compose down

# Limpiar volúmenes (borra datos)
docker-compose down -v
```

## Testing Local

```bash
# Crear una tarea
curl -X POST http://localhost:3001/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Task","description":"Testing local"}'

# Listar tareas
curl http://localhost:3001/tasks

# Obtener una tarea
curl http://localhost:3001/tasks/{id}

# Actualizar tarea
curl -X PUT http://localhost:3001/tasks/{id} \
  -H "Content-Type: application/json" \
  -d '{"completed":true}'

# Eliminar tarea
curl -X DELETE http://localhost:3001/tasks/{id}
```

## Troubleshooting

### Backend no conecta a DynamoDB
```bash
# Verifica que DynamoDB esté corriendo
docker-compose ps dynamodb

# Reinicia el backend
docker-compose restart backend
```

### Frontend no carga
```bash
# Verifica la variable VITE_API_URL
docker-compose exec frontend env | grep VITE

# Reconstruye el frontend
docker-compose up --build frontend
```

### Tabla no existe en DynamoDB
```bash
# Ejecuta el script de inicialización manualmente
docker-compose exec backend node scripts/init-db.js
```

## Migrar a Producción

Cuando despliegues a AWS:

1. ✅ Firebase Auth se activa automáticamente
2. ✅ Lambda Authorizer valida tokens
3. ✅ Multi-user con aislamiento por userId
4. ✅ DynamoDB real con GSI
5. ✅ Origin validation habilitada

**No necesitas cambiar código** - el backend detecta automáticamente el entorno.

## Notas Importantes

⚠️ **Modo desarrollo es INSEGURO**:
- No usar en producción
- No exponer puerto 3001 públicamente
- Solo para desarrollo local

✅ **En AWS todo es seguro**:
- Firebase JWT validation
- Lambda Authorizer con origin check
- Per-user data isolation
- API Gateway throttling
