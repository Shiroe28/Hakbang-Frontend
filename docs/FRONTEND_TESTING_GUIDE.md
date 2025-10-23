# 🧪 FRONTEND TESTING GUIDE - Do This Now!

## ⚠️ IMPORTANT: You Need to Restart the Flutter App!

The fixes I made won't work until you **completely restart** the app. Here's why:

### Why Restart is Required:
1. ✅ I modified `lib/main.dart` to load user on startup
2. ✅ I modified `lib/services/api_service.dart` to add forgot password methods
3. ✅ I modified `lib/screens/login_screen.dart` to add forgot password link
4. ✅ Dart needs to recompile these changes

**Hot reload (r) is NOT enough!** You need **Hot Restart (R)** or full restart.

---

## 🚀 STEP 1: Complete App Restart

### Option A: Hot Restart (Fastest - 5 seconds)
```bash
# In the terminal running flutter:
# Press SHIFT + R (capital R)
# OR
# Press R in the terminal
```

### Option B: Full Restart (Recommended - 30 seconds)
```bash
# In terminal running flutter:
# Press Ctrl + C to stop

# Then restart:
flutter run
```

**Wait for:** "Performing hot restart..." or "Flutter run key commands"

---

## 🧪 STEP 2: Test Each Feature

### Test 1: Username Display ✅

**Steps:**
```
1. Open the restarted app
2. Login with your account
3. Look at the Dashboard (Home tab)
```

**✅ EXPECTED:**
- Dashboard shows: "Welcome Back, YourName!" (with your actual name)
- NOT: "Welcome Back!" or "Welcome Back, N/A"

**❌ IF IT STILL SHOWS "N/A":**
- Backend issue: Login endpoint not returning user data
- Check BACKEND_REQUEST.md for what to ask backend team

---

### Test 2: Edit Profile ✅

**Steps:**
```
1. Still in the app (after restart)
2. Go to Profile tab (👤 bottom right)
3. Click "Edit Profile" button
```

**✅ EXPECTED:**
- Edit Profile screen opens
- Shows your current name, username, email
- You can edit and save

**❌ IF IT SHOWS "Please login first":**
- Backend issue: /api/users/me endpoint not working
- Check BACKEND_REQUEST.md for what to ask backend team

---

### Test 3: Forgot Password ✅

**Steps:**
```
1. Logout (Profile → Logout)
2. On Login screen, look below the "Login" button
3. Should see "Forgot Password?" link
4. Click it
```

**✅ EXPECTED:**
- Forgot Password screen opens
- Has email input field
- Has "Send Reset Code" button

**❌ IF LINK NOT VISIBLE:**
- App didn't restart properly
- Do FULL RESTART (flutter run)

**Test the Flow:**
```
1. Enter your email
2. Click "Send Reset Code"
3. Check BACKEND CONSOLE for 6-digit code
4. Enter code + new password
5. Should show success dialog
6. Login with new password
```

**❌ IF "Route not found" ERROR:**
- Backend issue: Forgot password endpoints not registered
- Send BACKEND_REQUEST.md to backend team

---

### Test 4: Community Forum ⚠️

**Steps:**
```
1. Login to app
2. Go to Community tab (💬)
3. Click the "+" button (Create Post)
4. Fill in title and content
5. Click Post button
```

**✅ EXPECTED:**
- Post created successfully
- Appears in community list

**❌ IF 404 ERROR:**
- Backend issue: /api/community/posts endpoint not working
- Send BACKEND_REQUEST.md to backend team

---

### Test 5: AI Chatbot Clean Responses ✅

**Steps:**
```
1. From Dashboard, click "AI Career Mentor"
2. Send message: "What is a web developer?"
3. Wait for response
```

**✅ EXPECTED:**
- Clean text response
- NO {response: or timestamp: visible

**❌ IF STILL SHOWS JSON:**
- My fix didn't load
- Do FULL RESTART (flutter run)

---

## 📊 Test Results Form

After testing, fill this out:

```markdown
## Frontend Test Results

**Date:** [Today's date]
**App Restarted:** YES/NO (Full restart or Hot Restart?)

### Test 1: Username Display
- Status: ✅ WORKING / ❌ BROKEN
- What I see: "[Paste what shows on screen]"
- Expected: "Welcome Back, MyName!"

### Test 2: Edit Profile
- Status: ✅ WORKING / ❌ BROKEN
- What happens: "[Opens edit screen / Shows 'login first' / Other]"
- Expected: Opens edit profile screen

### Test 3: Forgot Password
- Link visible: YES/NO
- Screens work: ✅ WORKING / ❌ BROKEN
- Error message (if any): "[Paste error]"

### Test 4: Community Forum
- Status: ✅ WORKING / ❌ BROKEN
- Can create post: YES/NO
- Error message (if any): "[Paste error]"

### Test 5: AI Chatbot
- Status: ✅ WORKING / ❌ BROKEN
- Shows clean text: YES/NO
- Still shows JSON: YES/NO

### Backend Issues Found:
- [ ] Username not in login response
- [ ] /api/users/me endpoint missing
- [ ] Forgot password endpoints missing
- [ ] Community endpoints not working
- [ ] Other: [Describe]
```

---

## 🐛 Common Problems & Solutions

### Problem 1: "Still shows N/A after restart"
**Cause:** Backend not returning user data  
**Solution:** 
1. Send BACKEND_REQUEST.md to backend team
2. They need to include `user` object in login response
3. They need to make sure /api/users/me endpoint works

---

### Problem 2: "Edit Profile still says 'login first'"
**Cause:** Same as Problem 1  
**Solution:** Same as above

---

### Problem 3: "Forgot Password link not visible"
**Cause:** App didn't fully restart  
**Solution:**
```bash
# Stop app completely:
Ctrl + C

# Clear build cache:
flutter clean

# Rebuild and run:
flutter run
```

---

### Problem 4: "Forgot Password shows 'Route not found'"
**Cause:** Backend endpoints not created/registered  
**Solution:** Send BACKEND_REQUEST.md to backend team

---

### Problem 5: "Community 404 error"
**Cause:** Backend route not registered  
**Solution:** Send BACKEND_REQUEST.md to backend team

---

## 🎯 Next Steps Based on Results

### If ALL Tests Pass ✅
Great! Move to creating Resume Builder screen.

### If Username/Edit Profile Broken ❌
**Action Required:**
1. Send BACKEND_REQUEST.md to backend team
2. Wait for them to fix user endpoints
3. Test again after they confirm fix

### If Forgot Password Broken ❌
**Action Required:**
1. Send BACKEND_REQUEST.md to backend team
2. They need to:
   - Create PasswordReset model
   - Add forgotPassword() controller
   - Add resetPassword() controller
   - Register routes in server.js

### If Community Broken ❌
**Action Required:**
1. Send BACKEND_REQUEST.md to backend team
2. They need to register community routes in server.js

---

## 📞 What to Do Now

### IMMEDIATE (5 minutes):

1. **Restart the Flutter app**:
   ```bash
   # Press R (Hot Restart)
   # OR
   # Ctrl+C then flutter run
   ```

2. **Test all 5 features** (follow steps above)

3. **Fill out Test Results Form** (copy template above)

4. **Reply to me with:**
   - ✅ Test results
   - ❌ What's not working
   - 📸 Screenshots if possible

### AFTER TESTING:

5. **Send BACKEND_REQUEST.md to backend team** if anything is broken

6. **Wait for backend fixes** (if needed)

7. **I'll create Resume Builder** after tests pass!

---

## 💬 Reply Template

Use this to reply to me:

```markdown
## Test Complete!

### App Restarted:
✅ YES - Used Hot Restart (R)
(or)
✅ YES - Used Full Restart (flutter run)

### Results:
1. Username Display: ✅ WORKING / ❌ BROKEN - [What I see]
2. Edit Profile: ✅ WORKING / ❌ BROKEN - [What happens]
3. Forgot Password: ✅ WORKING / ❌ BROKEN - [Error if any]
4. Community Forum: ✅ WORKING / ❌ BROKEN - [Error if any]
5. AI Chatbot: ✅ WORKING / ❌ BROKEN

### Backend Issues:
[List what's not working and needs backend fix]

### Screenshots:
[Attach if possible]

### Ready for:
- [ ] Resume Builder (if all tests pass)
- [ ] Wait for backend fixes (if issues found)
```

---

**Ready? Restart the app now and test!** 🚀

Commands:
```bash
# In flutter terminal:
Press R (for Hot Restart)

# OR

Press Ctrl+C
flutter run
```

Then test everything and reply with results!
