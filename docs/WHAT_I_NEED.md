# 📋 What I Need From Your Backend

## Quick Answer: Edit Profile Issue

**Problem:** "Please login first" when clicking Edit Profile

**Cause:** `GET /api/auth/me` endpoint isn't working or not being called properly

**Fix Applied:** Updated profile_screen.dart to call `userProvider.loadCurrentUser()` which fetches user data from API

**Now it should work IF:** Your backend `/api/auth/me` endpoint returns user data when given a valid token

---

## 🔥 Critical Endpoints (Must Work)

Send me the status of these **3 critical endpoints**:

### 1. GET /api/auth/me ⚠️ **MOST CRITICAL**
**Why:** Called on app startup. If this fails, Edit Profile won't work.

**Expected Request:**
```
GET http://localhost:3000/api/auth/me
Headers:
  Authorization: Bearer {token}
  Content-Type: application/json
```

**Expected Response:**
```json
{
  "_id": "123",
  "username": "johndoe",
  "email": "john@example.com",
  "role": "student"
}
```

**Test it:**
```bash
# Replace YOUR_TOKEN with actual token from login
curl -H "Authorization: Bearer YOUR_TOKEN" http://localhost:3000/api/auth/me
```

---

### 2. GET /api/learning/modules?careerId={id} ⚠️ **Must Filter**
**Why:** Career detail page shows all modules instead of career-specific ones

**Expected:** When `careerId` query parameter is provided, return ONLY modules for that career

**Backend code should be:**
```javascript
app.get('/api/learning/modules', async (req, res) => {
  const { careerId } = req.query;
  
  let filter = {};
  if (careerId) {
    filter.careerId = careerId; // ⚠️ Add this filtering
  }
  
  const modules = await Module.find(filter);
  res.json({ data: modules });
});
```

**Test it:**
```bash
# Should return only modules for that career
curl "http://localhost:3000/api/learning/modules?careerId=YOUR_CAREER_ID"
```

---

### 3. POST /api/community/posts ⚠️ **NEW - Must Implement**
**Why:** Users can now create community posts in the app

**Expected Request:**
```
POST http://localhost:3000/api/community/posts
Headers:
  Authorization: Bearer {token}
  Content-Type: application/json
Body:
  {
    "title": "My Post Title",
    "content": "Post content here"
  }
```

**Expected Response:**
```json
{
  "message": "Post created successfully",
  "post": {
    "_id": "123",
    "title": "My Post Title",
    "content": "Post content here",
    "authorId": "userId",
    "createdAt": "2025-10-16T10:30:00Z"
  }
}
```

**Test it:**
```bash
curl -X POST http://localhost:3000/api/community/posts \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"Test","content":"Hello"}'
```

---

## 📤 What to Send Me

Choose ONE:

### Option 1: Quick Status Check ✅ **EASIEST**
Just tell me:
- [ ] Do you have `GET /api/auth/me` working?
- [ ] Does `GET /api/learning/modules?careerId=X` filter modules?
- [ ] Do you have `POST /api/community/posts` (probably NOT - it's new)

### Option 2: Test Results 
Run these curl commands and send me the results:
```bash
# 1. Login (save the token)
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"your@email.com","password":"yourpassword"}'

# 2. Get current user (replace YOUR_TOKEN)
curl http://localhost:3000/api/auth/me \
  -H "Authorization: Bearer YOUR_TOKEN"

# 3. Test module filtering (replace CAREER_ID)
curl "http://localhost:3000/api/learning/modules?careerId=CAREER_ID"
```

### Option 3: Share Backend Code 🎯 **BEST**
Send me:
- GitHub link to your backend repo, OR
- Zip file with your backend code, OR
- Screenshots of your route files

Then I can:
- Check what's implemented
- Fix what's missing
- Test everything together

---

## 🚀 After You Send Info

I'll help you:
1. ✅ Fix any missing endpoints
2. ✅ Test the connections
3. ✅ Make sure Edit Profile works
4. ✅ Ensure modules are filtered correctly
5. ✅ Get community posts working

---

## 💡 Quick Fix Checklist

Before sending info, try these:

**For Edit Profile Issue:**
- [ ] Login to your app
- [ ] Open browser console (F12)
- [ ] Go to Profile tab
- [ ] Click Edit Profile
- [ ] Check console for errors
- [ ] Send me the error message

**For Backend:**
- [ ] Is backend running on port 3000?
- [ ] Can you access http://localhost:3000/api/careers?
- [ ] Do you have JWT authentication implemented?
- [ ] Are you using MongoDB for database?

---

**Ready to help once you send me the info!** 🎯

Just reply with:
- Backend status (which endpoints work/don't work)
- OR backend code/repo link
- OR error messages from browser console
