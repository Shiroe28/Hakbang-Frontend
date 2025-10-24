# 🎯 BACKEND FIX PROMPTS - October 24, 2025

## Copy & Paste to Backend Team

---

# PROMPT #1: Community Posts Fix

```
URGENT: Community Posts API Not Loading

Frontend shows: "Failed to load posts. Please try again later."

Fix Required:
GET /api/community/posts must return:

{
  "success": true,
  "data": [
    {
      "_id": "...",
      "title": "Post title",
      "content": "Post content",
      "authorId": "...",
      "authorName": "John Doe",  ← Must populate
      "authorRole": "student",   ← Must populate  
      "createdAt": "2025-10-24T10:30:00.000Z",
      "likes": 5,
      "comments": 3
    }
  ]
}

Controller Code:
exports.getPosts = async (req, res) => {
  const posts = await Post.find()
    .populate('authorId', 'name username role')
    .sort({ createdAt: -1 })
    .lean();

  const formatted = posts.map(post => ({
    _id: post._id,
    title: post.title,
    content: post.content,
    authorId: post.authorId._id,
    authorName: post.authorId.name || post.authorId.username,
    authorRole: post.authorId.role,
    createdAt: post.createdAt,
    likes: post.likes || 0,
    comments: post.comments?.length || 0
  }));

  res.json({ success: true, data: formatted });
};
```

---

# PROMPT #2: Assessment Type Error

```
CRITICAL: Assessment Crashes App

Error: "type 'String' is not a subtype of type 'int'"

Problem: correctOption is STRING but must be INTEGER

WRONG:
{ "correctOption": "1" }  ❌

CORRECT:
{ "correctOption": 1 }  ✅

Fix Schema:
const questionSchema = new mongoose.Schema({
  question: String,
  options: [String],
  correctOption: Number  ← Must be Number
});

OR Fix Controller:
exports.getAssessmentByModuleId = async (req, res) => {
  const assessment = await Assessment.findOne({ 
    moduleId: req.params.moduleId 
  });
  
  const fixed = {
    ...assessment.toObject(),
    questions: assessment.questions.map(q => ({
      ...q,
      correctOption: parseInt(q.correctOption)
    }))
  };

  res.json({ success: true, data: fixed });
};
```

---

# PROMPT #3: Module Filtering

```
CRITICAL: Shows ALL modules instead of filtered by career

Frontend sends: GET /api/learning/modules?careerId=123
Backend returns: All 28 modules (ignores filter)

Fix:
router.get('/modules', async (req, res) => {
  const { careerId } = req.query;
  
  let query = {};
  if (careerId) {
    query.careerId = careerId;
  }
  
  const modules = await Module.find(query);
  res.json({ success: true, data: modules });
});

Verify: All modules have careerId field
```

---

# PROMPT #4: Profile Picture Upload

```
Feature: Add profile picture upload

Install: npm install multer

Code:
const multer = require('multer');

const storage = multer.diskStorage({
  destination: 'uploads/profiles/',
  filename: (req, file, cb) => {
    cb(null, `${req.user._id}${path.extname(file.originalname)}`);
  }
});

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const allowed = ['image/jpeg', 'image/png', 'image/jpg'];
    if (allowed.includes(file.mimetype)) cb(null, true);
    else cb(new Error('Only JPEG/PNG'));
  }
});

router.post('/users/profile-picture',
  authMiddleware,
  upload.single('profilePicture'),
  async (req, res) => {
    const url = `/uploads/profiles/${req.file.filename}`;
    await User.findByIdAndUpdate(req.user._id, { profilePicture: url });
    res.json({ success: true, data: { profilePicture: url } });
  }
);

Add to User schema: profilePicture: String
```

---

# PROMPT #5: Badges & Progress

```
Feature: Track progress and award badges

Update User Schema:
progressSummary: {
  completedModules: { type: Number, default: 0 },
  badgesEarned: { type: Number, default: 0 },
  assessmentsPassed: { type: Number, default: 0 }
},
badges: [{
  title: String,
  description: String,
  icon: String,
  earnedAt: Date
}]

Update Mark Complete:
exports.markModuleComplete = async (req, res) => {
  await User.findByIdAndUpdate(req.user._id, {
    $inc: { 'progressSummary.completedModules': 1 }
  });

  const user = await User.findById(req.user._id);
  if (user.progressSummary.completedModules === 1) {
    await User.findByIdAndUpdate(req.user._id, {
      $push: { badges: {
        title: 'First Steps',
        description: 'First module completed',
        icon: '🎯',
        earnedAt: new Date()
      }},
      $inc: { 'progressSummary.badgesEarned': 1 }
    });
  }
};

Include in GET /api/users/me response
```

---

## Priority

**CRITICAL (App Broken):**
1. Assessment Type Error
2. Community Posts
3. Module Filtering

**IMPORTANT (Features):**
4. Profile Picture
5. Badges & Progress
