# Quick Start Guide - Hakbang Flutter App

## ⚡ Quick Setup (5 Minutes)

### Step 1: Install Dependencies
Open terminal in the project directory and run:
```bash
flutter pub get
```

### Step 2: Start Your Backend
Make sure your Node.js backend is running:
```bash
# In your backend directory
npm start
```
Backend should be accessible at: `http://localhost:3000/api`

### Step 3: Run the App
```bash
flutter run
```

Choose your device/emulator when prompted.

---

## 🧪 Test the Authentication Flow

### Test User Registration

1. **Open the app** - you'll see the login screen
2. **Click "Register"** at the bottom
3. **Fill in the form:**
   - Username: `john_doe`
   - Email: `john@example.com`
   - Password: `password123`
   - Confirm Password: `password123`
   - Role: Select "Student" or "Mentor"
4. **Click "Register"**
5. **Success!** You'll be automatically logged in and see the dashboard

### Test User Login

1. **Logout** from the dashboard (top-right logout icon)
2. **You're back at login screen**
3. **Enter credentials:**
   - Email: `john@example.com`
   - Password: `password123`
4. **Click "Login"**
5. **Success!** Dashboard shows your role

### Test Auto-Login

1. **Close the app** (swipe away or stop it)
2. **Reopen the app**
3. **Automatic!** You're logged in without entering credentials

---

## 📁 What Was Created

### Core Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point with authentication wrapper |
| `lib/models/user_model.dart` | User data structure |
| `lib/models/career_model.dart` | Career path data structure |
| `lib/models/module_model.dart` | Learning module structure |
| `lib/models/assessment_model.dart` | Quiz/assessment structure |
| `lib/services/api_service.dart` | All backend API calls |
| `lib/services/storage_service.dart` | Secure token storage |
| `lib/screens/login_screen.dart` | Login UI with validation |
| `lib/screens/register_screen.dart` | Registration UI |
| `lib/screens/dashboard_screen.dart` | Main dashboard after login |
| `pubspec.yaml` | Flutter dependencies |
| `README.md` | Project documentation |
| `.github/copilot-instructions.md` | AI assistant instructions |

---

## 🔍 Code Highlights

### Secure Token Storage
```dart
// Save after login
await StorageService.saveAuthData(
  token: result['token'],
  role: result['role'],
  userId: result['user']['_id'],
);

// Check if logged in
bool isLoggedIn = await StorageService.isLoggedIn();

// Logout
await StorageService.clearAuthData();
```

### Making API Calls
```dart
// Login (returns token and role)
final result = await ApiService.login(
  email: email,
  password: password,
);

// Get careers (public endpoint)
List<Career> careers = await ApiService.getCareers();

// Mark module complete (protected endpoint)
await ApiService.markModuleComplete(moduleId);
```

### Navigation Flow
```
App Start → Check Auth → Login Screen OR Dashboard
                             ↓                ↓
                        Register →      View Role
                             ↓                ↓
                        Dashboard ←      Logout
```

---

## 🎨 UI Features

### Login Screen
- Email validation (must contain @)
- Password validation (min 6 characters)
- Show/hide password toggle
- Loading indicator during login
- Error messages via SnackBar
- Link to registration

### Register Screen
- Username validation (min 3 characters)
- Email validation
- Password confirmation
- Role selection dropdown (Student/Mentor)
- Show/hide password toggles
- Auto-login after registration
- Link back to login

### Dashboard Screen
- Welcome message
- Role badge (color-coded)
- User info display (username, email)
- Logout button
- "Coming Soon" features notice

---

## 🐛 Troubleshooting

### "Connection refused" Error
**Problem:** App can't reach backend  
**Solution:** 
- Verify backend is running: `http://localhost:3000/api`
- Check backend terminal for errors
- Ensure no firewall blocking port 3000

### "401 Unauthorized" Error
**Problem:** Token expired or invalid  
**Solution:**
- Logout and login again
- Clear app data if issue persists

### Lint Errors in IDE
**Problem:** Red underlines in code editor  
**Solution:**
- Run `flutter pub get`
- Restart your IDE
- Run `flutter analyze`

### Build Fails
**Problem:** App won't compile  
**Solution:**
- Clean build: `flutter clean`
- Get dependencies: `flutter pub get`
- Run again: `flutter run`

---

## 📊 API Endpoints Used

### Currently Implemented
✅ `POST /api/auth/register` - User registration  
✅ `POST /api/auth/login` - User login  

### Ready to Use (Not Yet in UI)
🔄 `GET /api/careers` - List all careers  
🔄 `GET /api/learning/modules` - List modules  
🔄 `GET /api/learning/modules/:id` - Get single module  
🔄 `GET /api/learning/assessments/module/:id` - Get quiz  
🔄 `PUT /api/learning/modules/:id/progress` - Mark complete  
🔄 `POST /api/learning/assessments/:id/submit` - Submit quiz  
🔄 `POST /api/ai/recommendations` - Get AI recommendations  

---

## 🚀 Next Features to Build

### 1. Career Exploration Screen
**For Students:**
- List all IT career paths
- Show salary ranges
- Navigate to career details

### 2. Career Detail Screen
**For Students:**
- Show career description
- List learning modules
- Track completion progress

### 3. AI Career Quiz
**For Students:**
- Interactive questionnaire
- Submit to AI for recommendations
- Display recommended careers

### 4. Module Content Screen
**For Students:**
- Display module content
- Mark as complete button
- Link to quiz

### 5. Quiz Screen
**For Students:**
- Multiple choice questions
- Submit answers
- Show score and percentage

---

## 💡 Development Tips

### Adding a New Screen

1. **Create the file:**
   ```dart
   // lib/screens/new_screen.dart
   import 'package:flutter/material.dart';
   
   class NewScreen extends StatefulWidget {
     const NewScreen({super.key});
     
     @override
     State<NewScreen> createState() => _NewScreenState();
   }
   
   class _NewScreenState extends State<NewScreen> {
     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(title: const Text('New Screen')),
         body: Center(child: Text('Hello!')),
       );
     }
   }
   ```

2. **Navigate to it:**
   ```dart
   Navigator.push(
     context,
     MaterialPageRoute(builder: (context) => const NewScreen()),
   );
   ```

### Making a New API Call

1. **Add to api_service.dart:**
   ```dart
   static Future<List<Career>> getCareers() async {
     try {
       final response = await http.get(
         Uri.parse('$baseUrl/careers'),
         headers: await _getHeaders(),
       );
       
       if (response.statusCode == 200) {
         final List<dynamic> data = jsonDecode(response.body);
         return data.map((json) => Career.fromJson(json)).toList();
       } else {
         throw Exception('Failed to load careers');
       }
     } catch (e) {
       throw Exception('Error: $e');
     }
   }
   ```

2. **Use in your screen:**
   ```dart
   Future<void> _loadCareers() async {
     try {
       final careers = await ApiService.getCareers();
       setState(() {
         _careers = careers;
       });
     } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Error: $e')),
       );
     }
   }
   ```

---

## ✅ What's Working Now

- ✅ User registration with validation
- ✅ User login with error handling
- ✅ Secure token storage
- ✅ Role-based authentication
- ✅ Auto-login on app restart
- ✅ Logout functionality
- ✅ Loading states during async operations
- ✅ User-friendly error messages
- ✅ Clean, modern UI with Material Design 3

---

## 📞 Need Help?

- Check `README.md` for detailed documentation
- Review `.github/copilot-instructions.md` for coding standards
- Ensure backend is running and accessible
- Check Flutter and Dart versions match requirements

---

**You're all set! Start building amazing features! 🎉**
