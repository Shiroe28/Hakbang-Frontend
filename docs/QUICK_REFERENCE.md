# ⚡ Hakbang Quick Reference Card

## 🎯 Current Status
✅ **App is building and will open in Chrome automatically!**

---

## 🚀 Run Commands

```bash
# Web (No setup needed - RECOMMENDED)
flutter run -d chrome

# Windows (Requires Developer Mode)
flutter run -d windows

# Android (Requires emulator/device)
flutter run -d android

# See all devices
flutter devices
```

---

## ⌨️ While App is Running

| Key | Action |
|-----|--------|
| `r` | Hot reload (fast updates) |
| `R` | Hot restart (full restart) |
| `q` | Quit/Stop app |
| `h` | Help |
| `c` | Clear console |

---

## 🔧 Quick Fixes

**"No devices found"**
```bash
flutter run -d chrome  # Always works!
```

**"Symlink support required"**
```bash
start ms-settings:developers  # Enable Developer Mode
```

**"Backend not responding"**
```bash
# Start your Node.js backend first!
cd path/to/backend
npm start
```

---

## 📁 Important Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point |
| `lib/services/api_service.dart` | All API calls |
| `lib/screens/login_screen.dart` | Login UI |
| `RUN_GUIDE.md` | Detailed run instructions |
| `QUICK_START.md` | Setup guide |

---

## 🎨 Test Credentials (After Registration)

Create test accounts:
- **Student:** test@student.com / password123
- **Mentor:** test@mentor.com / password123

---

## 🐛 Common Issues

**App slow to start?**
→ First build takes 1-2 minutes, be patient!

**Can't connect to backend?**
→ Ensure backend is running: `http://localhost:3000`

**Changes not showing?**
→ Press `r` for hot reload or `R` for hot restart

---

## 📱 Backend Must Be Running!

```bash
# In your backend directory
npm start

# Should see: "Server running on port 3000"
```

---

## ✅ What to Test

1. ✅ Register new user (Student/Mentor)
2. ✅ Login with credentials
3. ✅ See dashboard with role badge
4. ✅ Logout
5. ✅ Login again
6. ✅ Refresh browser (still logged in!)

---

## 🎯 Next Features to Build

- Career Exploration Screen
- AI Career Quiz
- Module Progress Tracking
- Knowledge Assessments

All API methods are ready in `api_service.dart`!

---

**Your app is opening in Chrome now... 🚀**

**Press `r` to hot reload after making code changes!**
