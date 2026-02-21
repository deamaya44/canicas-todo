# AWS Amplify Hosting Module (Manual Deployment)

Módulo de Terraform para desplegar aplicaciones frontend con AWS Amplify Hosting usando **manual deployment** desde CodePipeline.

## Características

- ✅ Manual deployment desde CodePipeline/CodeBuild
- ✅ Integración con CodeCommit
- ✅ Dominio personalizado con SSL
- ✅ SPA routing (Single Page Application)
- ✅ CDN global incluido
- ✅ Free Tier: 15 GB hosting + 15 GB transferencia/mes

## Arquitectura

```
CodeCommit → CodePipeline → CodeBuild (npm run build) → Amplify CLI deploy → Amplify Hosting
```

## Uso

### 1. Crear la app Amplify

```hcl
module "amplify_frontend" {
  source = "git::https://github.com/deamaya44/aws_modules.git//modules/amplify?ref=main"

  app_name     = "my-app-prod"
  branch_name  = "main"

  environment_variables = {
    VITE_API_URL = "https://api.example.com"
  }

  custom_domain    = "example.com"
  subdomain_prefix = "app"

  common_tags = {
    Environment = "prod"
    Project     = "my-project"
  }
}
```

### 2. Buildspec para CodeBuild

```yaml
version: 0.2

phases:
  install:
    runtime-versions:
      nodejs: 18
    commands:
      - npm install -g @aws-amplify/cli
      
  pre_build:
    commands:
      - npm ci
      
  build:
    commands:
      - npm run build
      
  post_build:
    commands:
      - amplify deploy --appId $AMPLIFY_APP_ID --branchName $BRANCH_NAME --yes

artifacts:
  files:
    - '**/*'
  base-directory: dist
```

### 3. Variables de entorno en CodeBuild

```hcl
environment_variables = {
  AMPLIFY_APP_ID = module.amplify_frontend.app_id
  BRANCH_NAME    = "main"
  VITE_API_URL   = "https://api.example.com"
}
```

## Variables

| Variable | Descripción | Tipo | Default | Requerido |
|----------|-------------|------|---------|-----------|
| `app_name` | Nombre de la app | string | - | Sí |
| `branch_name` | Nombre de la rama | string | `main` | No |
| `build_spec` | Build spec personalizado | string | `""` | No |
| `environment_variables` | Variables de entorno | map(string) | `{}` | No |
| `custom_domain` | Dominio personalizado | string | `""` | No |
| `subdomain_prefix` | Prefijo del subdominio | string | `""` | No |
| `common_tags` | Tags comunes | map(string) | `{}` | No |

## Outputs

| Output | Descripción |
|--------|-------------|
| `app_id` | ID de la app Amplify (usar en CodeBuild) |
| `app_arn` | ARN de la app |
| `default_domain` | Dominio por defecto (.amplifyapp.com) |
| `branch_url` | URL de la rama desplegada |
| `custom_domain` | URL del dominio personalizado |

## Permisos IAM para CodeBuild

El rol de CodeBuild necesita:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "amplify:CreateDeployment",
        "amplify:StartDeployment",
        "amplify:GetJob"
      ],
      "Resource": "arn:aws:amplify:*:*:apps/*/branches/*/deployments/*"
    }
  ]
}
```

## Ejemplo Completo

```hcl
# 1. Crear Amplify App
module "amplify_app" {
  source = "git::https://github.com/deamaya44/aws_modules.git//modules/amplify?ref=main"

  app_name    = "tasks-3d-prod"
  branch_name = "main"

  environment_variables = {
    VITE_API_URL = "https://api.amxops.com"
  }

  custom_domain    = "amxops.com"
  subdomain_prefix = "app"

  common_tags = {
    Environment = "prod"
    Project     = "tasks-3d"
  }
}

# 2. CodeBuild con deploy a Amplify
module "codebuild_frontend" {
  source = "git::https://github.com/deamaya44/aws_modules.git//modules/codebuild?ref=main"

  project_name = "frontend-build"
  buildspec    = "frontend/buildspec.yml"

  environment_variables = {
    AMPLIFY_APP_ID = module.amplify_app.app_id
    BRANCH_NAME    = "main"
    VITE_API_URL   = "https://api.amxops.com"
  }

  # Permisos adicionales para Amplify
  additional_policies = [
    {
      actions = [
        "amplify:CreateDeployment",
        "amplify:StartDeployment",
        "amplify:GetJob"
      ]
      resources = ["${module.amplify_app.app_arn}/*"]
    }
  ]
}

output "app_url" {
  value = module.amplify_app.branch_url
}
```

## Costos

**Free Tier (siempre):**
- 15 GB almacenamiento
- 15 GB transferencia/mes
- Requests ilimitadas

**Después del Free Tier:**
- Hosting: $0.15/GB transferencia
- Almacenamiento: $0.023/GB/mes

**Nota**: No se cobra por build minutes en manual deployment.

## Flujo de Deployment

1. Push a CodeCommit
2. CodePipeline detecta cambio
3. CodeBuild ejecuta:
   - `npm ci`
   - `npm run build`
   - `amplify deploy --appId xxx --branchName main`
4. Amplify publica el contenido
5. Disponible en `https://main.xxxxx.amplifyapp.com`

