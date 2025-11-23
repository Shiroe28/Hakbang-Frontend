# 🔄 Backend Implementation: Toggle Complete/Incomplete & Notifications

## 📋 What Frontend Just Implemented

The Flutter app now has these new features:

1. ✅ **Toggle Module Complete/Incomplete** - Users can mark modules complete AND uncomplete
2. ✅ **Badge Notifications** - When badges are earned, notifications are created
3. ✅ **Milestone Notifications** - When modules/assessments are completed, milestone notifications are created
4. ✅ **Notifications Screen** - Fetches and displays real notifications with badge/milestone indicators
5. ✅ **Dashboard Recent Milestones** - Shows latest 3 milestones/badges on home screen

## 🎯 What Backend Needs to Implement

### Priority 1: Update Module Progress Endpoint (Required)

Your existing endpoint:
```
PUT /api/learning/modules/:moduleId/progress
```

**Current behavior:** Only marks as complete

**New behavior needed:** Support BOTH complete and uncomplete

#### Update your `learningController.js`:

```javascript
exports.updateModuleProgress = async (req, res) => {
  try {
    const { moduleId } = req.params;
    const { careerId, completed } = req.body; // ← Added 'completed' field
    const userId = req.user._id;

    // Validate inputs
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

    // Find existing progress entry for this module
    const existingProgress = userProgress.moduleProgress.find(
      mp => mp.moduleId.toString() === moduleId
    );

    if (existingProgress) {
      // Update existing entry
      existingProgress.completed = completed; // ← Use the 'completed' value from request
      existingProgress.completedAt = completed ? new Date() : null;
    } else {
      // Add new entry
      userProgress.moduleProgress.push({
        moduleId,
        completed: completed,
        completedAt: completed ? new Date() : null
      });
    }

    await userProgress.save();

    // Check for badges ONLY if marking as complete (not when uncompleting)
    let badgeEarned = false;
    let badge = null;

    if (completed) {
      // Your existing badge logic here
      // Example from your BACKEND_BADGE_SYSTEM.md:
      
      // Count completed modules
      const totalCompleted = await UserProgress.aggregate([
        { $match: { userId: mongoose.Types.ObjectId(userId) } },
        { $unwind: '$moduleProgress' },
        { $match: { 'moduleProgress.completed': true } },
        { $count: 'total' }
      ]);

      const completedCount = totalCompleted[0]?.total || 0;

      // Award badges based on count
      if (completedCount === 1) {
        badge = {
          title: 'Module Starter',
          description: 'Completed your first module',
          icon: '📚',
          points: 30
        };
        badgeEarned = true;
        // Add to user.badges array
      } else if (completedCount === 10) {
        badge = {
          title: 'Module Enthusiast',
          description: 'Completed 10 modules',
          icon: '🎓',
          points: 200
        };
        badgeEarned = true;
      }
    }

    return res.json({
      success: true,
      message: completed 
        ? 'Module marked as complete' 
        : 'Module marked as incomplete',
      data: {
        badgeEarned,
        badge
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

#### What Changed:
1. ✅ Extract `completed` from request body (true or false)
2. ✅ Use `completed` value when updating progress
3. ✅ Set `completedAt` to null when uncompleting
4. ✅ Only check badges when `completed === true`
5. ✅ Return appropriate message based on action

---

### Priority 2: Create Notifications Endpoint (Required)

Create new endpoint for notifications:

```
POST /api/notifications
```

#### Create `notificationsController.js`:

```javascript
const Notification = require('../models/Notification');

exports.createNotification = async (req, res) => {
  try {
    const { title, message, type } = req.body;
    const userId = req.user._id;

    // Validate inputs
    if (!title || !message || !type) {
      return res.status(400).json({
        success: false,
        error: 'Title, message, and type are required'
      });
    }

    // Validate type
    const validTypes = ['badge', 'milestone', 'system', 'update'];
    if (!validTypes.includes(type)) {
      return res.status(400).json({
        success: false,
        error: 'Invalid notification type'
      });
    }

    // Create notification
    const notification = new Notification({
      userId,
      title,
      message,
      type,
      isRead: false,
      createdAt: new Date()
    });

    await notification.save();

    return res.status(201).json({
      success: true,
      message: 'Notification created',
      data: notification
    });

  } catch (error) {
    console.error('Error creating notification:', error);
    return res.status(500).json({
      success: false,
      error: 'Failed to create notification'
    });
  }
};

exports.getUserNotifications = async (req, res) => {
  try {
    const userId = req.user._id;

    const notifications = await Notification.find({ userId })
      .sort({ createdAt: -1 }) // Most recent first
      .limit(50); // Limit to last 50

    return res.json({
      success: true,
      data: notifications
    });

  } catch (error) {
    console.error('Error fetching notifications:', error);
    return res.status(500).json({
      success: false,
      error: 'Failed to fetch notifications'
    });
  }
};

exports.markAsRead = async (req, res) => {
  try {
    const { notificationId } = req.params;
    const userId = req.user._id;

    const notification = await Notification.findOne({
      _id: notificationId,
      userId
    });

    if (!notification) {
      return res.status(404).json({
        success: false,
        error: 'Notification not found'
      });
    }

    notification.isRead = true;
    await notification.save();

    return res.json({
      success: true,
      message: 'Notification marked as read'
    });

  } catch (error) {
    console.error('Error marking notification as read:', error);
    return res.status(500).json({
      success: false,
      error: 'Failed to mark notification as read'
    });
  }
};
```

---

### Priority 3: Create Notification Model (Required)

#### Create `models/Notification.js`:

```javascript
const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  title: {
    type: String,
    required: true
  },
  message: {
    type: String,
    required: true
  },
  type: {
    type: String,
    enum: ['badge', 'milestone', 'system', 'update'],
    required: true
  },
  isRead: {
    type: Boolean,
    default: false
  },
  createdAt: {
    type: Date,
    default: Date.now,
    index: true
  }
});

// Index for efficient queries
notificationSchema.index({ userId: 1, createdAt: -1 });

module.exports = mongoose.model('Notification', notificationSchema);
```

---

### Priority 4: Update Routes (Required)

#### In your `routes/notifications.js`:

```javascript
const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth');
const notificationsController = require('../controllers/notificationsController');

// Create notification (authenticated)
router.post('/', authenticate, notificationsController.createNotification);

// Get user notifications
router.get('/', authenticate, notificationsController.getUserNotifications);

// Mark as read
router.put('/:notificationId/read', authenticate, notificationsController.markAsRead);

module.exports = router;
```

#### Register routes in `app.js` or `server.js`:

```javascript
const notificationsRoutes = require('./routes/notifications');

// ... other routes

app.use('/api/notifications', notificationsRoutes);
```

---

## 🧪 Testing Your Implementation

### Test 1: Mark Module Complete

```bash
curl -X PUT http://localhost:3000/api/learning/modules/MODULE_ID/progress \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "careerId": "CAREER_ID",
    "completed": true
  }'

# Expected response:
# {
#   "success": true,
#   "message": "Module marked as complete",
#   "data": {
#     "badgeEarned": false
#   }
# }
```

### Test 2: Mark Module Incomplete

```bash
curl -X PUT http://localhost:3000/api/learning/modules/MODULE_ID/progress \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "careerId": "CAREER_ID",
    "completed": false
  }'

# Expected response:
# {
#   "success": true,
#   "message": "Module marked as incomplete",
#   "data": {
#     "badgeEarned": false
#   }
# }
```

### Test 3: Create Notification

```bash
curl -X POST http://localhost:3000/api/notifications \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "🏆 New Badge Earned!",
    "message": "📚 Module Starter - Completed your first module",
    "type": "badge"
  }'

# Expected response:
# {
#   "success": true,
#   "message": "Notification created",
#   "data": {
#     "_id": "...",
#     "userId": "...",
#     "title": "🏆 New Badge Earned!",
#     "message": "📚 Module Starter - Completed your first module",
#     "type": "badge",
#     "isRead": false,
#     "createdAt": "2025-11-23T..."
#   }
# }
```

### Test 4: Get Notifications

```bash
curl -X GET http://localhost:3000/api/notifications \
  -H "Authorization: Bearer YOUR_TOKEN"

# Expected response:
# {
#   "success": true,
#   "data": [
#     {
#       "_id": "...",
#       "userId": "...",
#       "title": "🏆 New Badge Earned!",
#       "message": "...",
#       "type": "badge",
#       "isRead": false,
#       "createdAt": "2025-11-23T..."
#     },
#     ...
#   ]
# }
```

### Test 5: Mark Notification as Read

```bash
curl -X PUT http://localhost:3000/api/notifications/NOTIFICATION_ID/read \
  -H "Authorization: Bearer YOUR_TOKEN"

# Expected response:
# {
#   "success": true,
#   "message": "Notification marked as read"
# }
```

---

## 📊 How Frontend Will Use These Endpoints

### When User Marks Module Complete:
```
1. Frontend sends: PUT /api/learning/modules/:id/progress 
   Body: { "careerId": "...", "completed": true }
   
2. Backend responds with badge data (if earned)

3. Frontend creates notification: POST /api/notifications
   Body: { 
     "title": "📚 Module Completed",
     "message": "Great job! You completed 'Module Name'",
     "type": "milestone"
   }

4. If badge earned, frontend creates another: POST /api/notifications
   Body: {
     "title": "🏆 New Badge Earned!",
     "message": "📚 Module Starter - Completed your first module",
     "type": "badge"
   }
```

### When User Marks Module Incomplete:
```
1. Frontend sends: PUT /api/learning/modules/:id/progress 
   Body: { "careerId": "...", "completed": false }
   
2. Backend responds with success message
   (No badge checking when uncompleting)
```

### When User Opens Notifications Screen:
```
1. Frontend calls: GET /api/notifications

2. Backend returns list of notifications sorted by date

3. Frontend displays with different icons based on type:
   - badge → 🏆 emoji_events icon, amber color
   - milestone → ⭐ star icon, green color
   - system → ℹ️ info icon, blue color
   - update → 🆕 new_releases icon, purple color
```

### When User Taps a Notification:
```
1. Frontend calls: PUT /api/notifications/:id/read

2. Backend marks as read

3. Frontend updates UI to show as read (grey background)
```

### When User Opens Dashboard:
```
1. Frontend calls: GET /api/notifications

2. Filters for type === 'milestone' OR type === 'badge'

3. Takes latest 3 items

4. Displays in "Recent Milestones" card
```

---

## ⚠️ Important Notes

### 1. **completed Field is Required**
The frontend now sends `completed: true` or `completed: false` in the request body. This tells you whether to mark it complete or incomplete.

### 2. **Don't Award Badges When Uncompleting**
Only check and award badges when `completed === true`. When `completed === false`, just update the progress and return success.

### 3. **Frontend Handles Notification Creation**
The frontend will call the POST /api/notifications endpoint after successful module completion and badge earning. Your backend just needs to accept and store these notifications.

### 4. **Notification Types**
Valid types: `badge`, `milestone`, `system`, `update`

Frontend uses:
- `badge` - When a badge is earned
- `milestone` - When a module is completed or assessment is passed

### 5. **Index Your Collections**
Add indexes to Notification model for efficient queries:
```javascript
notificationSchema.index({ userId: 1, createdAt: -1 });
```

This makes queries fast when fetching user's notifications.

---

## 🎯 Summary Checklist

- [ ] Update `learningController.updateModuleProgress` to accept `completed` field
- [ ] Add logic to mark as incomplete when `completed === false`
- [ ] Only check badges when `completed === true`
- [ ] Create `Notification` model with required fields
- [ ] Create `notificationsController` with 3 methods:
  - [ ] `createNotification` (POST)
  - [ ] `getUserNotifications` (GET)
  - [ ] `markAsRead` (PUT)
- [ ] Create notification routes and register in app
- [ ] Test all 5 curl commands above
- [ ] Restart backend server
- [ ] Verify in Flutter app:
  - [ ] Mark module complete works
  - [ ] Mark module incomplete works
  - [ ] Notifications appear in notifications screen
  - [ ] Recent milestones show on dashboard
  - [ ] Badge notifications have trophy icon
  - [ ] Milestone notifications have star icon

---

## ⏰ Time Estimate

- **Update Module Progress:** ~10 minutes
- **Create Notification Model:** ~5 minutes
- **Create Notifications Controller:** ~15 minutes
- **Create Routes:** ~5 minutes
- **Testing:** ~10 minutes

**Total:** ~45 minutes

---

## 🆘 Troubleshooting

### Issue: "completed is not defined"
**Solution:** Make sure you're extracting `completed` from req.body:
```javascript
const { careerId, completed } = req.body;
```

### Issue: "Cannot create notification"
**Solution:** Check that:
1. Notification model is created
2. Routes are registered
3. Authentication middleware is working
4. Request has all required fields (title, message, type)

### Issue: "Badge still awarded when uncompleting"
**Solution:** Wrap badge logic in `if (completed)` condition:
```javascript
if (completed) {
  // Check and award badges here
}
```

### Issue: "Notifications not showing in app"
**Solution:** 
1. Check GET /api/notifications returns data
2. Verify JWT token is being sent in headers
3. Check notification type is one of: badge, milestone, system, update
4. Restart Flutter app to reload

---

**Last Updated:** November 23, 2025  
**Frontend Status:** ✅ Complete  
**Backend Status:** ⏳ Awaiting Implementation  
**Contact:** Check #codebase for questions
