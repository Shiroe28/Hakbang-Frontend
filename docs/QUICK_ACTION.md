# 🎯 QUICK ACTION GUIDE - Do These Now!

## ⚡ 3-Minute Quick Test

```bash
# Terminal 1: Start Backend
cd backend
npm run dev

# Terminal 2: Start Flutter
cd Frontend
flutter run

# In App:
1. Login
2. Check if username shows on Dashboard ✅
3. Go to Profile → Click "Edit Profile" ✅
4. Go to Login screen → Click "Forgot Password?" ✅
5. Go to Community → Try posting ✅
```

---

## 🐛 If Something Doesn't Work

### ❌ Edit Profile still says "login first"
**Cause**: App needs restart  
**Fix**: Stop app (Ctrl+C) → Run `flutter run` again

---

### ❌ Username still shows "N/A"
**Cause**: App needs restart  
**Fix**: Stop app → Run `flutter run` again

---

### ❌ Community still shows 404
**Cause**: Backend route not registered  
**Fix**:
```bash
# Check server.js or app.js has:
app.use('/api/community', communityRoutes);

# Test backend:
curl http://localhost:3000/api/community/posts
# Should return: { success: true, data: [...] }
# If 404: Route not registered
```

---

### ❌ Module filtering shows ALL modules
**Cause**: Modules don't have `careerId` in database  
**Fix**:
```bash
# MongoDB shell or Compass:
db.modules.find({}, { title: 1, careerId: 1 })

# If careerId is null, update them:
# Get career IDs first:
db.careers.find({}, { _id: 1, title: 1 })

# Update modules with careerId:
db.modules.updateMany(
  { title: /HTML|CSS|JavaScript|React|Node/i },
  { $set: { careerId: ObjectId("YOUR_WEB_DEVELOPER_ID") } }
)

db.modules.updateMany(
  { title: /Python|Pandas|NumPy|Data/i },
  { $set: { careerId: ObjectId("YOUR_DATA_SCIENTIST_ID") } }
)

# Repeat for all careers
```

---

### ❌ Forgot Password - No code in console
**Cause**: Backend endpoint not working  
**Fix**:
```bash
# Test backend:
curl -X POST http://localhost:3000/api/auth/forgot-password \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com"}'

# Should return: { success: true, message: "..." }
# And log code to console

# If 404: Restart backend
npm run dev
```

---

## 📊 Test Checklist

Use this to track what's working:

```
Testing Session: [DATE]

✅ Backend running on http://localhost:3000
✅ Flutter app running

Feature Tests:
[ ] Edit Profile - Opens (not "login first")
[ ] Username - Shows real name on Dashboard
[ ] Username - Shows real name on Profile
[ ] Forgot Password - Link appears on login
[ ] Forgot Password - Code sent (check backend console)
[ ] Forgot Password - Password reset works
[ ] Forgot Password - Can login with new password
[ ] Community - Can view posts
[ ] Community - Can create post (not 404)
[ ] Career Detail - Shows modules
[ ] Module Filtering - Shows ONLY that career's modules (not all)

Issues Found:
1. _______________________________________________
2. _______________________________________________
3. _______________________________________________
```

---

## 🔧 Backend Quick Fixes

### Fix 1: Community Route Not Registered
```javascript
// In server.js or app.js:
const communityRoutes = require('./routes/communityRoutes');
app.use('/api/community', communityRoutes);  // ← Add this line

// Restart backend:
npm run dev
```

### Fix 2: Modules Missing careerId
```bash
# MongoDB shell:
# Update all modules for Web Developer:
db.modules.updateMany(
  { title: { $in: [
    "HTML & CSS Fundamentals",
    "JavaScript Basics",
    "React Framework",
    "Node.js Backend"
  ]}},
  { $set: { careerId: ObjectId("WEB_DEV_CAREER_ID") } }
)

# Verify:
db.modules.find({ careerId: ObjectId("WEB_DEV_CAREER_ID") }, { title: 1 })
```

---

## 💬 What to Tell Me

After testing, reply with:

```
✅ WORKING:
- Edit Profile: YES/NO
- Username Display: YES/NO
- Forgot Password: YES/NO
- Community Forum: YES/NO

⚠️ NOT WORKING:
- Module Filtering: YES (all modules shown) / NO (filtered correctly)

📝 ERRORS (if any):
[Paste any error messages here]

🔍 NEED HELP WITH:
[What you need help fixing]
```

---

## 🎯 What's Already Done

**✅ Frontend Fixes (Ready to Test)**:
1. User loads on app start → Username displays
2. Edit Profile checks & loads user → No more "login first"
3. AI chatbot cleans responses → No more JSON artifacts
4. Forgot Password screens created → Full flow ready
5. Forgot Password link added to login → Easy to find

**⏳ Need Your Backend Data Fix**:
1. Module filtering → Update careerId in MongoDB
2. Community posts → Verify route registered
3. Badge system → Implement awarding logic

**📋 Still To Create**:
1. Resume Builder screen (30 min) - After you test

---

## 🚀 Next Steps

1. **NOW**: Test the app (5 min)
2. **THEN**: Reply with results
3. **NEXT**: Fix any issues together
4. **FINALLY**: I'll create Resume Builder

---

**Ready? Start testing!** ⚡

Commands:
```bash
npm run dev      # Terminal 1: Backend
flutter run      # Terminal 2: Flutter
```
