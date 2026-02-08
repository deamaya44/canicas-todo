# 📜 Scripts Guide

## 🚀 Master Script

### `setup.sh` - Interactive Menu (RECOMMENDED)
```bash
./setup.sh
```

Interactive menu with all options:
- Configure Firebase
- Start/stop local environment
- Deploy to AWS (dev/prod)
- View service status
- View Docker logs

**Use this for everything!** It calls all other scripts.

---

## 🔧 Development Scripts

### `configure-firebase.sh` - Firebase Setup Guide
```bash
./configure-firebase.sh
```

Interactive guide to:
1. Create Firebase project
2. Enable Google Sign-In
3. Register web app
4. Save credentials to AWS SSM

**Run once** when setting up the project.

### `start-with-ssm.sh` - Start Local Environment
```bash
./start-with-ssm.sh
```

Starts Docker with Firebase credentials from AWS SSM:
- Checks AWS authentication
- Verifies Firebase credentials in SSM
- Offers to configure if not found
- Starts Docker Compose

**Run this** to start developing locally.

### `start-docker.sh` - Start Docker (Legacy)
```bash
./start-docker.sh
```

Starts Docker without SSM (requires `.env.local`).
**Deprecated** - Use `start-with-ssm.sh` instead.

---

## ☁️ Deployment Scripts

### `deploy-codecommit.sh` - Deploy to AWS
```bash
./deploy-codecommit.sh dev   # Deploy to dev
./deploy-codecommit.sh prod  # Deploy to prod
```

Deploys code to AWS CodeCommit and triggers CI/CD pipeline.

### `deploy-all.sh` - Full Deployment
```bash
./deploy-all.sh
```

Deploys everything (infrastructure + code).

### `deploy-to-codecommit.sh` - Legacy Deploy
```bash
./deploy-to-codecommit.sh
```

Old deployment script. **Use `deploy-codecommit.sh` instead.**

---

## 📊 Quick Reference

| Task | Command |
|------|---------|
| **First time setup** | `./setup.sh` → Option 1 |
| **Start developing** | `./setup.sh` → Option 2 |
| **Stop services** | `./setup.sh` → Option 3 |
| **Deploy to dev** | `./setup.sh` → Option 4 |
| **Check status** | `./setup.sh` → Option 6 |

---

## 🔄 Typical Workflow

### First Time
```bash
# 1. Run setup
./setup.sh

# 2. Select option 1 (Configure Firebase)
# Follow the interactive guide

# 3. Select option 2 (Start local environment)
# Docker starts with Firebase credentials from SSM

# 4. Open http://localhost:3000
# Login with Google
```

### Daily Development
```bash
# Start
./setup.sh → Option 2

# Develop...

# Stop
./setup.sh → Option 3
```

### Deploy to AWS
```bash
./setup.sh → Option 4 (dev) or Option 5 (prod)
```

---

## 🗂️ Script Dependencies

```
setup.sh (master)
├── configure-firebase.sh
├── start-with-ssm.sh
│   └── configure-firebase.sh (if credentials not found)
├── deploy-codecommit.sh
└── docker-compose (via commands)
```

---

## 🧹 Cleanup Old Scripts

These scripts are **deprecated** and can be removed:
- `start-docker.sh` (use `start-with-ssm.sh`)
- `deploy-to-codecommit.sh` (use `deploy-codecommit.sh`)
- `deploy-all.sh` (use `setup.sh` menu)

---

## 💡 Tips

- **Always use `setup.sh`** - It's the easiest way
- **First time?** Run option 1 to configure Firebase
- **Need help?** Each script has `--help` or shows instructions
- **Check status** Use option 6 to see what's running
- **View logs** Use option 7 to debug issues

---

Made with ❤️ for easy development and deployment
