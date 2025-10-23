# MongoDB Schema Documentation - Hakbang Backend

This document defines the complete database schema for the Hakbang application using MongoDB.

---

## Database: `hakbang_db`

---

## Collections Overview

| Collection | Purpose | Key Relations |
|------------|---------|---------------|
| users | User accounts and profiles | → userProgress, aiFeatures, feedback |
| careers | IT career information | → modules |
| modules | Learning content | ← careers, → assessments |
| userProgress | User learning tracking | ← users, careers, modules |
| assessments | Quizzes and tests | ← modules |
| aiFeatures | AI interaction logs | ← users |
| notifications | User alerts | ← users |
| adminDashboard | Analytics data | System-wide stats |
| feedback | User feedback/reports | ← users |
| community | Forum posts | ← users |
| mentorship | Mentor-student connections | ← users |
| activityLogs | Action history | ← users |

---

## 1. **Users Collection**

Stores all users (students, mentors, admins).

### Schema
```javascript
{
  _id: ObjectId,
  
  // Authentication
  email: { 
    type: String, 
    required: true,
    unique: true,
    lowercase: true,
    trim: true
  },
  passwordHash: { 
    type: String, 
    required: true 
  },
  
  // Profile
  username: {
    type: String,
    required: true,
    unique: true,
    trim: true
  },
  name: {
    type: String,
    trim: true
  },
  profilePicture: {
    type: String,  // URL or base64
    default: null
  },
  bio: {
    type: String,
    maxlength: 500,
    default: ""
  },
  
  // Role & Permissions
  role: { 
    type: String, 
    enum: ["student", "mentor", "admin"], 
    required: true,
    default: "student"
  },
  
  // Career Info
  currentRole: {
    type: String,
    default: null
  },
  goals: [{
    type: String
  }],
  interests: [{
    type: String
  }],
  
  // Progress Summary
  progressSummary: {
    totalModules: {
      type: Number,
      default: 0
    },
    completedModules: {
      type: Number,
      default: 0
    },
    badgesEarned: {
      type: Number,
      default: 0
    },
    currentStreak: {
      type: Number,
      default: 0
    },
    totalHoursLearned: {
      type: Number,
      default: 0
    }
  },
  
  // Settings
  settings: {
    darkMode: {
      type: Boolean,
      default: false
    },
    notifications: {
      type: Boolean,
      default: true
    },
    emailNotifications: {
      type: Boolean,
      default: true
    },
    language: {
      type: String,
      default: "en"
    }
  },
  
  // Metadata
  isActive: {
    type: Boolean,
    default: true
  },
  lastLogin: {
    type: Date,
    default: null
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
}
```

### Indexes
```javascript
db.users.createIndex({ email: 1 }, { unique: true })
db.users.createIndex({ username: 1 }, { unique: true })
db.users.createIndex({ role: 1 })
```

---

## 2. **Careers Collection**

Contains IT career details and skill paths.

### Schema
```javascript
{
  _id: ObjectId,
  
  // Basic Info
  title: {
    type: String,
    required: true,
    trim: true
  }, // e.g. "Web Developer", "Data Scientist"
  
  description: {
    type: String,
    required: true
  },
  
  icon: {
    type: String,  // Icon name or URL
    default: "work"
  },
  
  // Career Details
  salaryRange: {
    type: String,
    required: true
  }, // e.g. "₱30,000 - ₱80,000 per month"
  
  skillsRequired: [{
    type: String
  }], // e.g. ["HTML", "CSS", "JavaScript", "React"]
  
  // Career Roadmap
  roadmap: [{
    step: {
      type: Number,
      required: true
    },
    title: {
      type: String,
      required: true
    },
    description: {
      type: String
    },
    estimatedDuration: {
      type: String
    }
  }],
  
  // Relationships
  relatedModules: [{
    type: ObjectId,
    ref: 'modules'
  }],
  
  // Stats
  popularity: {
    type: Number,
    default: 0
  },
  averageSalary: {
    type: Number,
    default: 0
  },
  growthRate: {
    type: String
  },
  
  // Metadata
  isActive: {
    type: Boolean,
    default: true
  },
  order: {
    type: Number,
    default: 0
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
}
```

### Indexes
```javascript
db.careers.createIndex({ title: 1 })
db.careers.createIndex({ isActive: 1, order: 1 })
```

---

## 3. **Modules / Courses Collection**

For learning materials linked to careers.

### Schema
```javascript
{
  _id: ObjectId,
  
  // Basic Info
  title: {
    type: String,
    required: true,
    trim: true
  },
  
  description: {
    type: String,
    required: true
  },
  
  // Relationships
  careerId: {
    type: ObjectId,
    ref: 'careers',
    required: true
  },
  
  // Content
  contentType: { 
    type: String, 
    enum: ["document", "video", "link", "text"],
    required: true
  },
  
  contentURL: {
    type: String,
    trim: true
  },
  
  content: {
    type: String  // For text-based content
  },
  
  // Module Info
  duration: {
    type: String  // e.g. "2 hours", "30 minutes"
  },
  
  difficulty: {
    type: String,
    enum: ["beginner", "intermediate", "advanced"],
    default: "beginner"
  },
  
  order: {
    type: Number,
    default: 0
  },
  
  prerequisites: [{
    type: ObjectId,
    ref: 'modules'
  }],
  
  // Gamification
  pointsAwarded: {
    type: Number,
    default: 10
  },
  
  // Stats
  completionCount: {
    type: Number,
    default: 0
  },
  
  averageRating: {
    type: Number,
    default: 0,
    min: 0,
    max: 5
  },
  
  // Metadata
  isActive: {
    type: Boolean,
    default: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
}
```

### Indexes
```javascript
db.modules.createIndex({ careerId: 1, order: 1 })
db.modules.createIndex({ title: "text", description: "text" })
db.modules.createIndex({ isActive: 1 })
```

---

## 4. **UserProgress Collection**

Tracks each user's progress in modules and careers.

### Schema
```javascript
{
  _id: ObjectId,
  
  // User Reference
  userId: {
    type: ObjectId,
    ref: 'users',
    required: true
  },
  
  // Career Reference
  careerId: {
    type: ObjectId,
    ref: 'careers',
    required: true
  },
  
  // Module Progress
  moduleProgress: [{
    moduleId: {
      type: ObjectId,
      ref: 'modules',
      required: true
    },
    completed: {
      type: Boolean,
      default: false
    },
    startedAt: {
      type: Date,
      default: Date.now
    },
    completedAt: {
      type: Date,
      default: null
    },
    timeSpent: {
      type: Number,  // in minutes
      default: 0
    },
    rating: {
      type: Number,
      min: 1,
      max: 5,
      default: null
    }
  }],
  
  // Badges
  badges: [{
    title: {
      type: String,
      required: true
    },
    description: {
      type: String
    },
    icon: {
      type: String
    },
    earnedAt: {
      type: Date,
      default: Date.now
    },
    category: {
      type: String,
      enum: ["completion", "streak", "mastery", "social", "special"],
      default: "completion"
    }
  }],
  
  // Assessments
  assessmentsTaken: [{
    assessmentId: {
      type: ObjectId,
      ref: 'assessments'
    },
    score: {
      type: Number
    },
    totalQuestions: {
      type: Number
    },
    percentage: {
      type: Number
    },
    passed: {
      type: Boolean
    },
    takenAt: {
      type: Date,
      default: Date.now
    }
  }],
  
  // Overall Stats
  totalPoints: {
    type: Number,
    default: 0
  },
  
  currentLevel: {
    type: Number,
    default: 1
  },
  
  // Metadata
  lastActivityAt: {
    type: Date,
    default: Date.now
  },
  
  updatedAt: {
    type: Date,
    default: Date.now
  }
}
```

### Indexes
```javascript
db.userProgress.createIndex({ userId: 1, careerId: 1 }, { unique: true })
db.userProgress.createIndex({ userId: 1 })
db.userProgress.createIndex({ careerId: 1 })
```

---

## 5. **Assessments Collection**

Stores quizzes or self-assessments per module.

### Schema
```javascript
{
  _id: ObjectId,
  
  // Basic Info
  title: {
    type: String,
    required: true
  },
  
  description: {
    type: String
  },
  
  // Module Reference
  moduleId: {
    type: ObjectId,
    ref: 'modules',
    required: true
  },
  
  // Questions
  questions: [{
    questionText: {
      type: String,
      required: true
    },
    options: [{
      type: String,
      required: true
    }],
    correctOption: {
      type: Number,  // Index of correct answer (0-based)
      required: true
    },
    explanation: {
      type: String  // Explain why this is correct
    },
    points: {
      type: Number,
      default: 1
    }
  }],
  
  // Settings
  passingScore: {
    type: Number,
    default: 70  // Percentage
  },
  
  timeLimit: {
    type: Number,  // in minutes, null for unlimited
    default: null
  },
  
  attempts: {
    type: Number,
    default: 3  // -1 for unlimited
  },
  
  // AI Feedback
  aiFeedbackEnabled: {
    type: Boolean,
    default: false
  },
  
  aiFeedbackPrompt: {
    type: String
  },
  
  // Stats
  totalAttempts: {
    type: Number,
    default: 0
  },
  
  averageScore: {
    type: Number,
    default: 0
  },
  
  // Metadata
  isActive: {
    type: Boolean,
    default: true
  },
  
  createdAt: {
    type: Date,
    default: Date.now
  },
  
  updatedAt: {
    type: Date,
    default: Date.now
  }
}
```

### Indexes
```javascript
db.assessments.createIndex({ moduleId: 1 })
db.assessments.createIndex({ isActive: 1 })
```

---

## 6. **AI Features Collection**

Manages all AI-based activities (recommendations, resume, chatbot, etc.)

### Schema
```javascript
{
  _id: ObjectId,
  
  // User Reference
  userId: {
    type: ObjectId,
    ref: 'users',
    required: true
  },
  
  // AI Feature Type
  type: {
    type: String,
    enum: [
      "career_recommendation",
      "chatbot_session",
      "resume_feedback",
      "skill_gap_analysis",
      "simulation"
    ],
    required: true
  },
  
  // Input Data
  inputData: {
    type: Object,  // Flexible structure based on type
    required: true
  },
  // Example for career_recommendation:
  // {
  //   quizResponses: [{ question, answer, answerIndex }],
  //   userInterests: [],
  //   currentSkills: []
  // }
  
  // AI Output
  aiOutput: {
    type: Object,
    required: true
  },
  // Example for career_recommendation:
  // {
  //   recommendations: [
  //     { careerId, title, matchPercentage, reasons: [] }
  //   ]
  // }
  
  // Results
  score: {
    type: Number,
    min: 0,
    max: 100
  },
  
  confidence: {
    type: Number,
    min: 0,
    max: 1
  },
  
  // Feedback
  userRating: {
    type: Number,
    min: 1,
    max: 5,
    default: null
  },
  
  userFeedback: {
    type: String
  },
  
  // Session Info (for chatbot)
  sessionDuration: {
    type: Number,  // in seconds
    default: 0
  },
  
  messageCount: {
    type: Number,
    default: 0
  },
  
  // Metadata
  createdAt: {
    type: Date,
    default: Date.now
  },
  
  updatedAt: {
    type: Date,
    default: Date.now
  }
}
```

### Indexes
```javascript
db.aiFeatures.createIndex({ userId: 1, type: 1 })
db.aiFeatures.createIndex({ createdAt: -1 })
db.aiFeatures.createIndex({ type: 1 })
```

---

## 7. **Notifications Collection**

Alerts from system or mentors.

### Schema
```javascript
{
  _id: ObjectId,
  
  // User Reference
  userId: {
    type: ObjectId,
    ref: 'users',
    required: true
  },
  
  // Notification Content
  title: {
    type: String,
    required: true
  },
  
  message: {
    type: String,
    required: true
  },
  
  // Type & Category
  type: { 
    type: String, 
    enum: ["system", "mentor", "community", "achievement", "update"],
    required: true
  },
  
  category: {
    type: String,
    enum: ["info", "success", "warning", "error"],
    default: "info"
  },
  
  // Icon & Color
  icon: {
    type: String,
    default: "notifications"
  },
  
  color: {
    type: String,
    default: "blue"
  },
  
  // Action
  actionURL: {
    type: String  // Deep link or route
  },
  
  actionLabel: {
    type: String  // e.g. "View", "Open", "Learn More"
  },
  
  // Status
  isRead: {
    type: Boolean,
    default: false
  },
  
  readAt: {
    type: Date,
    default: null
  },
  
  // Priority
  priority: {
    type: String,
    enum: ["low", "normal", "high", "urgent"],
    default: "normal"
  },
  
  // Metadata
  expiresAt: {
    type: Date,
    default: null
  },
  
  createdAt: {
    type: Date,
    default: Date.now
  }
}
```

### Indexes
```javascript
db.notifications.createIndex({ userId: 1, isRead: 1, createdAt: -1 })
db.notifications.createIndex({ createdAt: -1 })
db.notifications.createIndex({ expiresAt: 1 }, { expireAfterSeconds: 0 })
```

---

## 8. **Admin Dashboard Data Collection**

Used for insights and backend management.

### Schema
```javascript
{
  _id: ObjectId,
  
  // User Stats
  totalUsers: {
    type: Number,
    default: 0
  },
  
  activeUsers: {
    type: Number,
    default: 0
  },
  
  newUsersToday: {
    type: Number,
    default: 0
  },
  
  usersByRole: {
    students: {
      type: Number,
      default: 0
    },
    mentors: {
      type: Number,
      default: 0
    },
    admins: {
      type: Number,
      default: 0
    }
  },
  
  // Content Stats
  totalCareers: {
    type: Number,
    default: 0
  },
  
  totalModules: {
    type: Number,
    default: 0
  },
  
  totalAssessments: {
    type: Number,
    default: 0
  },
  
  // Engagement Stats
  moduleCompletionsToday: {
    type: Number,
    default: 0
  },
  
  assessmentsTakenToday: {
    type: Number,
    default: 0
  },
  
  communityPostsToday: {
    type: Number,
    default: 0
  },
  
  // AI Feature Usage
  aiFeatureUsage: {
    recommendations: {
      type: Number,
      default: 0
    },
    resumeFeedback: {
      type: Number,
      default: 0
    },
    chatbot: {
      type: Number,
      default: 0
    },
    skillGapAnalysis: {
      type: Number,
      default: 0
    },
    simulations: {
      type: Number,
      default: 0
    }
  },
  
  // Popular Content
  popularCareers: [{
    careerId: ObjectId,
    title: String,
    viewCount: Number
  }],
  
  popularModules: [{
    moduleId: ObjectId,
    title: String,
    completionCount: Number
  }],
  
  // Metadata
  date: {
    type: Date,
    default: Date.now
  },
  
  lastUpdated: {
    type: Date,
    default: Date.now
  }
}
```

### Indexes
```javascript
db.adminDashboard.createIndex({ date: -1 })
```

---

## 9. **Feedback & Reports Collection**

Stores user feedback and issue reports.

### Schema
```javascript
{
  _id: ObjectId,
  
  // User Reference
  userId: {
    type: ObjectId,
    ref: 'users',
    required: true
  },
  
  // Feedback Type
  category: { 
    type: String, 
    enum: ["feedback", "bug", "suggestion", "complaint", "question"],
    required: true
  },
  
  // Content
  title: {
    type: String,
    required: true
  },
  
  message: {
    type: String,
    required: true
  },
  
  // Screenshots/Attachments
  attachments: [{
    url: String,
    type: String,  // "image", "document"
    filename: String
  }],
  
  // Status
  status: { 
    type: String, 
    enum: ["pending", "in_progress", "reviewed", "resolved", "closed"],
    default: "pending"
  },
  
  priority: {
    type: String,
    enum: ["low", "medium", "high", "critical"],
    default: "medium"
  },
  
  // Admin Response
  adminId: {
    type: ObjectId,
    ref: 'users',
    default: null
  },
  
  adminResponse: {
    type: String
  },
  
  adminNotes: {
    type: String  // Internal notes
  },
  
  // Resolution
  resolvedAt: {
    type: Date,
    default: null
  },
  
  resolution: {
    type: String
  },
  
  // User Satisfaction
  satisfactionRating: {
    type: Number,
    min: 1,
    max: 5,
    default: null
  },
  
  // Metadata
  userAgent: {
    type: String
  },
  
  deviceInfo: {
    type: Object
  },
  
  appVersion: {
    type: String
  },
  
  createdAt: {
    type: Date,
    default: Date.now
  },
  
  updatedAt: {
    type: Date,
    default: Date.now
  }
}
```

### Indexes
```javascript
db.feedback.createIndex({ userId: 1, createdAt: -1 })
db.feedback.createIndex({ status: 1, priority: -1 })
db.feedback.createIndex({ category: 1 })
```

---

## 10. **Community / Forum Collection**

For discussion threads and comments.

### Schema
```javascript
{
  _id: ObjectId,
  
  // Post Info
  title: {
    type: String,
    required: true,
    trim: true
  },
  
  content: {
    type: String,
    required: true
  },
  
  // Category
  category: { 
    type: String, 
    enum: ["career", "skills", "general", "help", "showcase"],
    default: "general"
  },
  
  tags: [{
    type: String
  }],
  
  // Author
  authorId: {
    type: ObjectId,
    ref: 'users',
    required: true
  },
  
  authorName: {
    type: String
  },
  
  authorRole: {
    type: String
  },
  
  // Engagement
  views: {
    type: Number,
    default: 0
  },
  
  likes: [{
    userId: {
      type: ObjectId,
      ref: 'users'
    },
    likedAt: {
      type: Date,
      default: Date.now
    }
  }],
  
  // Comments
  comments: [{
    _id: ObjectId,
    userId: {
      type: ObjectId,
      ref: 'users',
      required: true
    },
    userName: String,
    userRole: String,
    text: {
      type: String,
      required: true
    },
    likes: [{
      userId: ObjectId,
      likedAt: Date
    }],
    createdAt: {
      type: Date,
      default: Date.now
    },
    updatedAt: {
      type: Date,
      default: Date.now
    }
  }],
  
  // Status
  isPinned: {
    type: Boolean,
    default: false
  },
  
  isClosed: {
    type: Boolean,
    default: false
  },
  
  isReported: {
    type: Boolean,
    default: false
  },
  
  // Metadata
  lastActivityAt: {
    type: Date,
    default: Date.now
  },
  
  createdAt: {
    type: Date,
    default: Date.now
  },
  
  updatedAt: {
    type: Date,
    default: Date.now
  }
}
```

### Indexes
```javascript
db.community.createIndex({ category: 1, createdAt: -1 })
db.community.createIndex({ authorId: 1 })
db.community.createIndex({ tags: 1 })
db.community.createIndex({ title: "text", content: "text" })
db.community.createIndex({ isPinned: -1, lastActivityAt: -1 })
```

---

## 11. **Mentorship Collection**

Connects mentors and students.

### Schema
```javascript
{
  _id: ObjectId,
  
  // Participants
  mentorId: {
    type: ObjectId,
    ref: 'users',
    required: true
  },
  
  studentId: {
    type: ObjectId,
    ref: 'users',
    required: true
  },
  
  // Session Info
  sessionDate: {
    type: Date,
    required: true
  },
  
  sessionDuration: {
    type: Number,  // in minutes
    default: 60
  },
  
  topic: {
    type: String,
    required: true
  },
  
  description: {
    type: String
  },
  
  // Meeting Details
  meetingType: {
    type: String,
    enum: ["video", "audio", "chat", "in-person"],
    default: "video"
  },
  
  meetingLink: {
    type: String
  },
  
  // Notes
  notes: {
    type: String
  },
  
  mentorNotes: {
    type: String
  },
  
  studentNotes: {
    type: String
  },
  
  // Status
  status: { 
    type: String, 
    enum: ["requested", "scheduled", "in_progress", "completed", "cancelled", "no_show"],
    default: "requested"
  },
  
  cancellationReason: {
    type: String
  },
  
  // Chat History
  chatHistory: [{
    senderId: {
      type: ObjectId,
      ref: 'users',
      required: true
    },
    message: {
      type: String,
      required: true
    },
    timestamp: {
      type: Date,
      default: Date.now
    },
    isRead: {
      type: Boolean,
      default: false
    }
  }],
  
  // Feedback
  studentRating: {
    type: Number,
    min: 1,
    max: 5,
    default: null
  },
  
  studentFeedback: {
    type: String
  },
  
  mentorRating: {
    type: Number,
    min: 1,
    max: 5,
    default: null
  },
  
  mentorFeedback: {
    type: String
  },
  
  // Metadata
  completedAt: {
    type: Date,
    default: null
  },
  
  createdAt: {
    type: Date,
    default: Date.now
  },
  
  updatedAt: {
    type: Date,
    default: Date.now
  }
}
```

### Indexes
```javascript
db.mentorship.createIndex({ mentorId: 1, status: 1 })
db.mentorship.createIndex({ studentId: 1, status: 1 })
db.mentorship.createIndex({ sessionDate: 1 })
db.mentorship.createIndex({ status: 1, sessionDate: 1 })
```

---

## 12. **Activity Logs Collection**

For recording user actions (AI sessions, module completions, etc.)

### Schema
```javascript
{
  _id: ObjectId,
  
  // User Reference
  userId: {
    type: ObjectId,
    ref: 'users',
    required: true
  },
  
  // Action Info
  actionType: {
    type: String,
    required: true
  },
  // Examples: 
  // "completed_module", "started_module", "passed_assessment",
  // "earned_badge", "started_chat", "posted_comment",
  // "created_post", "liked_post", "scheduled_mentorship"
  
  // Resource References
  resourceType: {
    type: String,
    enum: ["module", "career", "assessment", "post", "session", "badge", "chat"]
  },
  
  resourceId: {
    type: ObjectId
  },
  
  resourceTitle: {
    type: String
  },
  
  // Details
  details: {
    type: Object
  },
  // Example for completed_module:
  // {
  //   moduleId: ObjectId,
  //   moduleTitle: "HTML Basics",
  //   careerId: ObjectId,
  //   careerTitle: "Web Developer",
  //   timeSpent: 45,  // minutes
  //   score: 90  // if assessment
  // }
  
  // Metrics
  pointsEarned: {
    type: Number,
    default: 0
  },
  
  streakUpdated: {
    type: Boolean,
    default: false
  },
  
  // Device Info
  deviceInfo: {
    platform: String,  // "web", "android", "ios"
    browser: String,
    os: String
  },
  
  ipAddress: {
    type: String
  },
  
  // Metadata
  timestamp: {
    type: Date,
    default: Date.now,
    required: true
  }
}
```

### Indexes
```javascript
db.activityLogs.createIndex({ userId: 1, timestamp: -1 })
db.activityLogs.createIndex({ actionType: 1, timestamp: -1 })
db.activityLogs.createIndex({ resourceType: 1, resourceId: 1 })
db.activityLogs.createIndex({ timestamp: -1 })
```

---

## Relationships Diagram

```
users (1)─────────(M) userProgress
  │                      │
  │                      │
  │                   (M)│(1)
  │                   modules
  │                      │
  │                      │(M)
  │                      │(1)
  │                   careers
  │
  ├───(M) aiFeatures
  ├───(M) notifications
  ├───(M) feedback
  ├───(M) community
  ├───(M) mentorship (as mentor)
  ├───(M) mentorship (as student)
  └───(M) activityLogs

modules (1)───(M) assessments

community (1)───(M) comments (embedded)
```

---

## Data Initialization

### Sample Data Scripts

#### Create Admin User
```javascript
db.users.insertOne({
  email: "admin@hakbang.com",
  username: "admin",
  name: "Admin User",
  passwordHash: "$2a$10$...", // bcrypt hash of password
  role: "admin",
  settings: {
    darkMode: false,
    notifications: true,
    emailNotifications: true,
    language: "en"
  },
  createdAt: new Date(),
  updatedAt: new Date()
})
```

#### Create Sample Career
```javascript
db.careers.insertOne({
  title: "Web Developer",
  description: "Build and maintain websites and web applications",
  icon: "code",
  salaryRange: "₱30,000 - ₱80,000 per month",
  skillsRequired: ["HTML", "CSS", "JavaScript", "React", "Node.js"],
  roadmap: [
    {
      step: 1,
      title: "Learn HTML & CSS",
      description: "Master the building blocks of web pages",
      estimatedDuration: "4 weeks"
    },
    {
      step: 2,
      title: "JavaScript Fundamentals",
      description: "Learn programming with JavaScript",
      estimatedDuration: "8 weeks"
    },
    {
      step: 3,
      title: "React Framework",
      description: "Build modern web applications",
      estimatedDuration: "6 weeks"
    }
  ],
  popularity: 0,
  isActive: true,
  order: 1,
  createdAt: new Date(),
  updatedAt: new Date()
})
```

---

## Best Practices

### Security
1. **Password Hashing**: Use bcrypt with salt rounds ≥ 10
2. **Indexes**: Create indexes on frequently queried fields
3. **Validation**: Use Mongoose schema validation
4. **Sanitization**: Sanitize user inputs to prevent injection

### Performance
1. **Pagination**: Limit results for large collections
2. **Projection**: Only select needed fields
3. **Indexes**: Create compound indexes for common queries
4. **Caching**: Cache frequently accessed data (Redis)

### Maintenance
1. **Backups**: Regular database backups
2. **Monitoring**: Track query performance
3. **Cleanup**: Archive old activity logs
4. **Updates**: Keep schema documentation current

---

*This schema documentation serves as the complete database reference for the Hakbang application backend development.*
