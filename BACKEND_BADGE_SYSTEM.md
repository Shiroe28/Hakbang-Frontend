# 🏆 Complete Badge System - Backend Implementation

## Overview
This document contains the complete backend code to implement all badge types that award badges when users:
- Pass assessments (≥70%)
- Mark modules as complete
- Achieve perfect scores
- Complete quickly
- Build streaks
- Complete career paths

---

## 📋 Step 1: Update User Schema

Add these fields to your User model (e.g., `models/User.js`):

```javascript
const mongoose = require('mongoose');

const badgeSchema = new mongoose.Schema({
  id: { type: String, required: true },
  title: { type: String, required: true },
  description: { type: String, required: true },
  icon: { type: String, required: true },
  earnedAt: { type: Date, default: Date.now },
  points: { type: Number, default: 0 }
});

const userSchema = new mongoose.Schema({
  // ... existing fields (username, email, password, etc.)
  
  progressSummary: {
    totalModules: { type: Number, default: 0 },
    completedModules: { type: Number, default: 0 },
    badgesEarned: { type: Number, default: 0 },
    assessmentsPassed: { type: Number, default: 0 },
    currentStreak: { type: Number, default: 0 },
    lastActivityDate: { type: Date },
  },
  
  badges: [badgeSchema],
  totalPoints: { type: Number, default: 0 },
  
  completedModuleIds: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Module' }],
  
  assessmentHistory: [{
    assessmentId: { type: mongoose.Schema.Types.ObjectId, ref: 'Assessment' },
    moduleId: { type: mongoose.Schema.Types.ObjectId, ref: 'Module' },
    score: Number,
    total: Number,
    percentage: Number,
    passed: Boolean,
    completedAt: Date,
    completionTime: Number, // in seconds
  }]
}, {
  timestamps: true
});

module.exports = mongoose.model('User', userSchema);
```

---

## 📋 Step 2: Create Badge Service

Create `services/badgeService.js`:

```javascript
// services/badgeService.js

const User = require('../models/User');
const Module = require('../models/Module');

// Badge Definitions
const BADGES = {
  FIRST_STEPS: {
    id: 'first_steps',
    title: 'First Steps',
    description: 'Passed your first assessment',
    icon: '🎉',
    points: 50,
  },
  PERFECTIONIST: {
    id: 'perfectionist',
    title: 'Perfectionist',
    description: 'Achieved 100% on an assessment',
    icon: '💯',
    points: 100,
  },
  SPEED_DEMON: {
    id: 'speed_demon',
    title: 'Speed Demon',
    description: 'Completed assessment in under 5 minutes',
    icon: '⚡',
    points: 75,
  },
  RISING_STAR: {
    id: 'rising_star',
    title: 'Rising Star',
    description: 'Passed 5 assessments',
    icon: '⭐',
    points: 150,
  },
  HTML_MASTER: {
    id: 'html_master',
    title: 'HTML Master',
    description: 'Completed all HTML modules',
    icon: '🏆',
    points: 200,
  },
  MODULE_STARTER: {
    id: 'module_starter',
    title: 'Module Starter',
    description: 'Completed your first module',
    icon: '📚',
    points: 30,
  },
  MODULE_ENTHUSIAST: {
    id: 'module_enthusiast',
    title: 'Module Enthusiast',
    description: 'Completed 10 modules',
    icon: '🎓',
    points: 200,
  },
  WEEK_WARRIOR: {
    id: 'week_warrior',
    title: 'Week Warrior',
    description: '7 day learning streak',
    icon: '🔥',
    points: 150,
  },
  COURSE_CHAMPION: {
    id: 'course_champion',
    title: 'Course Champion',
    description: 'Completed all modules in a career path',
    icon: '👑',
    points: 500,
  }
};

/**
 * Check if user has already earned a badge
 */
function hasBadge(user, badgeId) {
  return user.badges.some(badge => badge.id === badgeId);
}

/**
 * Award a badge to a user
 */
async function awardBadge(userId, badgeDefinition) {
  try {
    const user = await User.findById(userId);
    
    // Check if already has badge
    if (hasBadge(user, badgeDefinition.id)) {
      return { badgeEarned: false };
    }
    
    // Add badge
    const newBadge = {
      id: badgeDefinition.id,
      title: badgeDefinition.title,
      description: badgeDefinition.description,
      icon: badgeDefinition.icon,
      earnedAt: new Date(),
      points: badgeDefinition.points,
    };
    
    user.badges.push(newBadge);
    user.progressSummary.badgesEarned = user.badges.length;
    user.totalPoints = (user.totalPoints || 0) + badgeDefinition.points;
    
    await user.save();
    
    console.log(`🏆 Badge awarded: ${badgeDefinition.title} to user ${userId}`);
    
    return {
      badgeEarned: true,
      badge: newBadge,
    };
  } catch (error) {
    console.error('Error awarding badge:', error);
    return { badgeEarned: false, error: error.message };
  }
}

/**
 * Check and award badges after assessment
 */
async function checkAssessmentBadges(userId, assessmentData) {
  const user = await User.findById(userId);
  const earnedBadges = [];
  
  const { score, total, percentage, completionTime } = assessmentData;
  
  // 1. First Steps - First assessment passed
  if (user.progressSummary.assessmentsPassed === 1 && !hasBadge(user, BADGES.FIRST_STEPS.id)) {
    const result = await awardBadge(userId, BADGES.FIRST_STEPS);
    if (result.badgeEarned) earnedBadges.push(result.badge);
  }
  
  // 2. Perfectionist - 100% score
  if (percentage === 100 && !hasBadge(user, BADGES.PERFECTIONIST.id)) {
    const result = await awardBadge(userId, BADGES.PERFECTIONIST);
    if (result.badgeEarned) earnedBadges.push(result.badge);
  }
  
  // 3. Speed Demon - Completed in under 5 minutes (300 seconds)
  if (completionTime && completionTime < 300 && percentage >= 70 && !hasBadge(user, BADGES.SPEED_DEMON.id)) {
    const result = await awardBadge(userId, BADGES.SPEED_DEMON);
    if (result.badgeEarned) earnedBadges.push(result.badge);
  }
  
  // 4. Rising Star - 5 assessments passed
  if (user.progressSummary.assessmentsPassed === 5 && !hasBadge(user, BADGES.RISING_STAR.id)) {
    const result = await awardBadge(userId, BADGES.RISING_STAR);
    if (result.badgeEarned) earnedBadges.push(result.badge);
  }
  
  return earnedBadges;
}

/**
 * Check and award badges after module completion
 */
async function checkModuleBadges(userId, moduleId) {
  const user = await User.findById(userId);
  const module = await Module.findById(moduleId);
  const earnedBadges = [];
  
  // 1. Module Starter - First module completed
  if (user.progressSummary.completedModules === 1 && !hasBadge(user, BADGES.MODULE_STARTER.id)) {
    const result = await awardBadge(userId, BADGES.MODULE_STARTER);
    if (result.badgeEarned) earnedBadges.push(result.badge);
  }
  
  // 2. Module Enthusiast - 10 modules completed
  if (user.progressSummary.completedModules === 10 && !hasBadge(user, BADGES.MODULE_ENTHUSIAST.id)) {
    const result = await awardBadge(userId, BADGES.MODULE_ENTHUSIAST);
    if (result.badgeEarned) earnedBadges.push(result.badge);
  }
  
  // 3. HTML Master - All HTML modules completed
  if (module && module.title.toLowerCase().includes('html')) {
    const allHtmlModules = await Module.find({ 
      title: { $regex: /html/i } 
    });
    
    const completedHtmlModules = allHtmlModules.filter(m => 
      user.completedModuleIds.some(id => id.toString() === m._id.toString())
    );
    
    if (completedHtmlModules.length === allHtmlModules.length && 
        allHtmlModules.length > 0 && 
        !hasBadge(user, BADGES.HTML_MASTER.id)) {
      const result = await awardBadge(userId, BADGES.HTML_MASTER);
      if (result.badgeEarned) earnedBadges.push(result.badge);
    }
  }
  
  // 4. Course Champion - All modules in a career completed
  if (module && module.careerId) {
    const careerModules = await Module.find({ careerId: module.careerId });
    const completedCareerModules = careerModules.filter(m =>
      user.completedModuleIds.some(id => id.toString() === m._id.toString())
    );
    
    if (completedCareerModules.length === careerModules.length && 
        careerModules.length > 0 && 
        !hasBadge(user, BADGES.COURSE_CHAMPION.id)) {
      const result = await awardBadge(userId, BADGES.COURSE_CHAMPION);
      if (result.badgeEarned) earnedBadges.push(result.badge);
    }
  }
  
  return earnedBadges;
}

/**
 * Update streak and check streak badges
 */
async function updateStreak(userId) {
  const user = await User.findById(userId);
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  
  const lastActivity = user.progressSummary.lastActivityDate 
    ? new Date(user.progressSummary.lastActivityDate)
    : null;
  
  if (lastActivity) {
    lastActivity.setHours(0, 0, 0, 0);
    const daysDiff = Math.floor((today - lastActivity) / (1000 * 60 * 60 * 24));
    
    if (daysDiff === 0) {
      // Same day, no change to streak
      return [];
    } else if (daysDiff === 1) {
      // Consecutive day, increment streak
      user.progressSummary.currentStreak += 1;
    } else {
      // Streak broken, reset to 1
      user.progressSummary.currentStreak = 1;
    }
  } else {
    // First activity
    user.progressSummary.currentStreak = 1;
  }
  
  user.progressSummary.lastActivityDate = new Date();
  await user.save();
  
  // Check for Week Warrior badge
  const earnedBadges = [];
  if (user.progressSummary.currentStreak === 7 && !hasBadge(user, BADGES.WEEK_WARRIOR.id)) {
    const result = await awardBadge(userId, BADGES.WEEK_WARRIOR);
    if (result.badgeEarned) earnedBadges.push(result.badge);
  }
  
  return earnedBadges;
}

module.exports = {
  BADGES,
  awardBadge,
  checkAssessmentBadges,
  checkModuleBadges,
  updateStreak,
};
```

---

## 📋 Step 3: Update Assessment Submit Endpoint

Update your assessment submit controller (e.g., `controllers/learningController.js`):

```javascript
const User = require('../models/User');
const Assessment = require('../models/Assessment');
const { checkAssessmentBadges, updateStreak } = require('../services/badgeService');

exports.submitAssessment = async (req, res) => {
  try {
    const { assessmentId } = req.params;
    const { answers, careerId } = req.body;
    const userId = req.user._id;
    
    const startTime = Date.now();
    
    // Find assessment
    const assessment = await Assessment.findById(assessmentId);
    if (!assessment) {
      return res.status(404).json({ 
        success: false, 
        error: 'Assessment not found' 
      });
    }
    
    // Calculate score
    let score = 0;
    const results = assessment.questions.map((question, index) => {
      const userAnswer = answers[index];
      const isCorrect = userAnswer === question.correctAnswer;
      if (isCorrect) score++;
      
      return {
        questionIndex: index,
        userAnswer,
        correctAnswer: question.correctAnswer,
        isCorrect,
      };
    });
    
    const total = assessment.questions.length;
    const percentage = Math.round((score / total) * 100);
    const passed = percentage >= 70;
    
    const completionTime = Math.floor((Date.now() - startTime) / 1000); // in seconds
    
    // Update user progress
    const user = await User.findById(userId);
    
    // Add to assessment history
    user.assessmentHistory.push({
      assessmentId,
      moduleId: assessment.moduleId,
      score,
      total,
      percentage,
      passed,
      completedAt: new Date(),
      completionTime,
    });
    
    // Increment assessments passed counter if passed
    if (passed) {
      user.progressSummary.assessmentsPassed += 1;
    }
    
    await user.save();
    
    // Update streak
    const streakBadges = await updateStreak(userId);
    
    // Check for badges
    const assessmentBadges = await checkAssessmentBadges(userId, {
      score,
      total,
      percentage,
      completionTime,
    });
    
    const allEarnedBadges = [...assessmentBadges, ...streakBadges];
    
    // Prepare response
    const responseData = {
      score,
      total,
      percentage,
      passed,
      results,
      feedback: passed 
        ? `Great job! You scored ${percentage}%` 
        : `You scored ${percentage}%. Try again to pass (70% required).`,
    };
    
    // Add badge info if any badges earned
    if (allEarnedBadges.length > 0) {
      responseData.badgeEarned = true;
      responseData.badge = allEarnedBadges[0]; // Return first badge
      responseData.allBadgesEarned = allEarnedBadges; // All badges earned
    }
    
    res.json({
      success: true,
      data: responseData,
    });
    
  } catch (error) {
    console.error('❌ Submit assessment error:', error);
    res.status(500).json({ 
      success: false, 
      error: error.message 
    });
  }
};
```

---

## 📋 Step 4: Update Mark Module Complete Endpoint

Update your module completion controller:

```javascript
const User = require('../models/User');
const Module = require('../models/Module');
const { checkModuleBadges, updateStreak } = require('../services/badgeService');

exports.markModuleComplete = async (req, res) => {
  try {
    const { moduleId } = req.params;
    const userId = req.user._id;
    
    // Find module
    const module = await Module.findById(moduleId);
    if (!module) {
      return res.status(404).json({ 
        success: false, 
        error: 'Module not found' 
      });
    }
    
    // Update user progress
    const user = await User.findById(userId);
    
    // Check if already completed
    const alreadyCompleted = user.completedModuleIds.some(
      id => id.toString() === moduleId
    );
    
    if (alreadyCompleted) {
      return res.json({
        success: true,
        message: 'Module already completed',
        data: { badgeEarned: false },
      });
    }
    
    // Mark as complete
    user.completedModuleIds.push(moduleId);
    user.progressSummary.completedModules += 1;
    
    // Update total modules if needed
    if (user.progressSummary.totalModules === 0) {
      const totalModules = await Module.countDocuments();
      user.progressSummary.totalModules = totalModules;
    }
    
    await user.save();
    
    // Update streak
    const streakBadges = await updateStreak(userId);
    
    // Check for badges
    const moduleBadges = await checkModuleBadges(userId, moduleId);
    
    const allEarnedBadges = [...moduleBadges, ...streakBadges];
    
    // Prepare response
    const responseData = {
      badgeEarned: allEarnedBadges.length > 0,
    };
    
    if (allEarnedBadges.length > 0) {
      responseData.badge = allEarnedBadges[0]; // Return first badge
      responseData.allBadgesEarned = allEarnedBadges; // All badges
    }
    
    res.json({
      success: true,
      message: 'Module marked as complete',
      data: responseData,
    });
    
  } catch (error) {
    console.error('❌ Mark module complete error:', error);
    res.status(500).json({ 
      success: false, 
      error: error.message 
    });
  }
};
```

---

## 📋 Step 5: Update GET Badges Endpoint

Update your get user badges controller (e.g., `controllers/userController.js`):

```javascript
exports.getUserBadges = async (req, res) => {
  try {
    const userId = req.user._id;
    
    const user = await User.findById(userId)
      .select('badges totalPoints progressSummary');
    
    if (!user) {
      return res.status(404).json({ 
        success: false, 
        error: 'User not found' 
      });
    }
    
    res.json({
      success: true,
      data: {
        badges: user.badges || [],
        totalPoints: user.totalPoints || 0,
        progressSummary: user.progressSummary,
        newBadgeEarned: false, // This endpoint just fetches, doesn't award
      },
    });
    
  } catch (error) {
    console.error('❌ Get badges error:', error);
    res.status(500).json({ 
      success: false, 
      error: error.message 
    });
  }
};
```

---

## 📋 Step 6: Register Routes

Make sure routes are registered in your routes file (e.g., `routes/users.js` or `routes/learning.js`):

```javascript
// routes/users.js
const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth');
const userController = require('../controllers/userController');

router.get('/badges', authenticate, userController.getUserBadges);

module.exports = router;

// In app.js or server.js:
// app.use('/api/users', require('./routes/users'));
```

```javascript
// routes/learning.js
const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth');
const learningController = require('../controllers/learningController');

router.post('/assessments/:assessmentId/submit', authenticate, learningController.submitAssessment);
router.put('/modules/:moduleId/progress', authenticate, learningController.markModuleComplete);

module.exports = router;

// In app.js or server.js:
// app.use('/api/learning', require('./routes/learning'));
```

---

## 🧪 Testing the Badge System

### Test 1: First Assessment Badge

```bash
# Submit first assessment (≥70%)
curl -X POST http://localhost:3000/api/learning/assessments/ASSESSMENT_ID/submit \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "answers": [0, 1, 2, 0, 1],
    "careerId": "CAREER_ID"
  }'

# Expected response:
# {
#   "success": true,
#   "data": {
#     "score": 4,
#     "total": 5,
#     "percentage": 80,
#     "passed": true,
#     "badgeEarned": true,
#     "badge": {
#       "id": "first_steps",
#       "title": "First Steps",
#       "description": "Passed your first assessment",
#       "icon": "🎉",
#       "points": 50,
#       "earnedAt": "2025-11-23T..."
#     }
#   }
# }
```

### Test 2: Perfect Score Badge

```bash
# Submit with 100% score
curl -X POST http://localhost:3000/api/learning/assessments/ASSESSMENT_ID/submit \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "answers": [0, 1, 2, 0, 1],
    "careerId": "CAREER_ID"
  }'

# If all answers correct, should award Perfectionist badge
```

### Test 3: Module Completion Badge

```bash
# Mark first module as complete
curl -X PUT http://localhost:3000/api/learning/modules/MODULE_ID/progress \
  -H "Authorization: Bearer YOUR_TOKEN"

# Expected response:
# {
#   "success": true,
#   "message": "Module marked as complete",
#   "data": {
#     "badgeEarned": true,
#     "badge": {
#       "id": "module_starter",
#       "title": "Module Starter",
#       "description": "Completed your first module",
#       "icon": "📚",
#       "points": 30,
#       "earnedAt": "2025-11-23T..."
#     }
#   }
# }
```

### Test 4: Fetch All Badges

```bash
# Get user's badges
curl http://localhost:3000/api/users/badges \
  -H "Authorization: Bearer YOUR_TOKEN"

# Expected response:
# {
#   "success": true,
#   "data": {
#     "badges": [
#       {
#         "id": "first_steps",
#         "title": "First Steps",
#         "icon": "🎉",
#         ...
#       }
#     ],
#     "totalPoints": 80,
#     "progressSummary": {
#       "completedModules": 1,
#       "badgesEarned": 2,
#       "assessmentsPassed": 1,
#       "currentStreak": 1
#     }
#   }
# }
```

---

## ✅ Implementation Checklist

- [ ] Update User schema with progressSummary, badges, completedModuleIds, assessmentHistory
- [ ] Create `services/badgeService.js` with all badge logic
- [ ] Update `submitAssessment` controller to check badges
- [ ] Update `markModuleComplete` controller to check badges
- [ ] Update `getUserBadges` controller to return badges
- [ ] Register all routes in your Express app
- [ ] Restart backend server
- [ ] Test with curl or Postman
- [ ] Test in Flutter app

---

## 🎯 Badge Trigger Summary

| Badge | How to Earn | Points | Icon |
|-------|------------|--------|------|
| First Steps | Pass 1st assessment (≥70%) | 50 | 🎉 |
| Perfectionist | Get 100% on any assessment | 100 | 💯 |
| Speed Demon | Complete assessment in <5 min + pass | 75 | ⚡ |
| Rising Star | Pass 5 assessments total | 150 | ⭐ |
| Module Starter | Complete 1st module | 30 | 📚 |
| Module Enthusiast | Complete 10 modules | 200 | 🎓 |
| HTML Master | Complete all HTML modules | 200 | 🏆 |
| Course Champion | Complete entire career path | 500 | 👑 |
| Week Warrior | 7 day activity streak | 150 | 🔥 |

---

**Total Possible Points:** 1,455+ points across all badges!

**Status:** ✅ Complete implementation guide  
**Last Updated:** November 23, 2025  
**Ready for backend integration!** 🚀
