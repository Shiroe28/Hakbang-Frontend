# Hakbang - Smart AI-Powered Career Tracker

A Flutter mobile application that helps students discover IT careers, follow learning paths, track their progress, and connect with mentors.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Node.js backend running at `http://localhost:3000`
- Android Studio or VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   cd Frontend
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Ensure backend is running**
   Make sure your Node.js backend is running at `http://localhost:3000/api`

4. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Features

### Current Features (Phase 1)
- ✅ User Registration (Student/Mentor)
- ✅ User Login with JWT Authentication
- ✅ Secure Token Storage
- ✅ Role-Based Dashboard
- ✅ Auto-login on app restart

### Coming Soon (Phase 2)
- 🔄 AI Career Recommendation Quiz
- 🔄 Career Exploration
- 🔄 Learning Module Tracking
- 🔄 Knowledge Assessments/Quizzes

### Future Features (Phase 3)
- 📋 Mentor Dashboard
- 💬 Community Forum
- 👤 Profile Management
- 📊 Progress Analytics

## 🏗️ Project Structure

```
lib/
├── main.dart                    # App entry point & authentication wrapper
├── models/                      # Data models
│   ├── user_model.dart         # User data structure
│   ├── career_model.dart       # Career path data
│   ├── module_model.dart       # Learning module data
│   └── assessment_model.dart   # Quiz/assessment data
├── services/                    # Business logic & API
│   ├── api_service.dart        # HTTP requests to backend
│   └── storage_service.dart    # Secure token storage
├── screens/                     # UI screens
│   ├── login_screen.dart       # Login page
│   ├── register_screen.dart    # Registration page
│   └── dashboard_screen.dart   # Main dashboard
└── widgets/                     # Reusable UI components
```

## 🔌 Backend API

The app connects to the following endpoints:

### Authentication
- `POST /api/auth/register` - Create new account
- `POST /api/auth/login` - Login user

### Public Content
- `GET /api/careers` - Get all IT career paths
- `GET /api/learning/modules` - Get learning modules
- `GET /api/learning/assessments/module/:id` - Get quiz

### Protected Routes (Requires Auth Token)
- `PUT /api/learning/modules/:id/progress` - Mark module complete
- `POST /api/learning/assessments/:id/submit` - Submit quiz
- `POST /api/ai/recommendations` - Get AI career suggestions

## 🔐 Authentication Flow

1. User registers or logs in
2. Backend returns JWT token and user role
3. Token stored securely using `flutter_secure_storage`
4. Token included in `Authorization` header for protected routes
5. Auto-login checks token on app start

## 🎨 Design Guidelines

- **Theme:** Material Design 3 with blue primary color
- **Borders:** 12px border radius for buttons and inputs
- **Typography:** Clear hierarchy with bold headings
- **Feedback:** Loading indicators and error messages via SnackBar

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0                      # HTTP requests
  flutter_secure_storage: ^9.0.0   # Secure token storage
  provider: ^6.1.1                  # State management
  cupertino_icons: ^1.0.2           # iOS icons
```

## 🧪 Testing the App

1. **Start Backend Server**
   ```bash
   # In your backend directory
   npm start
   ```

2. **Register a New User**
   - Open the app
   - Click "Register"
   - Fill in username, email, password
   - Select role (Student or Mentor)
   - Submit

3. **Login**
   - Enter email and password
   - Click "Login"
   - You'll be redirected to the dashboard

4. **Logout**
   - Click logout icon in the dashboard
   - You'll return to login screen

## 🛠️ Development Tips

### Adding New Screens
1. Create file in `lib/screens/`
2. Use StatefulWidget for interactive screens
3. Add loading states and error handling
4. Update navigation in existing screens

### Making API Calls
1. Add method to `api_service.dart`
2. Use `_getHeaders(needsAuth: true)` for protected routes
3. Parse JSON to model objects
4. Handle errors with try-catch

### Common Issues

**Issue:** "Target of URI doesn't exist"
- **Solution:** Run `flutter pub get` to ensure all dependencies are installed

**Issue:** "Connection refused" when calling API
- **Solution:** Ensure backend is running at `http://localhost:3000`

**Issue:** Token not persisting
- **Solution:** Check that `flutter_secure_storage` permissions are set in Android/iOS configs

## 📝 Code Conventions

- Use `camelCase` for variables and functions
- Use `PascalCase` for classes
- Add comments for complex logic
- Always dispose controllers in `dispose()` method
- Check `mounted` before calling `setState` after async operations

## 🎯 Next Steps

Now that the authentication flow is complete, you can:

1. Build the Career Exploration screen
2. Create the AI Quiz for career recommendations
3. Implement module progress tracking
4. Add knowledge assessments/quizzes

## 📄 License

This project is part of the Hakbang educational platform.

## 👥 User Roles

- **Student**: Explore careers, learn modules, track progress
- **Mentor**: Guide students, answer questions, provide support

## Contributors

- Sam Richmond Go
- Jenrick Ambalong

---

**Made using Flutter**
