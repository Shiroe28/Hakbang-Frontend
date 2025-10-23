# 🔴 URGENT: Backend Issues Found - Need Your Help

## Test Results from Frontend

Hi Backend Team! 👋

I tested the Flutter app with your endpoints and found several issues. Here's what's **NOT working**:

---

## ❌ Issue 1: Forgot Password - Route Not Found

**What I tried:**
```dart
// Frontend calling:
POST http://localhost:3000/api/auth/forgot-password
Body: { "email": "test@example.com" }
```

**Error:** Route not found (404 or similar)

**What I need:**

### 1️⃣ Verify Route is Registered
```javascript
// In your server.js or app.js, do you have:
const authRoutes = require('./routes/authRoutes');
app.use('/api/auth', authRoutes);

// In routes/authRoutes.js, do you have:
router.post('/forgot-password', forgotPassword);
router.post('/reset-password', resetPassword);
```

### 2️⃣ Test Endpoints Directly
```bash
# Test forgot password:
curl -X POST http://localhost:3000/api/auth/forgot-password \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com"}'

# Expected: { success: true, message: "..." }
# Actual: ???

# Test reset password:
curl -X POST http://localhost:3000/api/auth/reset-password \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","code":"123456","newPassword":"newpass123"}'

# Expected: { success: true, message: "..." }
# Actual: ???
```

**Please send me:**
- ✅ Curl test results (what you got back)
- ✅ Server console output (any errors?)
- ✅ Confirmation routes are registered in server.js

---

## ❌ Issue 2: Community Forum - Not Working

**What I tried:**
```dart
// Frontend calling:
GET http://localhost:3000/api/community/posts
POST http://localhost:3000/api/community/posts
```

**Error:** Not working (404 or other error?)

**What I need:**

### 1️⃣ Verify Routes are Registered
```javascript
// In server.js or app.js:
const communityRoutes = require('./routes/communityRoutes');
app.use('/api/community', communityRoutes);  // ← Is this line there?
```

### 2️⃣ Test Endpoints
```bash
# Test GET posts (should work without auth):
curl http://localhost:3000/api/community/posts

# Expected: { success: true, data: [...] }
# Actual: ???

# Test POST post (needs auth token):
# First login:
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"your@email.com","password":"yourpass"}'

# Copy the token from response, then:
curl -X POST http://localhost:3000/api/community/posts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{"category":"general","title":"Test Post","content":"Testing 123"}'

# Expected: { success: true, data: {...post} }
# Actual: ???
```

**Please send me:**
- ✅ Curl test results for both GET and POST
- ✅ Server console output
- ✅ Confirmation route is registered

---

## ⚠️ Issue 3: Username Not Showing on Frontend

**What I tried:**
- Login to app
- Check Dashboard and Profile

**Result:** Username shows "N/A" or "Welcome Back!" (without name)

**What I need from backend:**

### Check Login Response
```javascript
// When user logs in, does your response include user data?
// POST /api/auth/login response should be:
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "role": "student",
  "user": {  // ← THIS IS CRITICAL!
    "_id": "507f1f77bcf86cd799439011",
    "name": "John Doe",        // ← Need this!
    "username": "johndoe",     // ← Need this!
    "email": "john@example.com",
    "role": "student"
  }
}
```

### Check Get User Endpoint
```bash
# Test get current user:
# First login to get token:
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"your@email.com","password":"yourpass"}'

# Copy token, then get user:
curl http://localhost:3000/api/users/me \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"

# Expected:
{
  "success": true,
  "data": {
    "_id": "...",
    "name": "John Doe",
    "username": "johndoe",
    "email": "john@example.com",
    "role": "student"
  }
}

# Actual: ???
```

**Please send me:**
- ✅ Login response (what you return after successful login)
- ✅ GET /users/me response
- ✅ Does your User model have `name` and `username` fields?

---

## ⚠️ Issue 4: Edit Profile - Need to Verify

**What I tried:**
- Login → Profile → Click "Edit Profile"

**Result:** May show "Please login first" (testing now)

**What I need:**

### Verify Edit Profile Endpoint
```bash
# Login first:
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"your@email.com","password":"yourpass"}'

# Update profile:
curl -X PUT http://localhost:3000/api/users/profile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{"name":"New Name","username":"newusername"}'

# Expected: { success: true, data: {...updatedUser} }
# Actual: ???
```

**Please send me:**
- ✅ Does PUT /api/users/profile endpoint exist?
- ✅ Test result from curl command above

---

## 📊 Complete Backend Endpoint Checklist

Please test ALL of these and send me the results:

### Authentication Endpoints
```bash
# 1. Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
# Status: ???

# 2. Register
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test2@example.com","password":"password123","role":"student"}'
# Status: ???

# 3. Forgot Password
curl -X POST http://localhost:3000/api/auth/forgot-password \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com"}'
# Status: ???

# 4. Reset Password
curl -X POST http://localhost:3000/api/auth/reset-password \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","code":"123456","newPassword":"newpass123"}'
# Status: ???
```

### User Endpoints
```bash
# Login first and save token
TOKEN="paste_token_here"

# 5. Get Current User
curl http://localhost:3000/api/users/me \
  -H "Authorization: Bearer $TOKEN"
# Status: ???

# 6. Update Profile
curl -X PUT http://localhost:3000/api/users/profile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"name":"New Name"}'
# Status: ???
```

### Community Endpoints
```bash
# 7. Get Posts (public)
curl http://localhost:3000/api/community/posts
# Status: ???

# 8. Create Post (needs auth)
curl -X POST http://localhost:3000/api/community/posts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"category":"general","title":"Test","content":"Testing"}'
# Status: ???
```

### Career/Module Endpoints
```bash
# 9. Get All Careers
curl http://localhost:3000/api/careers
# Status: ???

# 10. Get All Modules
curl http://localhost:3000/api/learning/modules
# Status: ???

# 11. Get Modules by Career
curl "http://localhost:3000/api/learning/modules?careerId=CAREER_ID_HERE"
# Status: ???
```

---

## 🚨 Critical Information I Need

Please reply with:

### 1. Server Status
```
✅ Server running? YES/NO
✅ Port: 3000 or other?
✅ MongoDB connected? YES/NO
```

### 2. Route Registration
```javascript
// From your server.js or app.js, copy these lines:
app.use('/api/auth', authRoutes);        // ← Exists? YES/NO
app.use('/api/users', userRoutes);       // ← Exists? YES/NO
app.use('/api/community', communityRoutes);  // ← Exists? YES/NO
app.use('/api/careers', careerRoutes);   // ← Exists? YES/NO
app.use('/api/learning', learningRoutes); // ← Exists? YES/NO
```

### 3. Forgot Password Implementation
```javascript
// Do these files exist?
src/models/PasswordReset.js              // ← Exists? YES/NO
src/controllers/authController.js        // ← Has forgotPassword() function? YES/NO
                                         // ← Has resetPassword() function? YES/NO
```

### 4. User Model Fields
```javascript
// From your User model (src/models/User.js):
// Does it have these fields?
- name: String              // ← YES/NO
- username: String          // ← YES/NO
- email: String             // ← YES/NO
- passwordHash: String      // ← YES/NO
```

### 5. Login Response Format
```javascript
// What does your login endpoint return?
// Copy the actual response structure here:
{
  token: "...",
  role: "...",
  user: { ... }  // ← What's inside user object?
}
```

---

## 📝 Quick Test Script for You

Save this as `test-endpoints.sh` and run it:

```bash
#!/bin/bash

echo "🧪 Testing Hakbang Backend Endpoints"
echo "===================================="
echo ""

# Test 1: Login
echo "1️⃣ Testing Login..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@hakbang.com","password":"password123"}')
echo "Response: $LOGIN_RESPONSE"
echo ""

# Extract token (if jq is installed)
TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.token')

# Test 2: Get Current User
echo "2️⃣ Testing Get User..."
curl -s http://localhost:3000/api/users/me \
  -H "Authorization: Bearer $TOKEN"
echo ""
echo ""

# Test 3: Community Posts
echo "3️⃣ Testing Community Posts..."
curl -s http://localhost:3000/api/community/posts
echo ""
echo ""

# Test 4: Forgot Password
echo "4️⃣ Testing Forgot Password..."
curl -s -X POST http://localhost:3000/api/auth/forgot-password \
  -H "Content-Type: application/json" \
  -d '{"email":"test@hakbang.com"}'
echo ""
echo ""

# Test 5: Careers
echo "5️⃣ Testing Get Careers..."
curl -s http://localhost:3000/api/careers
echo ""
echo ""

echo "✅ Test Complete!"
```

Run with:
```bash
chmod +x test-endpoints.sh
./test-endpoints.sh
```

Send me the output!

---

## 🎯 Summary of What I Need

Please send me:

1. ✅ **Curl test results** for all endpoints above
2. ✅ **Server console output** (any errors?)
3. ✅ **Route registration confirmation** (what's in server.js?)
4. ✅ **User model structure** (what fields does User have?)
5. ✅ **Login response format** (what do you return?)
6. ✅ **Forgot password implementation** (files exist?)

---

## 💬 Response Template

Please copy and fill this out:

```markdown
## Backend Status Report

### Server Status
- Server running: YES/NO
- Port: 3000
- MongoDB connected: YES/NO

### Route Registration (server.js)
- app.use('/api/auth', authRoutes): YES/NO
- app.use('/api/users', userRoutes): YES/NO
- app.use('/api/community', communityRoutes): YES/NO
- app.use('/api/careers', careerRoutes): YES/NO
- app.use('/api/learning', learningRoutes): YES/NO

### Forgot Password Files
- src/models/PasswordReset.js: EXISTS/MISSING
- forgotPassword() in authController: EXISTS/MISSING
- resetPassword() in authController: EXISTS/MISSING

### User Model Fields
- name: YES/NO
- username: YES/NO
- email: YES/NO
- passwordHash: YES/NO

### Login Response Format
```json
{
  // Paste your actual login response here
}
```

### Curl Test Results
```bash
# Paste results of test-endpoints.sh here
# OR paste individual curl test results
```

### Errors from Server Console
```
# Paste any errors you see when testing
```
```

---

**Once I get this info, I can**:
1. Fix any remaining frontend issues
2. Tell you exactly what to fix in backend
3. Get everything working together!

**Thank you!** 🙏
