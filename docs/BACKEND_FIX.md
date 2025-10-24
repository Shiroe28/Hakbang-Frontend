# � URGENT: Backend Fixes Needed

## 📋 Quick Summary

Testing revealed **4 critical backend issues**:

1. ❌ **Resume AI Feedback** - Returns empty arrays, rating=0 (AI not working)
2. ❌ **Profile Update** - Endpoint failing/doesn't save
3. ❌ **Community Posts** - Not loading (route not registered)
4. ❌ **Module Filtering** - Career shows ALL modules instead of career-specific ones

---

## ❌ ISSUE 1: Resume Feedback Empty/Wrong Format

### What Frontend Gets:
```json
{
  "rating": 0,
  "strengths": [],
  "improvements": [],
  "suggestions": []
}
```

### THE PROBLEM:
- **AI is NOT analyzing the resume!**
- All arrays are EMPTY
- Rating is 0 (should be 1-10)

### What Backend MUST Return:
```json
{
  "rating": 7,
  "strengths": [
    "Clear professional summary",
    "Good technical skills listed",
    "Relevant experience highlighted"
  ],
  "improvements": [
    "Add quantifiable achievements with numbers",
    "Include project links or portfolio",
    "Expand on specific technologies used"
  ],
  "suggestions": [
    "Consider adding certifications section",
    "Include soft skills alongside technical",
    "Add a brief career objective at top"
  ]
}
```

### Backend Needs to Fix:
**File:** Probably `controllers/aiController.js` or similar

**Endpoint:** `POST /api/ai/resume-feedback`

**The AI integration is broken!** Check:
1. Is OpenAI API key set? (`OPENAI_API_KEY` in .env)
2. Is the AI prompt actually sending resume text?
3. Is response being parsed correctly?

**Example Fix:**
```javascript
const analyzeResume = async (req, res) => {
  try {
    const { resumeText } = req.body;
    
    // ✅ Call OpenAI with proper prompt
    const completion = await openai.chat.completions.create({
      model: "gpt-4",
      messages: [{
        role: "system",
        content: "You are an expert resume reviewer. Analyze the resume and provide 3-5 specific strengths, 3-5 areas to improve, and 3-5 actionable suggestions. Rate the resume 1-10."
      }, {
        role: "user",
        content: `Analyze this resume:\n\n${resumeText}`
      }]
    });
    
    // ✅ Parse AI response into arrays
    const analysis = parseAIResponse(completion.choices[0].message.content);
    
    res.json({
      rating: analysis.rating || 5,
      strengths: analysis.strengths || [],
      improvements: analysis.improvements || [],
      suggestions: analysis.suggestions || []
    });
  } catch (error) {
    console.error('AI Error:', error);
    res.status(500).json({ error: error.message });
  }
};
```

### Test Command:
```bash
curl -X POST http://localhost:3000/api/ai/resume-feedback \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "resumeText": "John Doe\nSoftware Developer\n2 years experience\nSkills: JavaScript, React, Node.js"
  }'
```

**Expected:** Arrays with 3-5 items each, rating 1-10

**Priority:** 🔴 **CRITICAL** - Feature completely broken

---

## ❌ ISSUE 2: Profile Update Failing

### Frontend Error:
```
Error updating profile: Exception: Error updating profile: Exception: Failed to update profile
```

### Frontend Sends:
```
PUT /api/users/profile
Headers: {
  "Authorization": "Bearer <token>",
  "Content-Type": "application/json"
}
Body: {
  "username": "Shiroe",
  "email": "sam.richmond.go@gmail.com"
}
```

### THE PROBLEM:
Endpoint either:
- Doesn't exist
- Not registered in routes
- Has validation errors

### Backend Must Implement:

**File:** `routes/userRoutes.js` or `routes/profileRoutes.js`
```javascript
const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/authMiddleware');
const { updateProfile } = require('../controllers/userController');

// ✅ Add this route
router.put('/profile', protect, updateProfile);

module.exports = router;
```

**File:** `controllers/userController.js`
```javascript
const updateProfile = async (req, res) => {
  try {
    const { username, email } = req.body;
    const userId = req.user.id; // From protect middleware
    
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ 
        success: false, 
        error: 'User not found' 
      });
    }
    
    // Update fields
    if (username) user.name = username;
    if (email) user.email = email;
    
    await user.save();
    
    res.json({
      success: true,
      message: 'Profile updated successfully',
      data: {
        _id: user._id,
        name: user.name,
        email: user.email,
        role: user.role
      }
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      error: error.message 
    });
  }
};

module.exports = { updateProfile };
```

**File:** `server.js`
```javascript
// ✅ Make sure routes are registered
const userRoutes = require('./routes/userRoutes');
app.use('/api/users', userRoutes);
```

### Test Command:
```bash
# Login first
TOKEN=$(curl -s -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"sam.richmond.go@gmail.com","password":"yourpass"}' | jq -r '.token')

# Test update
curl -X PUT http://localhost:3000/api/users/profile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"username":"NewName","email":"sam.richmond.go@gmail.com"}'
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    "_id": "...",
    "name": "NewName",
    "email": "sam.richmond.go@gmail.com"
  }
}
```

**Priority:** 🔴 **CRITICAL** - Users can't save profile changes

---

## ❌ ISSUE 3: Community Posts Not Loading

### Frontend Error:
"Failed to load posts. Please try again later."

### Frontend Calls:
```
GET /api/community/posts
```

### THE PROBLEM:
Routes not registered in `server.js`

### Backend Must Fix:

**File:** `server.js`
```javascript
// ✅ ADD THIS LINE
const communityRoutes = require('./routes/communityRoutes');
app.use('/api/community', communityRoutes);
```

**File:** `routes/communityRoutes.js` (if doesn't exist, create it)
```javascript
const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/authMiddleware');
const { 
  getForumPosts, 
  createForumPost 
} = require('../controllers/communityController');

router.get('/posts', getForumPosts);
router.post('/posts', protect, createForumPost);

module.exports = router;
```

**File:** `controllers/communityController.js`
```javascript
const Post = require('../models/Post');

const getForumPosts = async (req, res) => {
  try {
    const posts = await Post.find()
      .populate('authorId', 'name username')
      .sort({ createdAt: -1 });
    
    res.json({
      success: true,
      data: posts
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      error: error.message 
    });
  }
};

const createForumPost = async (req, res) => {
  try {
    const { category, title, content } = req.body;
    
    const post = await Post.create({
      category,
      title,
      content,
      authorId: req.user.id,
      comments: []
    });
    
    res.status(201).json({
      success: true,
      data: post
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      error: error.message 
    });
  }
};

module.exports = { getForumPosts, createForumPost };
```

### Test Commands:
```bash
# Test GET (no auth)
curl http://localhost:3000/api/community/posts

# Test POST (with auth)
TOKEN=$(curl -s -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"sam.richmond.go@gmail.com","password":"yourpass"}' | jq -r '.token')

curl -X POST http://localhost:3000/api/community/posts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"category":"general","title":"Test","content":"Test post"}'
```

**Priority:** 🟡 **MEDIUM** - Feature not accessible

---

## ❌ ISSUE 4: Career Shows ALL Modules Instead of Filtered

### Frontend Request:
```
GET /api/learning/modules?careerId=67891234567890abcdef
```

### THE PROBLEM:
Backend **ignores the careerId parameter** and returns ALL modules in database!

### Root Cause:
Controller doesn't read `req.query.careerId` or doesn't filter by it.

### Backend Must Fix:

**File:** `controllers/learningController.js` (or similar)

**Current (WRONG):**
```javascript
const getModules = async (req, res) => {
  try {
    // ❌ Ignores careerId from query params
    const modules = await Module.find(); // Gets ALL modules
    
    res.json({ success: true, data: modules });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
```

**Should Be (CORRECT):**
```javascript
const getModules = async (req, res) => {
  try {
    const { careerId } = req.query; // ✅ Read from query string
    
    let query = {};
    
    // ✅ Filter by careerId if provided
    if (careerId) {
      query.careerId = careerId;
      console.log(`Filtering modules for career: ${careerId}`);
    } else {
      console.log('Getting all modules (no filter)');
    }
    
    const modules = await Module.find(query);
    
    console.log(`Found ${modules.length} modules`);
    
    res.json({ success: true, data: modules });
  } catch (error) {
    console.error('Get modules error:', error);
    res.status(500).json({ error: error.message });
  }
};
```

### Test Commands:
```bash
# Get ALL modules (no filter)
curl http://localhost:3000/api/learning/modules

# Get modules for specific career ID
curl "http://localhost:3000/api/learning/modules?careerId=YOUR_CAREER_ID"

# COMPARE THE RESULTS:
# - If same number of modules = Backend ignoring filter!
# - If different number = Working correctly!

# Example test:
# 1. GET /api/learning/modules → Returns 50 modules
# 2. GET /api/learning/modules?careerId=123 → Should return 5-10 modules
# If both return 50 = BROKEN!
```

### What It Should Do:
| Request | Expected Behavior |
|---------|-------------------|
| GET /api/learning/modules | Return ALL modules |
| GET /api/learning/modules?careerId=123 | Return ONLY modules where `module.careerId === "123"` |

### How User Sees The Problem:
1. User takes career matching quiz
2. Gets recommendation: "Full Stack Developer"
3. Clicks on career
4. Sees 50+ modules from ALL careers (❌ Wrong!)
5. Should see only 8 modules for Full Stack Developer (✅ Correct)

**Priority:** 🔴 **HIGH** - Major feature broken

---

## ✅ WHAT TO PROMPT BACKEND

Copy/paste this message to your backend developer:

```
Hi Backend Team,

Frontend testing found 4 critical issues:

1. POST /api/ai/resume-feedback
   - AI not working - returns empty arrays
   - Need actual feedback with 3-5 items per array
   - Rating should be 1-10, not 0
   
2. PUT /api/users/profile
   - Returns success but doesn't save to database
   - Need to check if user.save() is working
   - Test: curl update → curl GET /api/users/me → should show new values
   
3. GET /api/community/posts  
   - Routes not registered in server.js
   - Need to add: app.use('/api/community', communityRoutes)

4. GET /api/learning/modules?careerId=123
   - Ignores careerId parameter, returns ALL modules
   - Need to read req.query.careerId and filter Module.find()
   - Test: compare results with and without careerId param

All test commands and code examples in: Frontend/docs/BACKEND_FIX.md

Please test ALL with curl before marking as done!
```

---

## 🧪 How to Verify

After backend fixes each:

1. **Resume:** Fill form → Get AI Feedback → See bullet points
2. **Profile:** Edit → Change name → Save → Reload → See new name
3. **Community:** Open tab → See posts → Can create new post
4. **Career:** Take quiz → Click career → See only that career's modules

**Test ALL with curl first, then tell frontend to test!**
```bash
flutter run -d chrome
```

## Test Registration Again

1. **Hot reload** the app (press `r` in terminal)
2. **Go back to registration screen** (refresh browser or navigate)
3. **Fill in the form:**
   - Username: `john_doe`
   - Email: `john@test.com`
   - Password: `password123`
   - Role: Student
4. **Click Register** - Should work now! ✅

## What the Backend Expects

```json
{
  "name": "john_doe",      // ✅ Correct field name
  "email": "john@test.com",
  "password": "password123",
  "role": "student"
}
```

## Expected Response

**Success:**
```json
{
  "_id": "...",
  "name": "john_doe",
  "email": "john@test.com",
  "role": "student"
}
```

Then auto-login returns:
```json
{
  "token": "eyJhbGc...",
  "role": "student",
  "user": {
    "name": "john_doe",
    "email": "john@test.com"
  }
}
```

## Backend API Reference

Your backend schema uses `name`, not `username`:
```javascript
// Backend User Schema
{
  name: { type: String, required: true },      // ✅ Required!
  email: { type: String, required: true },
  password: { type: String, required: true },
  role: { type: String, enum: ['student', 'mentor'] }
}
```

## Quick Test Checklist

After hot reload:
- [ ] Press `r` in terminal to hot reload
- [ ] Open registration screen
- [ ] Fill in all fields
- [ ] Click "Register"
- [ ] Should see success and auto-login to dashboard ✅
- [ ] Username should display correctly on dashboard

## If Hot Reload Doesn't Show Changes

Sometimes structural changes need a hot restart:
1. Press `R` (capital R) in terminal
2. Or stop (`q`) and restart: `flutter run -d chrome`

---

**The fix is applied! Press `r` in your terminal to hot reload and test registration again!** 🚀
