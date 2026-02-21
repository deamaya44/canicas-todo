#!/bin/bash
# Script para migrar parámetros SSM a cuenta nueva
# Ejecutar cuando los permisos estén activos

aws ssm put-parameter --name '/tasks-3d/cloudflare/api_token' --value 'DKtoh3EZBRKpZWLcX3FTr_VVLou2e-9KdJ2rzp8c' --type SecureString --region us-east-1 --profile querisa --overwrite
aws ssm put-parameter --name '/tasks-3d/cloudflare/zone_id' --value '233dafb74897fb34ad0a4a82236d5dfb' --type String --region us-east-1 --profile querisa --overwrite
aws ssm put-parameter --name '/tasks-3d/cloudflare/domain' --value 'amxops.com' --type String --region us-east-1 --profile querisa --overwrite
aws ssm put-parameter --name '/tasks-3d/firebase/project_id' --value 'canicas-todo' --type String --region us-east-1 --profile querisa --overwrite
aws ssm put-parameter --name '/tasks-3d/firebase/api_key' --value 'AIzaSyAoc0VZiQpnH4CypLy-btlOV_NuUb4Wjrc' --type String --region us-east-1 --profile querisa --overwrite
aws ssm put-parameter --name '/tasks-3d/firebase/auth_domain' --value 'canicas-todo.firebaseapp.com' --type String --region us-east-1 --profile querisa --overwrite
aws ssm put-parameter --name '/tasks-3d/firebase/storage_bucket' --value 'canicas-todo.firebasestorage.app' --type String --region us-east-1 --profile querisa --overwrite
aws ssm put-parameter --name '/tasks-3d/firebase/messaging_sender_id' --value '923196723085' --type String --region us-east-1 --profile querisa --overwrite
aws ssm put-parameter --name '/tasks-3d/firebase/app_id' --value '1:923196723085:web:b15c809433124d10e5f7c4' --type String --region us-east-1 --profile querisa --overwrite

echo "✅ Todos los parámetros migrados exitosamente"
