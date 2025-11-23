# 🏆 Complete Backend Implementation: All Achievements System

## 📋 Overview

This document contains **ALL backend requirements** to make the complete badge/achievement system work with the Flutter frontend.

---

## 🎯 What You Need to Implement

### 1. User Progress Tracking (CRITICAL)
### 2. Badge System (9 Badge Types)
### 3. Notification System
### 4. Progress Summary Endpoint

---

# Part 1: User Progress Tracking 🔄

## Endpoint: GET /api/users/progress/:careerId

**Purpose:** Frontend needs to know which modules are completed to show checkmarks

### Controller: `usersController.js`

```javascript
exports.getUserProgress = async (req, res) => {
  try {
    const { careerId } = req.params;
    const userId = req.user._id;

    const userProgress = await UserProgress.findOne({ 
      userId, 
      careerId 
    }).populate('moduleProgress.moduleId');

    if (!userProgress) {
      return res.json({
        success: true,
        data: {
          careerId,
          completedModules: [],
          moduleProgress: [],
          totalCompleted: 0
        }
      });
    }

    return res.json({
      success: true,
      data: {
        careerId: userProgress.careerId,
        completedModules: userProgress.moduleProgress
          .filter(mp => mp.completed)
          .map(mp => mp.moduleId),
        moduleProgress: userProgress.moduleProgress.map(mp => ({
          moduleId: mp.moduleId,
          completed: mp.completed,
          completedAt: mp.completedAt
        })),
        totalCompleted: userProgress.moduleProgress.filter(mp => mp.completed).length
      }
    });

  } catch (error) {
    console.error('Error fetching user progress:', error);
    return res.status(500).json({
      success: false,
      error: 'Failed to fetch user progress'
    });
  }
};
```

### Route: `routes/users.js`

```javascript
router.get('/progress/:careerId', authenticate, usersController.getUserProgress);
```

### Test:

```bash
curl -X GET http://localhost:3000/api/users/progress/CAREER_ID \
  -H "Authorization: Bearer YOUR_TOKEN"

# Expected response:
# {
#   "success": true,
#   "data": {
#     "careerId": "...",
#     "completedModules": ["moduleId1", "moduleId2"],
#     "moduleProgress": [
#       {
#         "moduleId": "moduleId1",
#         "completed": true,
#         "completedAt": "2025-11-23T..."
#       }
#     ],
#     "totalCompleted": 2
#   }
# }
```

---

# Part 2: Complete Badge System 🏆

## 9 Badge Types to Implement

### Badge Configuration

Create `services/badgeService.js`:

```javascript
const BADGES = {
  // Assessment Badges
  FIRST_STEPS: {
    id: 'first_steps',
    title: 'First Steps',
    description: 'Passed your first assessment',
    icon: '🎉',
    points: 50,
    category: 'assessment'
  },
  PERFECTIONIST: {
    id: 'perfectionist',
    title: 'Perfectionist',
    description: 'Achieved a perfect 100% score',
    icon: '💯',
    points: 50,
    category: 'assessment'
  },
  SPEED_DEMON: {
    id: 'speed_demon',
    title: 'Speed Demon',
    description: 'Completed assessment in under 5 minutes',
    icon: '⚡',
    points: 75,
    category: 'assessment'
  },
  RISING_STAR: {
    id: 'rising_star',
    title: 'Rising Star',
    description: 'Passed 5 assessments',
    icon: '⭐',
    points: 150,
    category: 'assessment'
  },

  // Module Completion Badges
  MODULE_STARTER: {
    id: 'module_starter',
    title: 'Module Starter',
    description: 'Completed your first module',
    icon: '📚',
    points: 30,
    category: 'module'
  },
  MODULE_ENTHUSIAST: {
    id: 'module_enthusiast',
    title: 'Module Enthusiast',
    description: 'Completed 10 modules',
    icon: '🎓',
    points: 200,
    category: 'module'
  },
  HTML_MASTER: {
    id: 'html_master',
    title: 'HTML Master',
    description: 'Completed all HTML modules',
    icon: '🏆',
    points: 200,
    category: 'module'
  },
  COURSE_CHAMPION: {
    id: 'course_champion',
    title: 'Course Champion',
    description: 'Completed an entire career path',
    icon: '👑',
    points: 500,
    category: 'career'
  },

  // Streak Badge
  WEEK_WARRIOR: {
    id: 'week_warrior',
    title: 'Week Warrior',
    description: '7 day learning streak',
    icon: '🔥',
    points: 150,
    category: 'streak'
  }
};

// Check if user already has this badge
function hasBadge(user, badgeId) {
  return user.badges && user.badges.some(b => b.id === badgeId);
}

// Award badge to user
async function awardBadge(userId, badge) {
  const User = require('../models/User');
  
  const user = await User.findById(userId);
  
  if (hasBadge(user, badge.id)) {
    return { badgeEarned: false };
  }

  // Add badge to user
  user.badges = user.badges || [];
  user.badges.push({
    id: badge.id,
    title: badge.title,
    description: badge.description,
    icon: badge.icon,
    points: badge.points,
    earnedAt: new Date()
  });

  // Update total points
  user.totalPoints = (user.totalPoints || 0) + badge.points;

  await user.save();

  return {
    badgeEarned: true,
    badge: {
      id: badge.id,
      title: badge.title,
      description: badge.description,
      icon: badge.icon,
      points: badge.points,
      earnedAt: new Date()
    }
  };
}

// Check assessment badges
async function checkAssessmentBadges(userId, assessmentResult) {
  const User = require('../models/User');
  const Assessment = require('../models/Assessment');
  
  const user = await User.findById(userId);
  const earnedBadges = [];

  // Count passed assessments
  const passedCount = await Assessment.countDocuments({
    userId,
    passed: true
  });

  // First Steps - First passed assessment
  if (passedCount === 1 && !hasBadge(user, BADGES.FIRST_STEPS.id)) {
    const result = await awardBadge(userId, BADGES.FIRST_STEPS);
    if (result.badgeEarned) earnedBadges.push(result.badge);
  }

  // Perfectionist - 100% score
  if (assessmentResult.percentage === 100 && !hasBadge(user, BADGES.PERFECTIONIST.id)) {
    const result = await awardBadge(userId, BADGES.PERFECTIONIST);
    if (result.badgeEarned) earnedBadges.push(result.badge);
  }

  // Speed Demon - Under 5 minutes
  if (assessmentResult.completionTime && assessmentResult.completionTime < 300000) { // 5 min in ms
    if (!hasBadge(user, BADGES.SPEED_DEMON.id)) {
      const result = await awardBadge(userId, BADGES.SPEED_DEMON);
      if (result.badgeEarned) earnedBadges.push(result.badge);
    }
  }

  // Rising Star - 5 passed assessments
  if (passedCount === 5 && !hasBadge(user, BADGES.RISING_STAR.id)) {
    const result = await awardBadge(userId, BADGES.RISING_STAR);
    if (result.badgeEarned) earnedBadges.push(result.badge);
  }

  return earnedBadges;
}

// Check module completion badges
async function checkModuleBadges(userId, moduleId) {
  const User = require('../models/User');
  const UserProgress = require('../models/UserProgress');
  const Module = require('../models/Module');
  
  const user = await User.findById(userId);
  const earnedBadges = [];

  // Count total completed modules across all careers
  const allProgress = await UserProgress.find({ userId });
  let totalCompleted = 0;
  
  for (const progress of allProgress) {
    totalCompleted += progress.moduleProgress.filter(mp => mp.completed).length;
  }

  console.log(`User has completed ${totalCompleted} modules total`);

  // Module Starter - First module
  if (totalCompleted === 1 && !hasBadge(user, BADGES.MODULE_STARTER.id)) {
    const result = await awardBadge(userId, BADGES.MODULE_STARTER);
    if (result.badgeEarned) earnedBadges.push(result.badge);
  }

  // Module Enthusiast - 10 modules
  if (totalCompleted === 10 && !hasBadge(user, BADGES.MODULE_ENTHUSIAST.id)) {
    const result = await awardBadge(userId, BADGES.MODULE_ENTHUSIAST);
    if (result.badgeEarned) earnedBadges.push(result.badge);
  }

  // HTML Master - All HTML modules completed
  const module = await Module.findById(moduleId);
  if (module && module.title.toLowerCase().includes('html')) {
    const allHtmlModules = await Module.find({ 
      title: { $regex: /html/i } 
    });
    
    let completedHtmlCount = 0;
    for (const progress of allProgress) {
      for (const mp of progress.moduleProgress) {
        if (mp.completed) {
          const mod = await Module.findById(mp.moduleId);
          if (mod && mod.title.toLowerCase().includes('html')) {
            completedHtmlCount++;
          }
        }
      }
    }

    if (completedHtmlCount === allHtmlModules.length && 
        !hasBadge(user, BADGES.HTML_MASTER.id)) {
      const result = await awardBadge(userId, BADGES.HTML_MASTER);
      if (result.badgeEarned) earnedBadges.push(result.badge);
    }
  }

  // Course Champion - Check if entire career is complete
  const currentModule = await Module.findById(moduleId);
  if (currentModule) {
    const careerModules = await Module.find({ careerId: currentModule.careerId });
    const careerProgress = await UserProgress.findOne({ 
      userId, 
      careerId: currentModule.careerId 
    });
    
    if (careerProgress) {
      const completedInCareer = careerProgress.moduleProgress.filter(mp => mp.completed).length;
      
      if (completedInCareer === careerModules.length && 
          !hasBadge(user, BADGES.COURSE_CHAMPION.id)) {
        const result = await awardBadge(userId, BADGES.COURSE_CHAMPION);
        if (result.badgeEarned) earnedBadges.push(result.badge);
      }
    }
  }

  return earnedBadges;
}

module.exports = {
  BADGES,
  hasBadge,
  awardBadge,
  checkAssessmentBadges,
  checkModuleBadges
};
```

---

## Update User Model

Add to `models/User.js`:

```javascript
const userSchema = new mongoose.Schema({
  // ... existing fields ...
  
  badges: [{
    id: String,
    title: String,
    description: String,
    icon: String,
    points: Number,
    earnedAt: Date
  }],
  
  totalPoints: {
    type: Number,
    default: 0
  },
  
  lastActivityDate: {
    type: Date,
    default: null
  },
  
  learningStreak: {
    type: Number,
    default: 0
  }
});
```

---

## Update Assessment Submit Endpoint

In `learningController.js`:

```javascript
const { checkAssessmentBadges } = require('../services/badgeService');

exports.submitAssessment = async (req, res) => {
  try {
    const { assessmentId } = req.params;
    const { answers, careerId } = req.body;
    const userId = req.user._id;

    // ... existing assessment grading logic ...
    
    const percentage = (score / totalQuestions) * 100;
    const passed = percentage >= 70;

    // Calculate completion time if you have startTime
    const completionTime = req.body.completionTime; // Frontend can send this

    // Save assessment result
    const assessment = new Assessment({
      userId,
      assessmentId,
      answers,
      score,
      totalQuestions,
      percentage,
      passed,
      completionTime,
      submittedAt: new Date()
    });
    
    await assessment.save();

    // Check for badges if passed
    let earnedBadges = [];
    if (passed) {
      earnedBadges = await checkAssessmentBadges(userId, {
        percentage,
        completionTime
      });
    }

    return res.json({
      success: true,
      data: {
        score,
        totalQuestions,
        percentage,
        passed,
        correctAnswers,
        badgeEarned: earnedBadges.length > 0,
        badge: earnedBadges[0] || null,
        newBadgeEarned: earnedBadges.length > 0, // For compatibility
        badges: earnedBadges
      }
    });

  } catch (error) {
    console.error('Error submitting assessment:', error);
    return res.status(500).json({
      success: false,
      error: 'Failed to submit assessment'
    });
  }
};
```

---

## Update Module Progress Endpoint

In `learningController.js`:

```javascript
const { checkModuleBadges } = require('../services/badgeService');

exports.updateModuleProgress = async (req, res) => {
  try {
    const { moduleId } = req.params;
    const { careerId, completed } = req.body;
    const userId = req.user._id;

    if (!careerId) {
      return res.status(400).json({
        success: false,
        error: 'Career ID is required'
      });
    }

    // Find or create UserProgress
    let userProgress = await UserProgress.findOne({ userId, careerId });

    if (!userProgress) {
      userProgress = new UserProgress({
        userId,
        careerId,
        moduleProgress: []
      });
    }

    // Find existing progress entry
    const existingProgress = userProgress.moduleProgress.find(
      mp => mp.moduleId.toString() === moduleId
    );

    if (existingProgress) {
      existingProgress.completed = completed;
      existingProgress.completedAt = completed ? new Date() : null;
    } else {
      userProgress.moduleProgress.push({
        moduleId,
        completed: completed,
        completedAt: completed ? new Date() : null
      });
    }

    await userProgress.save();

    // Check for badges ONLY if marking as complete
    let earnedBadges = [];
    if (completed) {
      earnedBadges = await checkModuleBadges(userId, moduleId);
      
      // Update user's last activity for streak tracking
      const user = await User.findById(userId);
      user.lastActivityDate = new Date();
      await user.save();
    }

    return res.json({
      success: true,
      message: completed 
        ? 'Module marked as complete' 
        : 'Module marked as incomplete',
      data: {
        badgeEarned: earnedBadges.length > 0,
        badge: earnedBadges[0] || null,
        badges: earnedBadges
      }
    });

  } catch (error) {
    console.error('Error updating module progress:', error);
    return res.status(500).json({
      success: false,
      error: 'Failed to update module progress'
    });
  }
};
```

---

# Part 3: Notification System 🔔

Already covered in previous document, but here's the summary:

## Endpoints Needed:

1. `POST /api/notifications` - Create notification
2. `GET /api/notifications` - Get user notifications
3. `PUT /api/notifications/:id/read` - Mark as read

## Model: `models/Notification.js`

```javascript
const notificationSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
  title: { type: String, required: true },
  message: { type: String, required: true },
  type: { type: String, enum: ['badge', 'milestone', 'system', 'update'], required: true },
  isRead: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now, index: true }
});

notificationSchema.index({ userId: 1, createdAt: -1 });
```

See `BACKEND_TOGGLE_COMPLETE_AND_NOTIFICATIONS.md` for complete code.

---

# Part 4: User Badges Endpoint 🏅

## Endpoint: GET /api/users/badges

In `usersController.js`:

```javascript
exports.getUserBadges = async (req, res) => {
  try {
    const userId = req.user._id;
    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    return res.json({
      success: true,
      data: {
        badges: user.badges || [],
        totalPoints: user.totalPoints || 0,
        totalBadges: (user.badges || []).length
      }
    });

  } catch (error) {
    console.error('Error fetching user badges:', error);
    return res.status(500).json({
      success: false,
      error: 'Failed to fetch badges'
    });
  }
};
```

---

# 🧪 Complete Testing Guide

## Test 1: Module Completion & Badges

```bash
# Mark first module complete
curl -X PUT http://localhost:3000/api/learning/modules/MODULE_ID/progress \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"careerId": "CAREER_ID", "completed": true}'

# Expected: Module Starter badge awarded
# {
#   "success": true,
#   "data": {
#     "badgeEarned": true,
#     "badge": {
#       "id": "module_starter",
#       "title": "Module Starter",
#       "icon": "📚",
#       "points": 30
#     }
#   }
# }
```

## Test 2: Get User Progress

```bash
curl -X GET http://localhost:3000/api/users/progress/CAREER_ID \
  -H "Authorization: Bearer TOKEN"

# Expected:
# {
#   "success": true,
#   "data": {
#     "careerId": "...",
#     "completedModules": ["moduleId1"],
#     "totalCompleted": 1
#   }
# }
```

## Test 3: Assessment with Badge

```bash
curl -X POST http://localhost:3000/api/learning/assessments/ASSESSMENT_ID/submit \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "answers": [0, 1, 2, 3, 4],
    "careerId": "CAREER_ID"
  }'

# Expected if 100%: Perfectionist badge
# Expected if first pass: First Steps badge
```

## Test 4: Get All Badges

```bash
curl -X GET http://localhost:3000/api/users/badges \
  -H "Authorization: Bearer TOKEN"

# Expected:
# {
#   "success": true,
#   "data": {
#     "badges": [
#       {
#         "id": "module_starter",
#         "title": "Module Starter",
#         "icon": "📚",
#         "points": 30,
#         "earnedAt": "2025-11-23T..."
#       }
#     ],
#     "totalPoints": 30,
#     "totalBadges": 1
#   }
# }
```

---

# 📊 Implementation Checklist

## Must Have (Critical for App to Work):

- [ ] Update User model with badges, totalPoints, lastActivityDate, learningStreak
- [ ] Create badgeService.js with all 9 badge types
- [ ] Add GET /api/users/progress/:careerId endpoint
- [ ] Update PUT /api/learning/modules/:id/progress to:
  - [ ] Accept `completed` field (true/false)
  - [ ] Check badges when completing
  - [ ] Return badge data
- [ ] Update POST /api/learning/assessments/:id/submit to:
  - [ ] Check badges when passing
  - [ ] Return badge data
- [ ] Add GET /api/users/badges endpoint
- [ ] Create Notification model
- [ ] Add POST /api/notifications endpoint
- [ ] Add GET /api/notifications endpoint
- [ ] Add PUT /api/notifications/:id/read endpoint

## Optional (Nice to Have):

- [ ] Implement Week Warrior streak badge logic
- [ ] Add badge analytics endpoint
- [ ] Add leaderboard endpoint
- [ ] Email notifications for badges

---

# ⏰ Time Estimates

| Task | Time | Priority |
|------|------|----------|
| Update User model | 5 min | 🔴 Critical |
| Create badgeService.js | 20 min | 🔴 Critical |
| Update assessment endpoint | 10 min | 🔴 Critical |
| Update module progress endpoint | 10 min | 🔴 Critical |
| Add user progress endpoint | 10 min | 🔴 Critical |
| Add user badges endpoint | 5 min | 🔴 Critical |
| Create Notification model | 5 min | 🟡 Important |
| Add notification endpoints | 15 min | 🟡 Important |
| Testing | 15 min | 🟡 Important |

**Total Critical:** ~60 minutes
**Total with Notifications:** ~95 minutes

---

# 🆘 Quick Help

### "Badge not awarded"
- Check console logs: `console.log('Checking badges...')`
- Verify badge count: `totalCompleted === 1` for first module
- Check `hasBadge()` function returns false
- Verify User model has badges array

### "Module completion not persisting"
- Check UserProgress is being saved: `await userProgress.save()`
- Verify `completed` field in request body
- Check careerId matches

### "Progress endpoint returns empty"
- Return empty object if no progress (don't error)
- Check authentication middleware
- Verify careerId parameter

---

# 📝 All Routes Summary

```javascript
// In routes/users.js
router.get('/progress/:careerId', authenticate, usersController.getUserProgress);
router.get('/badges', authenticate, usersController.getUserBadges);

// In routes/learning.js
router.put('/modules/:moduleId/progress', authenticate, learningController.updateModuleProgress);
router.post('/assessments/:assessmentId/submit', authenticate, learningController.submitAssessment);

// In routes/notifications.js
router.post('/', authenticate, notificationsController.createNotification);
router.get('/', authenticate, notificationsController.getUserNotifications);
router.put('/:notificationId/read', authenticate, notificationsController.markAsRead);
```

---

**Status:** Ready for Implementation
**Frontend:** ✅ Complete and Waiting
**Backend:** ⏳ Needs Implementation
**Time Required:** ~95 minutes total

Copy this entire file and implement section by section! 🚀
