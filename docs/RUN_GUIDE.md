# 🚀 How to Run Hakbang Flutter App

## Platform Support

Your Hakbang app now supports multiple platforms:
- ✅ **Web** (Chrome, Edge) - Ready to use immediately
- ✅ **Windows Desktop** - Requires Developer Mode
- ✅ **Android** - Requires Android device/emulator

---

## 🌐 Run on Web (Recommended for Quick Testing)

### Chrome
```bash
flutter run -d chrome
```

### Edge
```bash
flutter run -d edge
```

**Advantages:**
- ✅ No additional setup required
- ✅ Quick hot reload
- ✅ Easy debugging
- ✅ Works immediately

**Note:** The web version is currently running and will open in your browser automatically!

---

## 🪟 Run on Windows Desktop

### Step 1: Enable Developer Mode

Windows requires Developer Mode for plugin support (flutter_secure_storage uses symlinks).

**Option 1: Via Settings**
1. Open Windows Settings
2. Go to **Settings > Privacy & Security > For developers**
3. Turn on **Developer Mode**

**Option 2: Via Command (opens Settings)**
```bash
start ms-settings:developers
```

### Step 2: Run the App
```bash
flutter run -d windows
```

**Advantages:**
- ✅ Native Windows app
- ✅ Better performance
- ✅ Desktop experience

---

## 📱 Run on Android

### Prerequisites
1. **Android Studio** installed
2. **Android SDK** configured
3. **Android Emulator** OR **Physical Device** connected

### Check Available Devices
```bash
flutter devices
```

### Run on Android
```bash
# If only one device
flutter run

# If multiple devices, specify Android
flutter run -d <device-id>
```

**Advantages:**
- ✅ Mobile app experience
- ✅ Test on real hardware
- ✅ Production-like environment

---

## 🎯 Current Status

**Currently Running:** Your app is launching on **Chrome** right now! 🎉

The browser window should open automatically showing your Hakbang login screen.

---

## 🔧 Troubleshooting

### Issue: "Building with plugins requires symlink support"
**Solution:** Enable Windows Developer Mode (see instructions above)

### Issue: "No devices found"
**Solution:** 
- For web: Make sure Chrome or Edge is installed
- For Windows: Enable Developer Mode
- For Android: Start an emulator or connect a device

### Issue: App not loading in browser
**Solution:**
- Wait a few more seconds (first build takes longer)
- Check terminal for build progress
- Chrome should open automatically

---

## ⚡ Quick Commands Reference

```bash
# See all available devices
flutter devices

# Run on specific platform
flutter run -d chrome          # Web (Chrome)
flutter run -d edge            # Web (Edge)
flutter run -d windows         # Windows Desktop
flutter run -d android         # Android

# Hot reload (while app is running)
# Press 'r' in the terminal

# Hot restart (while app is running)
# Press 'R' in the terminal

# Stop the app
# Press 'q' in the terminal or Ctrl+C
```

---

## 🎨 Development Workflow

### Recommended for Development: **Web (Chrome)**

1. **Start the app:**
   ```bash
   flutter run -d chrome
   ```

2. **Make changes** to your code

3. **Hot reload** - Press `r` in terminal or save file
   - Updates UI instantly
   - Preserves app state

4. **Hot restart** - Press `R` in terminal
   - Restarts app completely
   - Clears app state

### For Testing: **Windows Desktop**

Better performance and native feel, but requires Developer Mode.

### For Production Testing: **Android Device**

Test on real hardware before releasing to Play Store.

---

## 📊 Platform Comparison

| Feature | Web | Windows | Android |
|---------|-----|---------|---------|
| Setup Required | None | Developer Mode | Android Studio |
| Build Speed | Fast | Medium | Slower |
| Hot Reload | ✅ Fast | ✅ Fast | ✅ Medium |
| Best For | Development | Desktop Users | Mobile Users |
| Performance | Good | Excellent | Excellent |

---

## 🌟 Next Steps

1. **Wait for Chrome to open** - Your app is building now!
2. **Test the login flow** - Register and login
3. **Start building features** - Career exploration, etc.

---

## 💡 Pro Tips

### Tip 1: Keep Terminal Open
The terminal shows important debugging info and allows hot reload.

### Tip 2: Use Hot Reload
Press `r` in terminal after making code changes - see changes instantly!

### Tip 3: Check Console
In Chrome, press F12 to see browser console for debugging.

### Tip 4: Backend Must Be Running
Remember to keep your Node.js backend running on `localhost:3000`

---

## 🎯 What's Happening Now

Your app is currently:
1. ✅ Building for Chrome
2. ⏳ Compiling Dart to JavaScript
3. ⏳ Starting development server
4. ⏳ Opening Chrome browser

**Be patient on first build - it can take 1-2 minutes!**

Once ready, you'll see:
- Chrome window opens automatically
- Your Hakbang login screen appears
- Terminal shows "Debug service listening on..."

---

## 🚀 After the App Opens

Test these features:
1. **Register** a new account (Student or Mentor)
2. **Login** with your credentials
3. **See Dashboard** with your role
4. **Logout** and login again
5. **Refresh browser** - you're still logged in (token stored)!

---

**Your app is launching... Get ready to test it! 🎉**
