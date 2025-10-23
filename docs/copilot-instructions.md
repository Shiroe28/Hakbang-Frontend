# Hakbang Flutter App - Copilot Instructions

## Project Overview

**Project Name:** Hakbang  
**Description:** A Smart AI-Powered Career Tracker for Learners Considering IT Careers  
**Tech Stack:** Flutter/Dart, Node.js Backend (already built), React Admin Panel (already built)  
**Backend URL:** http://localhost:3000/api

## Purpose

This Flutter mobile application helps students discover IT careers, follow learning paths, track their progress, and connect with mentors. Mentors can guide students and engage with the community.

---

# AI Coding Assistant Instructions for Hakbang Frontend

## Core Architecture
- Entry point: `lib/main.dart` contains the application root and Material theme configuration
- State Management: Provider pattern for global state management
- Widget Structure: Follows Flutter's widget composition pattern with StatelessWidget and StatefulWidget implementations
- Navigation Flow: Hierarchical navigation with main sections:
  - Authentication (Splash → Login/Signup)
  - Main Navigation (Home, Career Tracker, Insights, Profile)
  - Feature-specific screens (AI features, Learning Tracker, Community)
- Cross-Platform Support: Configured for Android, iOS, web, Linux, macOS and Windows platforms

## Application Structure

### Core Features
1. Authentication Flow
   - Splash/Loading Screen
   - Login/Sign-up with email and social authentication
   
2. Main Navigation
   - Home Dashboard (progress overview, AI suggestions)
   - Career Tracker
   - Insights
   - User Profile
   
3. Career Development Features
   - Career Path Overview
   - Career Details
   - Learning Progress Tracking
   - Course/Module Management
   - Assessments
   
4. AI-Powered Features
   - Career Recommendations
   - Virtual Mentor/Chatbot
   - Resume Builder
   - Skill Gap Analysis
   
5. User Management
   - Profile Management
   - Account Settings
   - Progress Tracking
   
6. Administrative Features
   - Admin Dashboard
   - User Management
   - Analytics
   - Feedback System
   
7. Community Features
   - Discussion Forums
   - Mentorship System
   - Help Center

## Development Workflow

### Environment Setup
- Flutter SDK version: >=3.0.0 <4.0.0
- Dart SDK requirements: Check `pubspec.yaml` for current version constraints

### Key Commands
```bash
# Run the app in development mode
flutter run

# Hot Reload (while app is running)
Press 'r' in terminal or use IDE hot reload button

# Hot Restart (when state reset needed)
Press 'R' in terminal or use IDE hot restart button

# Run tests
flutter test
```

### Testing Conventions
- Widget tests are located in `test/widget_test.dart`
- Use `WidgetTester` for interaction simulation
- Follow the pattern:
  1. Build widget
  2. Verify initial state
  3. Perform interactions
  4. Verify updated state

## Project Conventions

### Code Organization
- Main application logic goes in `lib/` with the following structure:
  - `screens/`: All screen widgets organized by feature
    - `auth/`: Authentication flows (splash, login, registration)
    - `home/`: Dashboard and main navigation
    - `career/`: Career tracking and learning features
    - `ai/`: AI-powered features (recommendations, chatbot)
    - `profile/`: User profile and settings
    - `admin/`: Administrative features
    - `community/`: Forums and mentorship features
  - `widgets/`: Reusable widget components
    - `buttons/`: Custom buttons
    - `cards/`: Reusable cards
    - `forms/`: Form components
    - `lists/`: List items
    - `loading/`: Loading indicators
    - `dialogs/`: Modal dialogs
  - `services/`: Business logic and API services
    - `auth/`: Authentication services
    - `api/`: API clients
    - `ai/`: AI feature services
    - `storage/`: Local storage
    - `analytics/`: Analytics
  - `models/`: Data models and state management
    - `user/`: User models
    - `career/`: Career/learning models
    - `ai/`: AI feature models
    - `community/`: Community models
  - `providers/`: State management providers
  - `utils/`: Helper functions and constants
    - `constants/`: App constants
    - `helpers/`: Utility functions
    - `extensions/`: Dart extensions
    - `validators/`: Form validators
    - `formatters/`: Data formatters
  
- Platform-specific code in respective directories:
  - `android/` for Android
  - `ios/` for iOS
  - `linux/`, `macos/`, `windows/` for desktop
  - `web/` for web platform

---

## Architecture (Original)

### Folder Structure

```
lib/
├── main.dart                      # App entry point with routing
├── models/                        # Data models
│   ├── user_model.dart
│   ├── career_model.dart
│   ├── module_model.dart
│   ├── post_model.dart
│   └── assessment_model.dart
├── providers/                     # State management
│   └── user_provider.dart
├── services/                      # API and utility services
│   ├── api_service.dart          # HTTP requests to backend
│   └── storage_service.dart      # Secure token storage
├── screens/                       # UI screens
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── dashboard_screen.dart
│   ├── main_screen.dart
│   ├── career_detail_screen.dart
│   ├── module_detail_screen.dart
│   ├── ai_chatbot_screen.dart
│   ├── community_screen.dart
│   ├── profile_screen.dart
│   └── [other screens]
└── widgets/                       # Reusable UI components
    └── [custom widgets]
```

## Backend API Endpoints

### Authentication (Public)
- **POST** `/auth/register` - Create new user
  - Body: `{ username, email, password, role }`
  - Returns: User data
  
- **POST** `/auth/login` - Login user
  - Body: `{ email, password }`
  - Returns: `{ token, role, user }`

### Public Content (No Auth Required)
- **GET** `/careers` - Fetch all career paths
- **GET** `/learning/modules?careerId=<id>` - Fetch modules (optionally filtered by career)
- **GET** `/learning/modules/:id` - Fetch single module
- **GET** `/learning/assessments/module/:moduleId` - Fetch quiz for module

### Protected Routes (Requires Authorization Header)
- **PUT** `/learning/modules/:id/progress` - Mark module complete
- **POST** `/learning/assessments/:id/submit` - Submit quiz answers
  - Body: `{ answers: [0, 1, 2, ...] }` (array of selected option indices)
  - Returns: `{ score, totalQuestions, percentage }`
  
- **POST** `/ai/recommendations` - Get AI career recommendations
  - Body: `{ quizResponses: [...] }`
  - Returns: Array of recommended careers

## User Roles

1. **Student** - Explore careers, learn modules, track progress, take quizzes
2. **Mentor** - Guide students, answer community questions

## Key Features to Implement

### Phase 1 (Completed)
- ✅ User registration and login
- ✅ Secure token storage with flutter_secure_storage
- ✅ Role-based authentication
- ✅ Basic dashboard showing user role

### Phase 2 (Next Steps)
- AI Career Recommendation Quiz (for students)
- Career Exploration Screen (list all careers)
- Career Detail Screen (show modules for selected career)
- Module Progress Tracking
- Knowledge Quizzes (assessments)

### Phase 3 (Future)
- Mentor Dashboard
- Community Forum
- Profile Management
- Advanced Analytics

## Coding Standards

### State Management
- Use **Provider** for state management
- Keep business logic separate from UI

### API Calls
- All HTTP requests go through `ApiService` class
- Use `http` or `dio` package
- Always handle errors gracefully with try-catch
- Show user-friendly error messages using SnackBar

### Authentication
- Store tokens securely using `flutter_secure_storage`
- Include `Authorization: Bearer <token>` header for protected routes
- Check authentication state on app start in `main.dart`
- Clear tokens on logout

### UI/UX Guidelines
- Use Material Design 3 (useMaterial3: true)
- Consistent color scheme: Blue as primary color
- Round borders (12px radius) for inputs and buttons
- Show loading indicators during async operations
- Validate forms before submission
- Use icons for better visual communication

### Error Handling
- Display meaningful error messages to users
- Never expose raw error messages
- Use SnackBar for temporary messages
- Handle network failures gracefully

### Code Quality
- Follow Dart naming conventions (camelCase for variables, PascalCase for classes)
- Add comments for complex logic
- Keep functions small and focused
- Use const constructors where possible for performance
- Dispose controllers and listeners properly

## Sample Data Structures

### Career Object
```dart
{
  "_id": "68ebe352578dc0a648e7bfe4",
  "title": "Web Developer",
  "description": "Builds and maintains websites...",
  "salaryRange": "₱30,000 - ₱80,000 per month"
}
```

### Module Object
```dart
{
  "_id": "68ebe5de578dc0a648e7c061",
  "title": "Module 1: HTML & CSS Fundamentals",
  "description": "Learn the core building blocks...",
  "careerId": "68ebe352578dc0a648e7bfe4",
  "contentType": "link",
  "contentURL": "https://www.freecodecamp.org/..."
}
```

### Assessment Object
```dart
{
  "_id": "...",
  "title": "HTML5 Basics Quiz",
  "moduleId": "68ebe5de578dc0a648e7c061",
  "questions": [
    {
      "questionText": "What does HTML stand for?",
      "options": ["Option 1", "Option 2", "Option 3", "Option 4"],
      "correctOption": 1
    }
  ]
}
```

## Development Workflow

1. **Before implementing a feature:**
   - Check if models exist or need updates
   - Verify API endpoint in `api_service.dart`
   - Plan UI/UX flow

2. **When creating a new screen:**
   - Create in `lib/screens/` directory
   - Use StatefulWidget for interactive screens
   - Implement proper dispose() for controllers
   - Add loading states and error handling

3. **When adding API calls:**
   - Add method to `api_service.dart`
   - Use proper HTTP method (GET, POST, PUT, DELETE)
   - Include authorization header if needed
   - Parse response into model objects

4. **Testing:**
   - Test with backend running on localhost:3000
   - Test both success and failure scenarios
   - Verify token storage and retrieval
   - Test navigation flows

## Common Patterns

### Making Authenticated API Calls
```dart
final response = await http.get(
  Uri.parse('$baseUrl/endpoint'),
  headers: await _getHeaders(needsAuth: true),
);
```

### Showing Loading State
```dart
bool _isLoading = false;

setState(() => _isLoading = true);
// ... perform async operation
setState(() => _isLoading = false);
```

### Navigation
```dart
// Push new screen
Navigator.push(context, MaterialPageRoute(
  builder: (context) => NewScreen(),
));

// Replace current screen
Navigator.pushReplacement(context, MaterialPageRoute(
  builder: (context) => NewScreen(),
));

// Clear stack and navigate
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (context) => NewScreen()),
  (route) => false,
);
```

## Important Notes

- MongoDB IDs use `_id` field, handle both `_id` and `id` in models
- Always check `mounted` before calling setState after async operations
- Use null-safety operators correctly (`?`, `!`, `??`)
- The backend is already complete - don't modify backend code
- Focus on Flutter app development only

## Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  flutter_secure_storage: ^9.0.0
  provider: ^6.1.1
  cupertino_icons: ^1.0.2
```

## Getting Started

1. Ensure backend is running at http://localhost:3000
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app
4. Test authentication flow first
5. Build features incrementally

## Future Enhancements

- Offline support with local database (sqflite)
- Push notifications for mentorship requests
- Dark mode theme
- Multi-language support
- Advanced progress analytics
- Social sharing features

---

## Best Practices

### Material Design
Use the built-in Material widgets and theme system consistently throughout the app.

### State Management
- Use Provider for global state management
- Use setState() for simple local widget state
- Consider suggesting advanced state management solutions (Riverpod, Bloc) for complex features

### Platform Adaptation
Use platform-specific widgets when needed (Material for Android/Windows/Linux, Cupertino for iOS/macOS)

### Testing
Write widget tests for new UI components following the existing pattern in `widget_test.dart`

### Performance Considerations
- Optimize image assets for mobile
- Implement proper loading states
- Consider pagination for lists
- Cache AI responses when appropriate

### Known Limitations/Constraints
- AI features require proper error handling and fallback states
- Cross-platform UI needs testing on all target platforms
- Consider offline functionality for learning features

---

**Remember:** This is a learning application focused on helping students discover and pursue IT careers. The UI should be intuitive, encouraging, and motivating!
