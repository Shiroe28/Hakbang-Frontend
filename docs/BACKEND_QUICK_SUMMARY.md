# 🚨 BACKEND FIXES NEEDED - Quick Reference

**Date:** October 24, 2025

---

## 🔴 3 CRITICAL BUGS (App Broken)

### 1. Assessment Crashes - Type Error
**Problem:** `correctOption` is STRING but must be INTEGER  
**Fix:** Change `correctOption: "1"` to `correctOption: 1` (remove quotes)  
**Where:** Assessment schema OR seed data OR controller conversion

### 2. Community Posts Empty
**Problem:** Posts exist but don't display  
**Fix:** Populate `authorName` and `authorRole` from User collection  
**Response needs:**
```json
{
  "authorName": "John Doe",
  "authorRole": "student"
}
```

### 3. Shows ALL Modules (Not Filtered)
**Problem:** Career shows 28 modules instead of 5-8  
**Fix:** Use `req.query.careerId` to filter modules  
**Code:** `Module.find({ careerId: req.query.careerId })`

---

## 🟡 2 MISSING FEATURES

### 4. Profile Picture Upload
**Need:** POST /api/users/profile-picture endpoint  
**Tool:** Use multer for file upload  
**Add to schema:** `profilePicture: String`

### 5. Badges & Progress Tracking
**Need:** Track completed modules and award badges  
**Add to schema:**
```javascript
progressSummary: {
  completedModules: Number,
  badgesEarned: Number
}
```

---

## 📝 Full Prompts

See `docs/QUICK_BACKEND_PROMPTS.md` for copy-paste prompts with complete code examples.

---

## ✅ Testing After Fixes

**Test 1:** Assessment returns integers  
**Test 2:** Posts show author names  
**Test 3:** Filter returns 5-8 modules per career  
**Test 4:** Can upload profile picture  
**Test 5:** Progress updates when completing modules
