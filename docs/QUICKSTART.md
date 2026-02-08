# 🚀 Quick Start Guide for Contributors

## No Firebase Account Needed!

This project uses **Firebase Auth Emulator** for local development. You don't need a Firebase account or any credentials!

## 1. Clone and Start

```bash
git clone https://github.com/deamaya44/canicas-todo.git
cd canicas-todo
docker-compose up
```

Wait ~30 seconds for all services to start.

## 2. Open the App

- **App**: http://localhost:3000
- **Emulator UI**: http://localhost:4000
- **Backend API**: http://localhost:3001

## 3. Sign In

1. Click "Sign in with Google"
2. Enter **ANY email**: `test@example.com`, `user1@test.com`, etc.
3. Enter **ANY password**: `password123`, `test`, anything!
4. You're signed in! 🎉

## 4. Test Multi-User Isolation

### User 1
```bash
# 1. Sign in as user1@test.com
# 2. Create tasks: "Buy milk", "Walk dog"
# 3. Sign out
```

### User 2
```bash
# 1. Sign in as user2@test.com
# 2. You DON'T see user1's tasks ✅
# 3. Create your own tasks: "Read book"
# 4. Sign out
```

### User 1 Again
```bash
# 1. Sign in as user1@test.com
# 2. You still see "Buy milk", "Walk dog" ✅
# 3. You DON'T see user2's tasks ✅
```

## 5. Emulator UI

Visit http://localhost:4000 to:
- See all registered users
- View JWT tokens
- Clear emulator data
- Inspect auth state

## 6. Stop Services

```bash
docker-compose down
```

## How It Works

1. **Firebase Emulator** (port 9099) accepts any email/password
2. **Emulator** generates valid JWT tokens
3. **Frontend** sends token to backend: `Authorization: Bearer <token>`
4. **Backend** extracts `userId` from token
5. **DynamoDB** stores tasks with `userId`
6. **Each user** only sees their own tasks

## Architecture

```
┌─────────────────┐
│  Frontend       │ http://localhost:3000
│  (React + 3D)   │
└────────┬────────┘
         │
         ├──────────────────┐
         │                  │
         ▼                  ▼
┌─────────────────┐  ┌─────────────────┐
│ Firebase Auth   │  │  Backend API    │
│   Emulator      │  │  (Express)      │
│  port 9099      │  │  port 3001      │
└─────────────────┘  └────────┬────────┘
                              │
                              ▼
                     ┌─────────────────┐
                     │  DynamoDB       │
                     │  Local          │
                     │  port 8000      │
                     └─────────────────┘
```

## Troubleshooting

### Emulator not starting?
```bash
docker logs tasks-firebase-emulator
```

### Backend not responding?
```bash
docker logs tasks-backend
curl http://localhost:3001/tasks
```

### Frontend not loading?
```bash
docker logs tasks-frontend
```

### Reset everything
```bash
docker-compose down -v
docker-compose up
```

## Need Help?

Open an issue on GitHub: https://github.com/deamaya44/canicas-todo/issues

---

Made with ❤️ using React, Three.js, Firebase Emulator, and AWS
