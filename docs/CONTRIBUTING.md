# 🤝 Contributing to 3D Task Manager

Thank you for your interest in contributing! This guide will help you set up the project locally.

## 🚀 Quick Start for Contributors

### Option 1: Local Development WITHOUT Firebase (Recommended)

If you just want to contribute to the code without setting up Firebase:

```bash
# 1. Clone the repo
git clone https://github.com/deamaya44/canicas-todo.git
cd canicas-todo

# 2. Start with Docker (no Firebase needed!)
docker-compose up

# 3. Access the app
# Frontend: http://localhost:3000
# Backend: http://localhost:3001
```

**No Firebase setup required!** The local environment works without authentication.

### Option 2: Full Setup WITH Firebase

If you want to test Firebase authentication:

1. **Create your own Firebase project** (free):
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project
   - Enable Google Sign-In in Authentication

2. **Configure environment variables**:
   ```bash
   # Copy the example file
   cp frontend/.env.example frontend/.env.local
   
   # Edit frontend/.env.local with your Firebase credentials
   # Get them from: Firebase Console → Project Settings → General
   ```

3. **Start the app**:
   ```bash
   docker-compose up
   ```

## 📁 Project Structure

```
.
├── frontend/          # React + Three.js app
├── backend/           # Node.js API
├── infra/terraform/   # AWS infrastructure (for maintainers only)
└── docker-compose.yml # Local development
```

## 🔐 Security Notes

### What's Safe to Commit:
- ✅ Code changes
- ✅ Documentation
- ✅ `.env.example` files
- ✅ Docker configuration

### What's NOT Safe to Commit:
- ❌ `.env.local` files
- ❌ Firebase credentials
- ❌ AWS credentials
- ❌ API keys or tokens

**These files are gitignored automatically.**

## 🧪 Testing Your Changes

### Frontend
```bash
cd frontend
npm install
npm run dev
```

### Backend
```bash
cd backend
npm install
npm start
```

### Full Stack (Docker)
```bash
docker-compose up --build
```

## 📝 Making a Pull Request

1. **Fork the repository**
2. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes**
4. **Test locally** with Docker
5. **Commit with clear messages**:
   ```bash
   git commit -m "feat: add awesome feature"
   ```
6. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```
7. **Open a Pull Request** on GitHub

## 🎯 What to Contribute

### Good First Issues:
- 🐛 Bug fixes
- 📝 Documentation improvements
- 🎨 UI/UX enhancements
- ♿ Accessibility improvements
- 🧪 Adding tests

### Areas Needing Help:
- Mobile responsiveness
- Performance optimizations
- 3D physics improvements
- Internationalization (i18n)
- Unit and integration tests

## 💬 Questions?

- Open an issue on GitHub
- Check existing issues and PRs
- Read the [README.md](README.md) for more details

## 📜 Code Style

- Use ESLint configuration provided
- Follow existing code patterns
- Write clear commit messages
- Add comments for complex logic

## 🙏 Thank You!

Every contribution helps make this project better. We appreciate your time and effort!

---

**Note for Maintainers**: AWS deployment requires additional credentials stored in AWS SSM Parameter Store. Contributors don't need AWS access for local development.
