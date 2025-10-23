# Hakbang App Architecture

## 📐 Application Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                       App Startup                            │
│                       (main.dart)                            │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────┐
        │ AuthenticationWrapper  │
        │  Check if token exists │
        └───────┬────────────────┘
                │
        ┌───────┴────────┐
        │                │
        ▼                ▼
   No Token         Has Token
        │                │
        ▼                ▼
┌──────────────┐  ┌──────────────┐
│ Login Screen │  │  Dashboard   │
└──────┬───────┘  └──────┬───────┘
       │                 │
       │ Login Success   │ Logout
       └─────────────────┘
```

## 🏗️ Folder Structure

```
Frontend/
│
├── lib/
│   ├── main.dart                    ← App entry & authentication check
│   │
│   ├── models/                      ← Data structures
│   │   ├── user_model.dart         (id, username, email, role)
│   │   ├── career_model.dart       (id, title, description, salary)
│   │   ├── module_model.dart       (id, title, careerId, url)
│   │   └── assessment_model.dart   (id, questions[], answers)
│   │
│   ├── services/                    ← Business logic
│   │   ├── api_service.dart        ← All HTTP calls to backend
│   │   │   ├── register()
│   │   │   ├── login()
│   │   │   ├── getCareers()
│   │   │   ├── getModules()
│   │   │   ├── markModuleComplete()
│   │   │   └── submitAssessment()
│   │   │
│   │   └── storage_service.dart    ← Secure token storage
│   │       ├── saveAuthData()
│   │       ├── getToken()
│   │       ├── getRole()
│   │       ├── isLoggedIn()
│   │       └── clearAuthData()
│   │
│   ├── screens/                     ← UI pages
│   │   ├── login_screen.dart       (email, password inputs)
│   │   ├── register_screen.dart    (username, email, password, role)
│   │   └── dashboard_screen.dart   (welcome, role display, logout)
│   │
│   └── widgets/                     ← Reusable components (future)
│
├── pubspec.yaml                     ← Dependencies
├── README.md                        ← Project documentation
├── QUICK_START.md                   ← Setup guide
└── .github/
    └── copilot-instructions.md      ← AI coding guidelines
```

## 🔄 Authentication Flow

```
┌──────────────┐
│ User Opens   │
│     App      │
└──────┬───────┘
       │
       ▼
┌─────────────────────────┐
│ Check for stored token  │
│ (storage_service.dart)  │
└──────┬──────────────────┘
       │
   ┌───┴───┐
   │       │
   ▼       ▼
  YES      NO
   │       │
   │       ▼
   │   ┌──────────────┐
   │   │Login Screen  │
   │   └──────┬───────┘
   │          │
   │          │ User enters credentials
   │          ▼
   │   ┌─────────────────────┐
   │   │ POST /auth/login    │
   │   │ (api_service.dart)  │
   │   └──────┬──────────────┘
   │          │
   │          │ Success: Returns token + role
   │          ▼
   │   ┌─────────────────────────┐
   │   │ Save token & role       │
   │   │ (storage_service.dart)  │
   │   └──────┬──────────────────┘
   │          │
   └──────────┴───────┐
                      │
                      ▼
              ┌──────────────┐
              │  Dashboard   │
              │ Show user    │
              │   role       │
              └──────────────┘
```

## 📡 API Call Flow

```
┌──────────────┐
│ User Action  │
│ (Button tap) │
└──────┬───────┘
       │
       ▼
┌─────────────────┐
│ Screen calls    │
│ ApiService      │
│ method          │
└──────┬──────────┘
       │
       ▼
┌──────────────────────┐
│ Get auth token from  │
│ StorageService       │
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│ Add token to         │
│ Authorization header │
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│ HTTP Request to      │
│ Backend API          │
│ (localhost:3000)     │
└──────┬───────────────┘
       │
   ┌───┴────┐
   │        │
   ▼        ▼
Success   Error
   │        │
   │        ▼
   │   ┌──────────────┐
   │   │ Show SnackBar│
   │   │ with error   │
   │   └──────────────┘
   │
   ▼
┌──────────────┐
│ Parse JSON   │
│ to Model     │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Update UI    │
│ with data    │
└──────────────┘
```

## 🎭 User Role Paths

```
┌─────────────────┐
│ User Registers  │
└────────┬────────┘
         │
    ┌────┴─────┐
    │          │
    ▼          ▼
┌─────────┐  ┌──────────┐
│ Student │  │  Mentor  │
└────┬────┘  └─────┬────┘
     │             │
     │             │
     ▼             ▼
┌──────────────────────┐  ┌──────────────────────┐
│ STUDENT FEATURES:    │  │ MENTOR FEATURES:     │
│                      │  │                      │
│ • AI Career Quiz     │  │ • Mentor Dashboard   │
│ • Browse Careers     │  │ • View Students      │
│ • Learning Modules   │  │ • Answer Questions   │
│ • Track Progress     │  │ • Community Forum    │
│ • Take Assessments   │  │ • Guide Students     │
│ • View Certificates  │  │                      │
└──────────────────────┘  └──────────────────────┘
```

## 🔐 Security Architecture

```
┌────────────────────────────────────────┐
│          Flutter App (Frontend)        │
└────────────┬───────────────────────────┘
             │
             │ 1. User logs in
             ▼
┌────────────────────────────────────────┐
│   POST /api/auth/login                 │
│   Body: { email, password }            │
└────────────┬───────────────────────────┘
             │
             │ 2. Backend validates
             ▼
┌────────────────────────────────────────┐
│   Returns JWT Token + User Role        │
│   { token: "eyJhbG...", role: "..." }  │
└────────────┬───────────────────────────┘
             │
             │ 3. Save securely
             ▼
┌────────────────────────────────────────┐
│   flutter_secure_storage               │
│   (Encrypted on device)                │
│   • auth_token                         │
│   • user_role                          │
│   • user_id                            │
└────────────┬───────────────────────────┘
             │
             │ 4. For protected routes
             ▼
┌────────────────────────────────────────┐
│   Add to request headers:              │
│   Authorization: Bearer <token>        │
└────────────┬───────────────────────────┘
             │
             │ 5. Backend verifies token
             ▼
┌────────────────────────────────────────┐
│   Access Granted / Denied              │
└────────────────────────────────────────┘
```

## 📦 Data Models Relationships

```
┌──────────────┐
│    User      │
│────────────  │
│ id           │
│ username     │
│ email        │
│ role         │◄─────┐
└──────────────┘      │
                      │ has role
┌──────────────┐      │
│   Career     │      │
│────────────  │      │
│ id           │      │
│ title        │      │
│ description  │      │
│ salaryRange  │      │
└──────┬───────┘      │
       │              │
       │ has many     │
       │              │
       ▼              │
┌──────────────┐      │
│   Module     │      │
│────────────  │      │
│ id           │      │
│ title        │      │
│ careerId     │──────┘
│ contentURL   │
│ isCompleted  │
└──────┬───────┘
       │
       │ has one
       │
       ▼
┌──────────────────┐
│   Assessment     │
│────────────────  │
│ id               │
│ moduleId         │
│ questions[]      │
│  • questionText  │
│  • options[]     │
│  • correctOption │
└──────────────────┘
```

## 🎯 Current Implementation Status

```
✅ COMPLETED (Phase 1)
├── User Registration
├── User Login
├── Token Storage
├── Auto-login
├── Dashboard (Basic)
└── Logout

🔄 READY TO BUILD (Phase 2)
├── Career Exploration
├── Career Details
├── AI Career Quiz
├── Module Tracking
└── Assessments/Quizzes

📋 FUTURE (Phase 3)
├── Mentor Dashboard
├── Community Forum
├── Profile Management
└── Analytics
```

## 🛠️ Technology Stack

```
┌────────────────────────────────────┐
│         Frontend (Flutter)         │
├────────────────────────────────────┤
│ • Dart 3.x                         │
│ • Flutter 3.x                      │
│ • Material Design 3                │
│ • Provider (State Management)      │
│ • HTTP Package (API Calls)         │
│ • Flutter Secure Storage           │
└────────────┬───────────────────────┘
             │
             │ HTTP/JSON
             ▼
┌────────────────────────────────────┐
│       Backend (Node.js)            │
├────────────────────────────────────┤
│ • Express.js                       │
│ • MongoDB                          │
│ • JWT Authentication               │
│ • RESTful API                      │
└────────────────────────────────────┘
```

---

**This architecture ensures:**
- 🔒 **Security** - Encrypted token storage
- ⚡ **Performance** - Efficient API calls
- 🎨 **Maintainability** - Clean separation of concerns
- 📱 **Scalability** - Modular structure for easy expansion
