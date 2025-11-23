# 🚀 Quick Start: Backend Prompt Message

Copy and send this to your backend developer:

---

## 📱 Frontend Update: New Features Ready!

Hi! The Flutter app now has **5 new features** that need backend support:

### ✅ What's New in Frontend:

1. **Toggle Complete/Incomplete** - Users can mark modules complete AND uncomplete them
2. **Badge Notifications** - Automatic notifications when badges are earned
3. **Milestone Notifications** - Notifications for completed modules and assessments
4. **Live Notifications Screen** - Real-time notification feed with different types
5. **Dashboard Milestones** - Shows latest 3 achievements on home screen

### 🎯 What Backend Needs to Do:

#### Priority 1: Update Module Progress (10 minutes)

**Endpoint:** `PUT /api/learning/modules/:moduleId/progress`

**Current behavior:** Only marks as complete

**New behavior:** Accept `completed` field in body (true/false)

**Code change in `learningController.js`:**

```javascript
exports.updateModuleProgress = async (req, res) => {
  const { careerId, completed } = req.body; // ← Add 'completed'
  
  // Update progress
  existingProgress.completed = completed; // ← Use it here
  existingProgress.completedAt = completed ? new Date() : null;
  
  // Only check badges when completing (not uncompleting)
  if (completed) {
    // Badge logic here
  }
  
  return res.json({
    success: true,
    message: completed ? 'Module marked as complete' : 'Module marked as incomplete',
    data: { badgeEarned, badge }
  });
};
```

**Test it:**
```bash
# Mark complete
curl -X PUT http://localhost:3000/api/learning/modules/MODULE_ID/progress \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"careerId": "CAREER_ID", "completed": true}'

# Mark incomplete
curl -X PUT http://localhost:3000/api/learning/modules/MODULE_ID/progress \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"careerId": "CAREER_ID", "completed": false}'
```

---

#### Priority 2: Create Notifications System (35 minutes)

**Need 3 new endpoints:**

##### 1. POST /api/notifications - Create notification
```javascript
exports.createNotification = async (req, res) => {
  const { title, message, type } = req.body;
  const userId = req.user._id;
  
  const notification = new Notification({
    userId,
    title,
    message,
    type, // badge, milestone, system, or update
    isRead: false,
    createdAt: new Date()
  });
  
  await notification.save();
  return res.status(201).json({ success: true, data: notification });
};
```

##### 2. GET /api/notifications - Get user notifications
```javascript
exports.getUserNotifications = async (req, res) => {
  const notifications = await Notification.find({ userId: req.user._id })
    .sort({ createdAt: -1 })
    .limit(50);
    
  return res.json({ success: true, data: notifications });
};
```

##### 3. PUT /api/notifications/:id/read - Mark as read
```javascript
exports.markAsRead = async (req, res) => {
  const notification = await Notification.findOne({
    _id: req.params.notificationId,
    userId: req.user._id
  });
  
  notification.isRead = true;
  await notification.save();
  
  return res.json({ success: true, message: 'Notification marked as read' });
};
```

**Need 1 new model - `models/Notification.js`:**
```javascript
const notificationSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  title: { type: String, required: true },
  message: { type: String, required: true },
  type: { type: String, enum: ['badge', 'milestone', 'system', 'update'], required: true },
  isRead: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now }
});

notificationSchema.index({ userId: 1, createdAt: -1 });
module.exports = mongoose.model('Notification', notificationSchema);
```

**Register routes in `app.js`:**
```javascript
const notificationsRoutes = require('./routes/notifications');
app.use('/api/notifications', notificationsRoutes);
```

**Test endpoints:**
```bash
# Create notification
curl -X POST http://localhost:3000/api/notifications \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title": "Test", "message": "Hello", "type": "system"}'

# Get notifications
curl -X GET http://localhost:3000/api/notifications \
  -H "Authorization: Bearer TOKEN"

# Mark as read
curl -X PUT http://localhost:3000/api/notifications/NOTIFICATION_ID/read \
  -H "Authorization: Bearer TOKEN"
```

---

### 📋 Implementation Checklist:

- [ ] Update `learningController.js` to accept `completed` field
- [ ] Create `models/Notification.js` model
- [ ] Create `controllers/notificationsController.js` with 3 methods
- [ ] Create `routes/notifications.js` routes
- [ ] Register routes in `app.js`
- [ ] Restart backend server
- [ ] Test with curl commands above
- [ ] Verify in Flutter app

---

### 📚 Full Documentation:

For complete details, see: **`BACKEND_TOGGLE_COMPLETE_AND_NOTIFICATIONS.md`**

Includes:
- ✅ Complete code examples
- ✅ Database schema
- ✅ All test commands
- ✅ Troubleshooting guide
- ✅ Integration flow diagrams

---

### ⏰ Time Estimate:

- Module progress update: **10 minutes**
- Notification model: **5 minutes**
- Notification controller: **15 minutes**
- Routes: **5 minutes**
- Testing: **10 minutes**

**Total: ~45 minutes**

---

### 🆘 Questions?

Check the full documentation or ask in the chat!

---

**Status:**
- Frontend: ✅ Complete
- Backend: ⏳ Awaiting Implementation
- Testing: Ready once backend is done

Let me know when you're finished so I can test it in the app! 🚀

---
