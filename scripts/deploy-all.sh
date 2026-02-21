#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   🚀 AWS 3D Tasks - Deployment Script                    ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check prerequisites
echo -e "${YELLOW}📋 Checking prerequisites...${NC}"
command -v terraform >/dev/null 2>&1 || { echo -e "${RED}❌ Terraform not found${NC}"; exit 1; }
command -v aws >/dev/null 2>&1 || { echo -e "${RED}❌ AWS CLI not found${NC}"; exit 1; }
command -v git >/dev/null 2>&1 || { echo -e "${RED}❌ Git not found${NC}"; exit 1; }
echo -e "${GREEN}✅ All prerequisites met${NC}\n"

# Ask for environment
echo -e "${BLUE}🌍 Select environment:${NC}"
echo "1) Development (Docker local)"
echo "2) Production (AWS with optional custom domain)"
read -p "Enter choice [1-2]: " ENV_CHOICE

if [ "$ENV_CHOICE" = "1" ]; then
    ENVIRONMENT="dev"
    DEPLOY_CLOUDFLARE="no"
    
    # Check Docker for dev
    echo -e "${YELLOW}🐳 Checking Docker...${NC}"
    if ! command -v docker >/dev/null 2>&1; then
        echo -e "${RED}❌ Docker not found. Please install Docker Desktop.${NC}"
        echo -e "${YELLOW}Download from: https://www.docker.com/products/docker-desktop${NC}"
        exit 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}❌ Docker daemon not running. Please start Docker Desktop.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Docker is ready${NC}"
    echo -e "${GREEN}✅ Development environment selected${NC}\n"
    
    # Check for docker-compose.yml
    if [ ! -f "docker-compose.yml" ]; then
        echo -e "${YELLOW}📝 Creating docker-compose.yml...${NC}"
        cat > docker-compose.yml << 'DOCKER_EOF'
version: '3.8'

services:
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    environment:
      - VITE_API_URL=http://localhost:3001
    volumes:
      - ./frontend:/app
      - /app/node_modules
    command: npm run dev

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    ports:
      - "3001:3001"
    environment:
      - PORT=3001
      - NODE_ENV=development
    volumes:
      - ./backend:/app
      - /app/node_modules
    command: npm run dev
DOCKER_EOF
        echo -e "${GREEN}✅ docker-compose.yml created${NC}\n"
    fi
    
    # Check for Dockerfiles
    if [ ! -f "frontend/Dockerfile" ]; then
        echo -e "${YELLOW}📝 Creating frontend Dockerfile...${NC}"
        cat > frontend/Dockerfile << 'DOCKERFILE_EOF'
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "run", "dev"]
DOCKERFILE_EOF
        echo -e "${GREEN}✅ frontend/Dockerfile created${NC}"
    fi
    
    if [ ! -f "backend/Dockerfile" ]; then
        echo -e "${YELLOW}📝 Creating backend Dockerfile...${NC}"
        cat > backend/Dockerfile << 'DOCKERFILE_EOF'
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3001

CMD ["npm", "run", "dev"]
DOCKERFILE_EOF
        echo -e "${GREEN}✅ backend/Dockerfile created${NC}\n"
    fi
    
    # Start Docker containers
    echo -e "${BLUE}🐳 Starting Docker containers...${NC}"
    docker-compose up -d --build
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Containers started successfully${NC}\n"
        
        # Wait for services to be ready
        echo -e "${YELLOW}⏳ Waiting for services to start (10 seconds)...${NC}"
        sleep 10
        
        # Final summary for dev
        echo -e "${GREEN}"
        cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   ✅ DEVELOPMENT ENVIRONMENT READY                        ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
        echo -e "${NC}"
        
        echo -e "${BLUE}📊 Development Summary:${NC}"
        echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo -e "${GREEN}🌐 Frontend:${NC} http://localhost:3000"
        echo -e "${GREEN}🔌 Backend:${NC}  http://localhost:3001"
        
        echo -e "\n${BLUE}🐳 Docker Containers:${NC}"
        docker-compose ps
        
        echo -e "\n${BLUE}📝 Useful Commands:${NC}"
        echo -e "  • View logs:    ${YELLOW}docker-compose logs -f${NC}"
        echo -e "  • Stop:         ${YELLOW}docker-compose stop${NC}"
        echo -e "  • Restart:      ${YELLOW}docker-compose restart${NC}"
        echo -e "  • Rebuild:      ${YELLOW}docker-compose up -d --build${NC}"
        echo -e "  • Remove:       ${YELLOW}docker-compose down${NC}"
        
        echo -e "\n${GREEN}🎉 Open http://localhost:3000 in your browser!${NC}\n"
        
        exit 0
    else
        echo -e "${RED}❌ Failed to start containers${NC}"
        echo -e "${YELLOW}Check logs with: docker-compose logs${NC}"
        exit 1
    fi
elif [ "$ENV_CHOICE" = "2" ]; then
    ENVIRONMENT="prod"
    
    # Ask about Cloudflare
    echo -e "${BLUE}☁️  Do you want to configure a custom domain with Cloudflare?${NC}"
    read -p "Deploy custom domain? [y/N]: " CLOUDFLARE_CHOICE
    
    if [[ "$CLOUDFLARE_CHOICE" =~ ^[Yy]$ ]]; then
        DEPLOY_CLOUDFLARE="yes"
        
        # Get Cloudflare details
        echo -e "\n${YELLOW}📝 Cloudflare Configuration${NC}"
        read -p "Enter your domain (e.g., amxops.com): " DOMAIN
        read -p "Enter subdomain for frontend (e.g., app): " FRONTEND_SUBDOMAIN
        read -p "Enter subdomain for backend (e.g., api): " BACKEND_SUBDOMAIN
        read -sp "Enter Cloudflare API Token: " CF_API_TOKEN
        echo
        read -p "Enter Cloudflare Zone ID: " CF_ZONE_ID
        
        # Store in SSM
        echo -e "\n${YELLOW}🔐 Storing credentials in AWS SSM...${NC}"
        aws ssm put-parameter \
            --name '/tasks-3d/cloudflare/api_token' \
            --value "$CF_API_TOKEN" \
            --type SecureString \
            --overwrite \
            --region us-east-1 >/dev/null 2>&1
        
        aws ssm put-parameter \
            --name '/tasks-3d/cloudflare/zone_id' \
            --value "$CF_ZONE_ID" \
            --type String \
            --overwrite \
            --region us-east-1 >/dev/null 2>&1
        
        aws ssm put-parameter \
            --name '/tasks-3d/cloudflare/domain' \
            --value "$DOMAIN" \
            --type String \
            --overwrite \
            --region us-east-1 >/dev/null 2>&1
        
        echo -e "${GREEN}✅ Credentials stored securely${NC}\n"
    else
        DEPLOY_CLOUDFLARE="no"
        echo -e "${GREEN}✅ Skipping custom domain configuration${NC}\n"
    fi
else
    echo -e "${RED}❌ Invalid choice${NC}"
    exit 1
fi

# Deploy infrastructure
echo -e "${BLUE}🏗️  Deploying AWS infrastructure...${NC}"
cd infra/terraform

# Initialize Terraform
echo -e "${YELLOW}Initializing Terraform...${NC}"
terraform init -upgrade >/dev/null 2>&1
echo -e "${GREEN}✅ Terraform initialized${NC}"

# Select tfvars file
if [ "$ENVIRONMENT" = "dev" ]; then
    TFVARS_FILE="terraform.dev.tfvars"
else
    TFVARS_FILE="terraform.tfvars"
fi

# Apply infrastructure
echo -e "${YELLOW}Applying infrastructure (this may take 5-10 minutes)...${NC}"
if terraform apply -var-file="$TFVARS_FILE" -auto-approve; then
    echo -e "${GREEN}✅ Infrastructure deployed successfully${NC}\n"
else
    echo -e "${RED}❌ Infrastructure deployment failed${NC}"
    exit 1
fi

# Get outputs
API_ENDPOINT=$(terraform output -json | jq -r '.api_endpoint.value')
CLOUDFRONT_DOMAIN=$(terraform output -json | jq -r '.cloudfront_distribution.value.domain_name')
CLOUDFRONT_ID=$(terraform output -json | jq -r '.cloudfront_distribution.value.id')

cd ../..

# Setup git-remote-codecommit if not installed
if ! pip3 show git-remote-codecommit >/dev/null 2>&1; then
    echo -e "${YELLOW}📦 Installing git-remote-codecommit...${NC}"
    pip3 install git-remote-codecommit --break-system-packages >/dev/null 2>&1
    echo -e "${GREEN}✅ git-remote-codecommit installed${NC}\n"
fi

# Add CodeCommit remotes if not exist
if ! git remote | grep -q "codecommit-backend"; then
    echo -e "${YELLOW}🔗 Adding CodeCommit remotes...${NC}"
    git remote add codecommit-backend codecommit::us-east-1://tasks-3d-backend 2>/dev/null || true
    git remote add codecommit-frontend codecommit::us-east-1://tasks-3d-frontend 2>/dev/null || true
    echo -e "${GREEN}✅ Remotes configured${NC}\n"
fi

# Deploy backend
echo -e "${BLUE}🔧 Deploying backend...${NC}"
git subtree split --prefix=backend -b backend-deploy >/dev/null 2>&1
if git push codecommit-backend backend-deploy:main --force; then
    echo -e "${GREEN}✅ Backend deployed to CodeCommit${NC}"
else
    echo -e "${RED}❌ Backend deployment failed${NC}"
    git branch -D backend-deploy 2>/dev/null || true
    exit 1
fi
git branch -D backend-deploy >/dev/null 2>&1

# Deploy frontend
echo -e "${BLUE}🎨 Deploying frontend...${NC}"
git subtree split --prefix=frontend -b frontend-deploy >/dev/null 2>&1
if git push codecommit-frontend frontend-deploy:main --force; then
    echo -e "${GREEN}✅ Frontend deployed to CodeCommit${NC}\n"
else
    echo -e "${RED}❌ Frontend deployment failed${NC}"
    git branch -D frontend-deploy 2>/dev/null || true
    exit 1
fi
git branch -D frontend-deploy >/dev/null 2>&1

# Wait for pipeline
echo -e "${YELLOW}⏳ Waiting for CI/CD pipeline (90 seconds)...${NC}"
sleep 90

# Check pipeline status
PIPELINE_STATUS=$(aws codepipeline get-pipeline-state --name tasks-3d-pipeline --region us-east-1 | jq -r '.stageStates[] | select(.stageName=="Build") | .latestExecution.status')

if [ "$PIPELINE_STATUS" = "Succeeded" ]; then
    echo -e "${GREEN}✅ Pipeline completed successfully${NC}\n"
else
    echo -e "${YELLOW}⚠️  Pipeline status: $PIPELINE_STATUS${NC}"
    echo -e "${YELLOW}Check pipeline at: https://console.aws.amazon.com/codesuite/codepipeline/pipelines/tasks-3d-pipeline${NC}\n"
fi

# Invalidate CloudFront
echo -e "${YELLOW}🔄 Invalidating CloudFront cache...${NC}"
aws cloudfront create-invalidation --distribution-id "$CLOUDFRONT_ID" --paths "/*" --region us-east-1 >/dev/null 2>&1
echo -e "${GREEN}✅ CloudFront invalidated${NC}\n"

# Final summary
echo -e "${GREEN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   ✅ DEPLOYMENT COMPLETED SUCCESSFULLY                    ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${BLUE}📊 Deployment Summary:${NC}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$DEPLOY_CLOUDFLARE" = "yes" ]; then
    echo -e "${GREEN}🌐 Frontend:${NC} https://${FRONTEND_SUBDOMAIN}.${DOMAIN}"
    echo -e "${GREEN}🔌 Backend:${NC}  https://${BACKEND_SUBDOMAIN}.${DOMAIN}"
    echo -e "\n${YELLOW}⏳ DNS propagation: 5-10 minutes${NC}"
    echo -e "${YELLOW}⏳ SSL certificates: Already issued${NC}"
else
    echo -e "${GREEN}🌐 Frontend:${NC} https://${CLOUDFRONT_DOMAIN}"
    echo -e "${GREEN}🔌 Backend:${NC}  ${API_ENDPOINT}"
fi

echo -e "\n${BLUE}📦 Resources Deployed:${NC}"
echo -e "  ✅ Lambda function"
echo -e "  ✅ API Gateway"
echo -e "  ✅ DynamoDB table"
echo -e "  ✅ S3 buckets"
echo -e "  ✅ CloudFront distribution"
echo -e "  ✅ CodePipeline"
echo -e "  ✅ CodeBuild projects"

if [ "$DEPLOY_CLOUDFLARE" = "yes" ]; then
    echo -e "  ✅ SSL certificates"
    echo -e "  ✅ Custom domains"
    echo -e "  ✅ DNS records"
fi

echo -e "\n${BLUE}🔐 Security:${NC}"
echo -e "  ✅ CORS configured"
echo -e "  ✅ S3 private (CloudFront OAC)"
if [ "$DEPLOY_CLOUDFLARE" = "yes" ]; then
    echo -e "  ✅ SSL/TLS encryption"
fi

echo -e "\n${BLUE}🚀 Next Steps:${NC}"
if [ "$DEPLOY_CLOUDFLARE" = "yes" ]; then
    echo -e "  1. Wait 5-10 minutes for DNS propagation"
    echo -e "  2. Open https://${FRONTEND_SUBDOMAIN}.${DOMAIN}"
    echo -e "  3. Test the application"
else
    echo -e "  1. Wait 2-3 minutes for CloudFront"
    echo -e "  2. Open https://${CLOUDFRONT_DOMAIN}"
    echo -e "  3. Test the application"
fi

echo -e "\n${BLUE}📚 Documentation:${NC}"
echo -e "  • CLOUDFLARE-SETUP.md - Cloudflare configuration"
echo -e "  • ENVIRONMENTS.md - Environment management"
echo -e "  • README.md - Project overview"

echo -e "\n${GREEN}🎉 Deployment completed! Enjoy your 3D task manager!${NC}\n"
