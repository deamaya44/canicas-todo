# 📁 Repository Structure

```
canicas-todo/
│
├── 📄 README.md                 # Main project documentation
├── 📄 LICENSE                   # MIT License
├── 📄 docker-compose.yml        # Local development setup
├── 🚀 setup                     # Quick access script
│
├── 📂 frontend/                 # React Three.js Application
│   ├── src/
│   │   ├── components/         # React components
│   │   ├── api/                # API client
│   │   ├── firebase.js         # Firebase config
│   │   └── App.jsx             # Main app
│   ├── Dockerfile
│   ├── buildspec.yml           # AWS CodeBuild
│   └── package.json
│
├── 📂 backend/                  # Node.js Lambda API
│   ├── src/
│   │   ├── handlers/           # API handlers
│   │   └── utils/              # Utilities
│   ├── scripts/
│   │   └── init-db.js          # DynamoDB init
│   ├── index.js                # Lambda entry
│   ├── server.js               # Local server
│   ├── buildspec.yml           # AWS CodeBuild
│   └── package.json
│
├── 📂 infra/                    # Infrastructure as Code
│   └── terraform/
│       ├── modules/            # Terraform modules
│       ├── lambda-authorizer/  # Firebase auth
│       ├── *.tf                # Terraform configs
│       └── terraform.tfvars    # Variables
│
├── 📂 scripts/                  # Automation Scripts
│   ├── 📄 README.md            # Scripts guide
│   ├── 🚀 setup.sh             # Interactive menu (MAIN)
│   ├── 🔧 configure-firebase.sh # Firebase setup
│   ├── 🐳 start-with-ssm.sh    # Start local
│   ├── ☁️  deploy-codecommit.sh # Deploy to AWS
│   ├── 🐳 start-docker.sh      # Legacy start
│   └── ☁️  deploy-all.sh        # Full deploy
│
├── 📂 docs/                     # Documentation
│   ├── 📄 README.md            # Docs index
│   ├── 📘 SCRIPTS.md           # Scripts guide
│   ├── 📘 SECRETS_MANAGEMENT.md # AWS SSM guide
│   ├── 📘 FIREBASE-SETUP.md    # Firebase config
│   ├── 📘 QUICKSTART.md        # Quick start
│   ├── 📘 LOCAL_DEVELOPMENT.md # Docker guide
│   ├── 📘 CONTRIBUTING.md      # How to contribute
│   ├── 📘 SECURITY_PLAN.md     # Security best practices
│   ├── 📘 SECURITY_IMPROVEMENTS.md # Security enhancements
│   ├── 📘 COGNITO-VS-FIREBASE.md # Comparison
│   └── 📘 COGNITO-SETUP.md     # Cognito alternative
│
└── 📂 .archive/                 # Deprecated Files
    ├── 📄 README.md            # Archive notice
    ├── deploy-to-codecommit.sh # Old deploy script
    ├── firebase.json           # Old emulator config
    └── test-api.html           # Old test file
```

## 🎯 Quick Navigation

### For Users
- **Start here**: [README.md](README.md)
- **Quick setup**: Run `./setup`
- **Documentation**: [docs/](docs/)

### For Developers
- **Scripts**: [scripts/](scripts/)
- **Frontend**: [frontend/](frontend/)
- **Backend**: [backend/](backend/)
- **Infrastructure**: [infra/terraform/](infra/terraform/)

### For Contributors
- **Contributing guide**: [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md)
- **Local development**: [docs/LOCAL_DEVELOPMENT.md](docs/LOCAL_DEVELOPMENT.md)
- **Scripts guide**: [docs/SCRIPTS.md](docs/SCRIPTS.md)

## 📊 File Count

- **Documentation**: 11 files
- **Scripts**: 6 files
- **Source code**: Frontend + Backend
- **Infrastructure**: Terraform configs
- **Archived**: 3 deprecated files

## 🔍 Finding Things

| Looking for... | Go to... |
|----------------|----------|
| How to start | `./setup` or [README.md](README.md) |
| Scripts | [scripts/](scripts/) |
| Documentation | [docs/](docs/) |
| Frontend code | [frontend/src/](frontend/src/) |
| Backend code | [backend/src/](backend/src/) |
| Infrastructure | [infra/terraform/](infra/terraform/) |
| Old files | [.archive/](.archive/) |

---

**Clean, organized, and easy to navigate!** 🎉
