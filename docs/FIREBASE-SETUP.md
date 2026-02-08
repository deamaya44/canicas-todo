# Firebase Setup Guide

## 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `canicas-todo` (or your preferred name)
4. Disable Google Analytics (optional)
5. Click "Create project"

## 2. Enable Authentication

1. In Firebase Console, go to **Authentication**
2. Click "Get started"
3. Enable **Google** sign-in provider
4. Add authorized domains:
   - `dev.amxops.com`
   - `app.amxops.com`
   - `localhost`

## 3. Get Firebase Configuration

1. Go to **Project Settings** (gear icon)
2. Scroll to "Your apps"
3. Click web icon (</>) to add web app
4. Register app name: `Canicas Todo`
5. Copy the Firebase config object

## 4. Store Firebase Project ID in AWS SSM

```bash
# Get your Firebase Project ID from console
aws ssm put-parameter \
  --name "/tasks-3d/firebase/project_id" \
  --value "YOUR_FIREBASE_PROJECT_ID" \
  --type String \
  --region us-east-1
```

## 5. Deploy Infrastructure

```bash
cd infra/terraform
./deploy.sh dev apply
```

## 6. Frontend Integration

Install Firebase SDK:

```bash
cd frontend
npm install firebase
```

Create `src/firebase.js`:

```javascript
import { initializeApp } from 'firebase/app';
import { getAuth, GoogleAuthProvider } from 'firebase/auth';

const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_PROJECT_ID.appspot.com",
  messagingSenderId: "YOUR_SENDER_ID",
  appId: "YOUR_APP_ID"
};

const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const googleProvider = new GoogleAuthProvider();
```

## 7. Use Firebase Auth in Components

```javascript
import { signInWithPopup, signOut } from 'firebase/auth';
import { auth, googleProvider } from './firebase';

// Login
const handleLogin = async () => {
  try {
    const result = await signInWithPopup(auth, googleProvider);
    const token = await result.user.getIdToken();
    // Use token for API calls
  } catch (error) {
    console.error('Login error:', error);
  }
};

// Logout
const handleLogout = () => {
  signOut(auth);
};

// Get current user token for API calls
const getToken = async () => {
  const user = auth.currentUser;
  if (user) {
    return await user.getIdToken();
  }
  return null;
};
```

## 8. API Calls with Firebase Token

```javascript
const token = await getToken();

fetch('https://api-dev.amxops.com/tasks', {
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  }
});
```

## Architecture

```
User → Firebase Auth → JWT Token → API Gateway → Lambda Authorizer → Lambda → DynamoDB
                                         ↓
                                   Verifies Firebase Token
                                   Extracts userId
```

## Cost

**Firebase Auth: $0/month** (unlimited users)

No setup fees, no monthly fees, no per-user fees. Completely free forever.

---

## 9. Add Team Members to Firebase Project

### Add Collaborators

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Click **⚙️ Project Settings** (gear icon)
4. Go to **Users and permissions** tab
5. Click **Add member**
6. Enter email address of your friend
7. Select role:

### Available Roles

| Role | Permissions | Use Case |
|------|-------------|----------|
| **Viewer** | Read-only access | See metrics, can't change anything |
| **Editor** | Full access except billing | Can modify auth, database, deploy |
| **Owner** | Full access including billing | Complete control |

**Recommended for friends:**
- **Viewer** - If they just need to see metrics/users
- **Editor** - If they need to help with development

### Email Notifications

Firebase automatically sends email notifications for:
- ✅ New user signups (if enabled in Auth settings)
- ✅ Project changes by team members
- ✅ Quota warnings
- ✅ Security alerts

**Enable detailed notifications:**

1. Go to **Project Settings** → **Integrations**
2. Enable **Slack** or **Email** notifications
3. Configure alerts for:
   - Authentication events
   - Database changes
   - Security rules updates
   - Quota usage

### Monitor Team Activity

1. Go to **Project Settings** → **Audit logs**
2. See all changes made by team members
3. Filter by:
   - User email
   - Action type
   - Date range

**Note:** Audit logs are available in all Firebase projects for free.

---

## 10. Monitor Authentication Activity

### View Users

1. Go to **Authentication** → **Users** tab
2. See all registered users
3. Export user list (CSV)
4. Disable/delete users if needed

### Analytics (Optional)

1. Enable Google Analytics in project settings
2. Track:
   - Daily active users
   - Sign-in methods used
   - User retention
   - Geographic distribution

**Cost:** Google Analytics is free
