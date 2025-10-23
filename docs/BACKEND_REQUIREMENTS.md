# 🔌 Backend API Requirements - Complete List

## Overview
This document lists **ALL** backend endpoints required for the Hakbang Flutter app to work properly.

---

## 🔐 Authentication Endpoints

### 1. Register New User
**POST** `/api/auth/register`

**Request Body:**
```json
{
  "username": "string",
  "email": "string",
  "password": "string",
  "role": "student" | "mentor"
}
```

**Response (200):**
```json
{
  "message": "User registered successfully",
  "user": {
    "_id": "string",
    "username": "string",
    "email": "string",
    "role": "string"
  }
}
```

---

### 2. Login User
**POST** `/api/auth/login`

**Request Body:**
```json
{
  "email": "string",
  "password": "string"
}
```

**Response (200):**
```json
{
  "token": "jwt_token_string",
  "role": "student" | "mentor",
  "user": {
    "_id": "string",
    "username": "string",
    "email": "string",
    "role": "string"
  }
}
```

**Important:** Flutter saves the token and uses it in `Authorization: Bearer {token}` header

---

### 3. Get Current User ⚠️ **CRITICAL**
**GET** `/api/auth/me`

**Headers Required:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Response (200):**
```json
{
  "_id": "string",
  "username": "string",
  "email": "string",
  "role": "string",
  "bio": "string" (optional),
  "createdAt": "date" (optional)
}
```

**Why Critical:** This is called on app startup to load user data. If this fails, Edit Profile won't work!

---

## 🎓 Careers & Learning Endpoints

### 4. Get All Careers
**GET** `/api/careers`

**Headers:** None (public endpoint)

**Response (200):**
```json
[
  {
    "_id": "string",
    "title": "Web Developer",
    "description": "Builds and maintains websites...",
    "salaryRange": "₱30,000 - ₱80,000 per month",
    "icon": "string" (optional)
  }
]
```

---

### 5. Get Learning Modules ⚠️ **MUST FILTER BY CAREER**
**GET** `/api/learning/modules`  
**GET** `/api/learning/modules?careerId={id}`

**Headers:** None (public endpoint)

**Query Parameters:**
- `careerId` (optional) - Filter modules for specific career

**Response (200):**
```json
{
  "data": [
    {
      "_id": "string",
      "title": "Module 1: HTML & CSS Fundamentals",
      "description": "Learn the core building blocks...",
      "careerId": "string",
      "contentType": "link" | "video" | "text",
      "contentURL": "https://...",
      "duration": "2 hours" (optional),
      "order": 1 (optional)
    }
  ]
}
```

**Important Implementation:**
```javascript
// Example Node.js/Express code
app.get('/api/learning/modules', async (req, res) => {
  const { careerId } = req.query;
  
  let query = {};
  if (careerId) {
    query.careerId = careerId; // ⚠️ MUST filter here!
  }
  
  const modules = await Module.find(query);
  res.json({ data: modules });
});
```

---

### 6. Get Single Module
**GET** `/api/learning/modules/:id`

**Headers:** None (public endpoint)

**Response (200):**
```json
{
  "_id": "string",
  "title": "string",
  "description": "string",
  "careerId": "string",
  "contentType": "string",
  "contentURL": "string",
  "duration": "string"
}
```

---

### 7. Mark Module as Complete
**PUT** `/api/learning/modules/:id/progress`

**Headers Required:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "completed": true
}
```

**Response (200):**
```json
{
  "message": "Progress updated",
  "progress": {
    "moduleId": "string",
    "userId": "string",
    "completed": true,
    "completedAt": "date"
  }
}
```

---

## 📝 Assessment/Quiz Endpoints

### 8. Get Module Assessment
**GET** `/api/learning/assessments/module/:moduleId`

**Headers:** None (public endpoint)

**Response (200):**
```json
{
  "_id": "string",
  "title": "HTML5 Basics Quiz",
  "moduleId": "string",
  "questions": [
    {
      "questionText": "What does HTML stand for?",
      "options": [
        "Hyper Text Markup Language",
        "High Tech Modern Language",
        "Home Tool Markup Language",
        "Hyperlinks and Text Markup Language"
      ],
      "correctOption": 0
    }
  ]
}
```

---

### 9. Submit Assessment
**POST** `/api/learning/assessments/:id/submit`

**Headers Required:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "answers": [0, 2, 1, 3]
}
```
*Array of selected option indices*

**Response (200):**
```json
{
  "score": 3,
  "totalQuestions": 4,
  "percentage": 75,
  "passed": true
}
```

---

## 🤖 AI Features Endpoints

### 10. Get AI Career Recommendations
**POST** `/api/ai/recommendations`

**Headers Required:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "quizResponses": [
    {
      "question": "What interests you most?",
      "answer": "Building websites",
      "answerIndex": 0
    },
    {
      "question": "What are your strengths?",
      "answer": "Creative problem solving",
      "answerIndex": 2
    }
  ]
}
```

**Response (200):**
```json
[
  {
    "_id": "string",
    "title": "Web Developer",
    "description": "string",
    "salaryRange": "string",
    "matchPercentage": 85
  },
  {
    "_id": "string",
    "title": "UI/UX Designer",
    "description": "string",
    "salaryRange": "string",
    "matchPercentage": 72
  }
]
```

---

## 👥 Community Endpoints

### 11. Get Community Posts
**GET** `/api/community/posts`

**Headers:** None (public endpoint)

**Query Parameters (optional):**
- `limit` - Number of posts to return
- `skip` - Pagination offset

**Response (200):**
```json
{
  "data": [
    {
      "_id": "string",
      "title": "My First Post",
      "content": "Hello everyone!",
      "authorId": "string",
      "authorName": "John Doe",
      "authorRole": "student",
      "createdAt": "2025-10-16T10:30:00Z",
      "likes": 5,
      "commentsCount": 2
    }
  ]
}
```

**OR simpler format:**
```json
[
  {
    "_id": "string",
    "title": "string",
    "content": "string",
    "author": {
      "username": "string",
      "role": "string"
    },
    "createdAt": "date"
  }
]
```

---

### 12. Create Community Post ⚠️ **NEW - MUST IMPLEMENT**
**POST** `/api/community/posts`

**Headers Required:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "title": "string",
  "content": "string"
}
```

**Response (201):**
```json
{
  "message": "Post created successfully",
  "post": {
    "_id": "string",
    "title": "string",
    "content": "string",
    "authorId": "string",
    "createdAt": "date"
  }
}
```

**Example Node.js Implementation:**
```javascript
router.post('/api/community/posts', authenticateToken, async (req, res) => {
  const { title, content } = req.body;
  const userId = req.user.id; // From JWT token
  
  const post = new Post({
    title,
    content,
    authorId: userId,
    createdAt: new Date()
  });
  
  await post.save();
  res.status(201).json({ message: 'Post created successfully', post });
});
```

---

## 👤 User Profile Endpoints

### 13. Update User Profile
**PUT** `/api/users/profile`

**Headers Required:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "username": "string" (optional),
  "email": "string" (optional),
  "bio": "string" (optional),
  "profilePhoto": "base64_string_or_url" (optional)
}
```

**Response (200):**
```json
{
  "message": "Profile updated successfully",
  "user": {
    "_id": "string",
    "username": "string",
    "email": "string",
    "bio": "string",
    "role": "string"
  }
}
```

---

## 🔒 Authentication Middleware

Your backend needs JWT authentication middleware for protected routes:

```javascript
const jwt = require('jsonwebtoken');

function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN
  
  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }
  
  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid or expired token' });
    }
    req.user = user; // { id, email, role }
    next();
  });
}
```

---

## 📊 Summary Table

| Endpoint | Method | Auth Required | Status | Priority |
|----------|--------|---------------|--------|----------|
| `/api/auth/register` | POST | ❌ | Required | HIGH |
| `/api/auth/login` | POST | ❌ | Required | HIGH |
| `/api/auth/me` | GET | ✅ | **CRITICAL** | **CRITICAL** |
| `/api/careers` | GET | ❌ | Required | HIGH |
| `/api/learning/modules` | GET | ❌ | Required | HIGH |
| `/api/learning/modules?careerId=` | GET | ❌ | **Must Filter** | **HIGH** |
| `/api/learning/modules/:id` | GET | ❌ | Required | MEDIUM |
| `/api/learning/modules/:id/progress` | PUT | ✅ | Required | MEDIUM |
| `/api/learning/assessments/module/:id` | GET | ❌ | Required | MEDIUM |
| `/api/learning/assessments/:id/submit` | POST | ✅ | Required | MEDIUM |
| `/api/ai/recommendations` | POST | ✅ | Required | HIGH |
| `/api/community/posts` | GET | ❌ | Required | HIGH |
| `/api/community/posts` | POST | ✅ | **NEW** | **HIGH** |
| `/api/users/profile` | PUT | ✅ | Required | MEDIUM |

---

## 🚨 Critical Issues to Fix

### 1. ⚠️ `/api/auth/me` - MUST WORK
**Why:** App calls this on startup. If it fails, UserProvider.user stays null and Edit Profile won't work.

**Test it:**
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" http://localhost:3000/api/auth/me
```

**Expected:** Returns user object with username, email, role

---

### 2. ⚠️ `/api/learning/modules?careerId=` - MUST FILTER
**Why:** Without filtering, all careers show all modules.

**Test it:**
```bash
curl "http://localhost:3000/api/learning/modules?careerId=YOUR_CAREER_ID"
```

**Expected:** Returns only modules with matching careerId

**Backend Code:**
```javascript
app.get('/api/learning/modules', async (req, res) => {
  const { careerId } = req.query;
  const filter = careerId ? { careerId } : {};
  const modules = await Module.find(filter);
  res.json({ data: modules });
});
```

---

### 3. ⚠️ `/api/community/posts` POST - MUST CREATE
**Why:** Flutter app now has create post feature that calls this endpoint.

**Test it:**
```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"Test","content":"Hello"}' \
  http://localhost:3000/api/community/posts
```

**Expected:** Creates post and returns 201 status

---

## 📦 What to Send Me

To help you integrate, please send:

### 1. Backend Repository or Code
- GitHub link, or
- Zip file with backend code

### 2. Current Endpoints List
Run this in your backend directory:
```bash
# If using Express
grep -r "app.get\|app.post\|app.put\|app.delete\|router.get\|router.post" . --include="*.js"
```

Or just tell me:
- Which endpoints are already implemented?
- Which ones are missing?

### 3. Database Schema
- User model structure
- Module model structure
- Career model structure
- Post model structure

Example:
```javascript
const UserSchema = {
  _id: ObjectId,
  username: String,
  email: String,
  password: String, // hashed
  role: String,
  createdAt: Date
};
```

### 4. Authentication Details
- Are you using JWT?
- How do you generate tokens?
- What's in the JWT payload?

### 5. Current Issues
- Which endpoints return errors?
- Any CORS issues?
- Any authentication problems?

---

## 🧪 Quick Test Commands

Test your backend with these:

```bash
# 1. Test registration
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@test.com","password":"pass123","role":"student"}'

# 2. Test login (save the token from response)
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"pass123"}'

# 3. Test get current user (replace YOUR_TOKEN)
curl http://localhost:3000/api/auth/me \
  -H "Authorization: Bearer YOUR_TOKEN"

# 4. Test careers
curl http://localhost:3000/api/careers

# 5. Test modules without filter
curl http://localhost:3000/api/learning/modules

# 6. Test modules with filter (replace CAREER_ID)
curl "http://localhost:3000/api/learning/modules?careerId=CAREER_ID"

# 7. Test create post (replace YOUR_TOKEN)
curl -X POST http://localhost:3000/api/community/posts \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Post","content":"Hello World"}'
```

---

## 🎯 Minimum Requirements for App to Work

**Must Have:**
1. ✅ `POST /api/auth/register`
2. ✅ `POST /api/auth/login`
3. ✅ `GET /api/auth/me` ← **CRITICAL**
4. ✅ `GET /api/careers`
5. ✅ `GET /api/learning/modules?careerId=` ← **Must filter**
6. ✅ `POST /api/community/posts` ← **NEW**

**Nice to Have:**
- Module progress tracking
- Assessment/quiz endpoints
- AI recommendations
- Profile update

---

## 📞 Next Steps

1. **Check your backend** against this list
2. **Test critical endpoints** with curl commands
3. **Send me** what's implemented and what's missing
4. **I'll help** integrate or fix any issues

Share your backend code or endpoint list and I'll help you connect everything! 🚀
