# 🖼️ Logo Setup Instructions

## What I Did:

### 1. ✅ Created Assets Folder
- Created `assets/images/` directory
- Ready for logo file

### 2. ✅ Updated `pubspec.yaml`
- Added assets configuration:
```yaml
flutter:
  assets:
    - assets/images/
```

### 3. ✅ Updated Splash Screen
- Changed from icon to image logo
- Added fallback to icon if image not found
- Location: `lib/screens/splash_screen.dart`

### 4. ✅ Updated App Bar (Home Screen)
- Added logo next to "Hakbang" text
- With fallback icon
- Location: `lib/screens/main_screen.dart`

---

## 📝 What YOU Need To Do:

### Step 1: Add Your Logo File

1. **Save your logo image** as: `logo.png`
2. **Place it in**: `c:\dev\Frontend\assets\images\logo.png`

**Requirements:**
- Format: PNG (with transparent background recommended)
- Size: 512x512 px or similar square dimensions
- Name: **MUST be** `logo.png` (exactly)

### Step 2: Hot Reload

In your Flutter terminal, press `r` to hot reload!

---

## 🎨 Where Logo Will Appear:

1. **Splash Screen** (app startup)
   - Large logo in white container
   - Centered with app name below

2. **Home Screen App Bar** (top of every screen)
   - Small logo next to "Hakbang" text
   - 32px height

3. **Fallback Behavior**
   - If logo not found → Shows school icon instead
   - App won't crash!

---

## 🔧 If Logo Doesn't Show:

1. **Check file location**:
   ```
   Frontend/
   ├── assets/
   │   └── images/
   │       └── logo.png  ← Must be here!
   ```

2. **Check file name**: Must be exactly `logo.png` (lowercase)

3. **Restart app** (not just hot reload):
   - Press `q` to quit
   - Run `flutter run` again

4. **Clear cache** (if still not working):
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

---

## 📸 Expected Result:

- Splash screen shows your logo
- Home screen app bar shows small logo
- All screens have logo in header

**Ready! Just add your logo file and press `r`!** 🎉
