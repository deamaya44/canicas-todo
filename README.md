# 🎯 3D Task Manager

A modern task management application with a 3D physics-based interface built with React Three.js, deployed on AWS with full CI/CD pipeline and Firebase Authentication.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![AWS](https://img.shields.io/badge/AWS-Cloud-orange.svg)
![React](https://img.shields.io/badge/React-18-blue.svg)
![Three.js](https://img.shields.io/badge/Three.js-3D-green.svg)
![Firebase](https://img.shields.io/badge/Firebase-Auth-yellow.svg)

## ✨ Features

- 🎮 **Interactive 3D Interface** - Physics-based marble interactions using React Three Fiber
- 🔐 **Firebase Authentication** - Secure Google Sign-In with Firebase
- 👤 **Multi-User Support** - Each user has isolated tasks (per-user data isolation)
- 📱 **Responsive Design** - Optimized for both desktop and mobile devices
- ☁️ **Serverless Backend** - AWS Lambda + API Gateway + DynamoDB
- 🚀 **Full CI/CD Pipeline** - Automated deployments with AWS CodePipeline
- 🔒 **Secure by Design** - All credentials in AWS SSM, no secrets in code
- 🌐 **Custom Domain** - SSL certificates with automatic DNS validation
- 🐳 **Docker Support** - Local development environment included
- 📜 **Interactive Scripts** - Easy setup and deployment with guided menus
- 💰 **Zero Cost** - Runs completely free on AWS Free Tier ($0.00/month)

## 🏗️ Architecture

### Infrastructure Overview

**56 AWS Resources Deployed via Terraform:**

- **Frontend:** Amplify App + Custom Domain + SSL
- **Backend:** API Gateway HTTP + Lambda Functions + DynamoDB
- **Security:** Firebase JWT Authorizer + IAM Roles + ACM Certificates
- **CI/CD:** CodeCommit + CodeBuild + CodePipeline + EventBridge
- **Storage:** S3 Artifacts + DynamoDB Table
- **Monitoring:** CloudWatch Logs + Metrics

### Request Flow

1. User authenticates with Firebase (Google OAuth)
2. Frontend sends requests to API Gateway with JWT token
3. Lambda Authorizer verifies token with Firebase Admin SDK
4. API Gateway routes to backend Lambda
5. Backend queries DynamoDB filtered by userId
6. Response returns only user's tasks

### Deployment

All infrastructure managed with Terraform using atomic modules:
- Modular design with reusable components
- Automatic imports for existing resources
- Local exec provisioners for Lambda packaging
- No manual configuration required

**Cost:** $0.00/month (AWS Free Tier)

## 🔐 Authentication Flow

1. User clicks "Sign in with Google" on frontend
2. Firebase handles OAuth flow and returns JWT token
3. Frontend stores token and includes it in API requests: `Authorization: Bearer <token>`
4. API Gateway invokes Lambda authorizer
5. Lambda authorizer verifies token with Firebase Admin SDK
6. If valid, authorizer returns IAM policy allowing access + user context
7. Backend Lambda receives `userId` from authorizer context
8. DynamoDB queries are filtered by `userId` using GSI (Global Secondary Index)
9. Each user only sees their own tasks

## 🚀 Quick Start

### Prerequisites

- AWS Account with CLI configured
- Firebase project with Google Sign-In enabled
- Terraform installed
- Node.js 18+ and npm

### Setup

```bash
# Clone repository
git clone https://github.com/deamaya44/canicas-todo.git
cd canicas-todo

# Configure AWS SSM Parameters (required)
aws ssm put-parameter --name "/tasks-3d/firebase/project_id" --value "YOUR_PROJECT_ID" --type String
aws ssm put-parameter --name "/tasks-3d/firebase/api_key" --value "YOUR_API_KEY" --type SecureString
# ... (see docs/SECRETS_MANAGEMENT.md for all parameters)

# Deploy infrastructure
cd infra/terraform
terraform init
terraform apply -auto-approve

# Deploy application code to CodeCommit
# (Pipeline will automatically build and deploy)
```

### Local Development

```bash
# Frontend
cd frontend
npm install
npm run dev

# Backend
cd backend
npm install
npm run dev
```

## 📁 Project Structure

```
.
├── frontend/              # React Three.js application
│   ├── src/
│   │   ├── components/   # React components
│   │   ├── api/          # API client (with Firebase token)
│   │   ├── firebase.js   # Firebase configuration
│   │   └── App.jsx       # Main app with auth
│   ├── buildspec.yml     # CodeBuild config
│   └── package.json
│
├── backend/              # Node.js Lambda API
│   ├── src/
│   │   ├── handlers/    # Request handlers (userId filtering)
│   │   └── utils/       # DynamoDB utilities (GSI queries)
│   ├── index.js         # Lambda entry point
│   ├── buildspec.yml    # CodeBuild config
│   └── package.json
│
├── infra/terraform/      # Infrastructure as Code
│   ├── modules/
│   │   └── api-backend/ # Lambda + DynamoDB + Authorizer
│   ├── lambda-authorizer/
│   │   └── index.js     # Firebase token verification
│   ├── *.tf            # Terraform configs
│   └── deploy.sh       # Deployment script
│
├── scripts/             # Automation scripts
│   ├── setup.sh        # Interactive menu (main entry point)
│   ├── configure-firebase.sh  # Firebase setup guide
│   ├── start-with-ssm.sh      # Start local with SSM
│   └── deploy-codecommit.sh   # Deploy to AWS
│
├── docs/                # Documentation
│   ├── SCRIPTS.md       # Scripts guide
│   ├── SECRETS_MANAGEMENT.md  # AWS SSM guide
│   ├── CONTRIBUTING.md  # Contribution guide
│   └── *.md            # Other docs
│
├── docker-compose.yml   # Local development
├── setup               # Quick access to setup.sh
└── README.md
```

## 🎮 Usage

### Desktop
- **Sign in** with your Google account
- **Hover** over a marble to see the task name
- **Click** to select a task
- Use the form to create new tasks
- Click **✕** to delete a task
- Your tasks are private - other users can't see them

### Mobile
- **Sign in** with your Google account
- **Tap** a marble to see the task name
- **Tap** again to select
- Use the **▲ Tareas** button to toggle the task list
- Your tasks are private - other users can't see them

## 🔧 Configuration

All configuration is stored in AWS SSM Parameter Store. No hardcoded values.

### Required SSM Parameters

```bash
/tasks-3d/firebase/project_id
/tasks-3d/firebase/api_key
/tasks-3d/firebase/auth_domain
/tasks-3d/firebase/storage_bucket
/tasks-3d/firebase/messaging_sender_id
/tasks-3d/firebase/app_id
/tasks-3d/cloudflare/api_token
/tasks-3d/cloudflare/zone_id
/tasks-3d/cloudflare/domain
```

See [docs/SECRETS_MANAGEMENT.md](docs/SECRETS_MANAGEMENT.md) for details.

### Terraform Configuration

All configuration in `locals.tf` - no `.tfvars` files needed.
Workspace-based environments: `terraform workspace select prod`

## 🔐 Security Features

- **Firebase Authentication**: Secure OAuth 2.0 flow with Google
- **Lambda Authorizer**: Verifies Firebase JWT tokens on every API request
- **IAM Policies**: Fine-grained access control with least privilege
- **Per-User Isolation**: DynamoDB GSI ensures users only access their own data
- **No Hardcoded Credentials**: All secrets in AWS SSM Parameter Store
- **Private S3 Buckets**: CloudFront OAC for secure content delivery
- **CORS Configuration**: Restricted to allowed origins only

## 📊 DynamoDB Schema

**Table Structure:**
- **Primary Key**: `taskId` (String) - Unique task identifier
- **Sort Key**: `userId` (String) - Firebase user ID
- **Attributes**: title, description, color, completed, timestamps

**Global Secondary Index:**
- **Name**: UserIdIndex
- **Partition Key**: userId
- **Purpose**: Efficient per-user queries

All queries filtered by userId for data isolation.

## 🚀 CI/CD Pipeline

**Automated Deployment:**
1. Push code to CodeCommit repository
2. EventBridge triggers CodePipeline on main branch
3. CodeBuild packages and deploys:
   - Backend: Lambda function update
   - Frontend: Amplify deployment

**Zero-downtime deployments** with automatic rollback on failure.

## 📚 Documentation

- [Architecture Diagram](docs/ARCHITECTURE.md) - Visual architecture with Mermaid
- [Cost Analysis](docs/COST_ANALYSIS.html) - Detailed cost breakdown and Free Tier usage
- [Scripts Guide](docs/SCRIPTS.md) - All available scripts and usage
- [Secrets Management](docs/SECRETS_MANAGEMENT.md) - AWS SSM Parameter Store guide
- [Contributing](docs/CONTRIBUTING.md) - How to contribute
- [Firebase Setup](docs/FIREBASE-SETUP.md) - Firebase configuration details
- [Local Development](docs/LOCAL_DEVELOPMENT.md) - Docker development guide
- [Security Plan](docs/SECURITY_PLAN.md) - Security best practices

## 🐛 Troubleshooting

### Authentication Issues
- Verify Firebase configuration in SSM Parameter Store
- Check Google Sign-In is enabled in Firebase Console
- Review browser console for errors

### API Errors
- Check Lambda authorizer CloudWatch logs
- Verify JWT token format in Authorization header
- Confirm Firebase project ID matches

### Tasks Not Loading
- Review backend Lambda CloudWatch logs
- Verify DynamoDB table and GSI exist
- Check IAM permissions for DynamoDB access

For detailed logs: AWS CloudWatch → Log Groups → `/aws/lambda/`

## 🤝 Contributing

Contributions are welcome! Please read [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) first.

## 🔒 Security

This project follows security best practices:

- ✅ **No hardcoded credentials** - All secrets in AWS SSM Parameter Store
- ✅ **Clean Git history** - No exposed credentials in commit history
- ✅ **Dynamic configuration** - Account IDs and domains from SSM
- ✅ **Firebase authentication** - Secure OAuth 2.0 flow with Google
- ✅ **Lambda authorizer** - JWT token verification on every request
- ✅ **Per-user isolation** - DynamoDB GSI ensures data privacy
- ✅ **IAM least privilege** - Fine-grained access control

For security concerns, see [docs/SECURITY_PLAN.md](docs/SECURITY_PLAN.md)

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [React Three Fiber](https://docs.pmnd.rs/react-three-fiber) - 3D rendering
- [Three.js](https://threejs.org/) - 3D library
- [Firebase](https://firebase.google.com/) - Authentication
- [AWS](https://aws.amazon.com/) - Cloud infrastructure
- [Terraform](https://www.terraform.io/) - Infrastructure as Code

## 📧 Contact

For questions or support, please open an issue on GitHub.

---

Made with ❤️ using React, Three.js, Firebase, and AWS
