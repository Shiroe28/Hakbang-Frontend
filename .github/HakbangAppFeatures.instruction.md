# Hakbang App Features Documentation

This document outlines all the screens and features of the Hakbang application organized by functional area.

---

## **Main Menu / Navigation (5 Screens)**

### 1. **Splash / Loading Screen**
- **Purpose:** Initial app loading
- **Features:**
  - App logo and name display
  - Quick loading animation
  - Auto-navigation to Login or Home (if logged in)
- **File:** `lib/screens/splash_screen.dart`

### 2. **Login / Sign-up Page**
- **Purpose:** User authentication
- **Features:**
  - Email and password fields
  - "Forgot Password" option
  - "Register" navigation button
  - Google sign-in integration
  - Form validation
  - Error handling
- **Files:** 
  - `lib/screens/login_screen.dart`
  - `lib/screens/register_screen.dart`

### 3. **Home Dashboard**
- **Purpose:** Central hub showing user overview
- **Features:**
  - Welcome message with username
  - Learning progress overview
  - AI career suggestions summary
  - Quick action cards:
    - Explore Careers
    - Learning Modules
    - AI Career Quiz
    - Badges & Achievements
    - AI Mentor
  - Recent notifications/updates
- **File:** `lib/screens/main_screen.dart` (Dashboard tab)

### 4. **Main Navigation Bar**
- **Purpose:** App-wide navigation
- **Features:**
  - Bottom navigation with 4 tabs:
    - 🏠 Home (Dashboard)
    - 🎯 Careers (Career Tracker)
    - 💬 Community (Insights/Discussion)
    - 👤 Profile (User settings)
  - Active tab highlighting
  - Badge indicators for notifications
- **File:** `lib/screens/main_screen.dart`

### 5. **Notifications / Inbox Page**
- **Purpose:** Display system alerts and updates
- **Features:**
  - List of notifications with icons
  - Unread count badge
  - Mark as read functionality
  - "Mark all as read" button
  - Time formatting (e.g., "3h ago")
  - Color-coded by type (system, mentor, update)
  - Empty state message
- **File:** `lib/screens/notifications_screen.dart`

---

## **Career Path & Learning Tracker (7 Screens)**

### 1. **Career Path Overview**
- **Purpose:** Browse all available IT careers
- **Features:**
  - Grid/list of IT career cards
  - Career titles with icons
  - Salary range preview
  - Filter or search option
  - Tap to view details
- **File:** `lib/screens/careers_screen.dart`

### 2. **Career Details Page**
- **Purpose:** Show comprehensive career information
- **Features:**
  - Career title and icon
  - Detailed role description
  - Salary range information
  - Required skills list
  - Career roadmap visualization
  - Related learning modules list
  - "Start Learning" button
  - Career-specific module filtering
- **File:** `lib/screens/career_detail_screen.dart`

### 3. **Learning Progress Page**
- **Purpose:** Track overall learning progress
- **Features:**
  - Progress bars for each career path
  - Checklist of completed skills
  - Module completion statistics
  - Total hours learned
  - Current learning streak
  - Next suggested module
- **File:** `lib/screens/progress_screen.dart`

### 4. **Course or Module Page**
- **Purpose:** Display individual module content
- **Features:**
  - Module title and description
  - Content type indicator (video, document, link)
  - External link or embedded content
  - Duration estimate
  - "Mark as Completed" button
  - Progress saving
  - Navigation to next module
  - Related assessments
- **File:** `lib/screens/module_detail_screen.dart`

### 5. **Milestones & Badges Page**
- **Purpose:** Show achievements and gamification
- **Features:**
  - Grid of earned badges
  - Locked/unlocked badge states
  - Badge descriptions
  - Achievement dates
  - Motivational statistics
  - Progress to next badge
  - Share achievements option
- **File:** `lib/screens/badges_screen.dart`

### 6. **Assessment Page**
- **Purpose:** Test user knowledge
- **Features:**
  - Module-specific quizzes
  - Multiple choice questions
  - Progress indicator
  - Question navigation
  - Timer (optional)
  - Submit answers
  - Instant feedback
  - Score display
  - Retry option
- **File:** `lib/screens/assessment_screen.dart`

### 7. **Recommendation Quiz Screen**
- **Purpose:** AI-powered career matching
- **Features:**
  - 8-question personality/skill assessment
  - Question progress bar
  - Multiple choice answers
  - "Next" and "Previous" buttons
  - Answer validation
  - Submit to AI for analysis
  - Results screen with career matches
- **Files:**
  - `lib/screens/recommendation_quiz_screen.dart`
  - `lib/screens/recommendation_results_screen.dart`

---

## **AI-Powered Features (5 Screens)**

### 1. **AI Career Recommendation Screen**
- **Purpose:** Show personalized career suggestions
- **Features:**
  - List of recommended IT careers
  - Match percentage for each career
  - "Why this fits you" explanation
  - Salary and growth info
  - "Save" or "Explore More" options
  - Navigate to career details
- **File:** `lib/screens/recommendation_results_screen.dart`

### 2. **AI Chatbot / Virtual Mentor**
- **Purpose:** Conversational career guidance
- **Features:**
  - Chat interface
  - Message history
  - User and AI message bubbles
  - Text input field
  - Send button
  - Career guidance responses
  - Resume advice
  - Skill recommendations
  - Motivational support
  - Learning tips
  - Salary information
- **File:** `lib/screens/ai_chatbot_screen.dart`

### 3. **AI Resume Builder**
- **Purpose:** Create and improve resumes
- **Features:**
  - Resume data input form
  - Auto-fill from profile
  - AI-generated suggestions
  - Resume scoring/rating
  - Download/export options
  - Multiple templates
  - Skills highlighting
  - Experience formatting
- **File:** `lib/screens/resume_builder_screen.dart` (to be implemented)

### 4. **Skill Gap Analyzer**
- **Purpose:** Identify learning needs
- **Features:**
  - Current skills assessment
  - Target career comparison
  - Gap visualization
  - Suggested learning paths
  - Module recommendations
  - Estimated time to fill gaps
  - Priority ranking
- **File:** `lib/screens/skill_gap_screen.dart` (to be implemented)

### 5. **AI Career Simulation**
- **Purpose:** Experience career scenarios
- **Features:**
  - "Day in the life" interactive stories
  - Decision-based scenarios
  - Role-playing exercises
  - Task simulations
  - Feedback on choices
  - Career insight points
  - Scenario completion badges
- **File:** `lib/screens/career_simulation_screen.dart` (to be implemented)

---

## **Backend / System Management (5 Screens)**

### 1. **Admin Dashboard**
- **Purpose:** System overview for administrators
- **Features:**
  - Total user count
  - Active users today
  - Engagement statistics
  - Module completion rates
  - AI feature usage stats
  - Recent activity feed
  - Quick action buttons
  - Data visualization charts
- **File:** `lib/screens/admin_dashboard_screen.dart` (to be implemented)

### 2. **User Management Page**
- **Purpose:** Manage system users
- **Features:**
  - User list with search
  - Filter by role (student/mentor/admin)
  - Add new user button
  - Edit user details
  - Delete/deactivate users
  - Role assignment
  - User activity logs
  - Bulk actions
- **File:** `lib/screens/admin_users_screen.dart` (to be implemented)

### 3. **Data Analytics Page**
- **Purpose:** System insights and metrics
- **Features:**
  - Learning activity graphs
  - AI usage statistics
  - User engagement trends
  - Module popularity charts
  - Career interest distribution
  - Export to CSV/PDF
  - Date range filtering
  - Comparison views
- **File:** `lib/screens/admin_analytics_screen.dart` (to be implemented)

### 4. **Feedback & Reports Page**
- **Purpose:** Handle user feedback
- **Features:**
  - List of user feedback
  - Filter by category (feedback/bug/suggestion)
  - Status indicators (pending/reviewed/resolved)
  - Reported issues details
  - Admin response field
  - Resolution tracking
  - Priority levels
  - Email notifications
- **File:** `lib/screens/admin_feedback_screen.dart` (to be implemented)

### 5. **Content Management Page**
- **Purpose:** Manage learning materials
- **Features:**
  - Add new modules
  - Edit existing content
  - Upload documents/links
  - Assign modules to careers
  - Update AI prompts
  - Content approval workflow
  - Version control
  - Preview changes
- **File:** `lib/screens/admin_content_screen.dart` (to be implemented)

---

## **User & Profile Management (4 Screens)**

### 1. **User Profile Page**
- **Purpose:** Display user information
- **Features:**
  - Profile photo display
  - Name and username
  - Email address
  - Current role/career interest
  - Learning goals
  - Progress summary statistics
  - Total modules completed
  - Badges earned count
  - Account creation date
  - Last login info
- **File:** `lib/screens/profile_screen.dart`

### 2. **Edit Profile Screen**
- **Purpose:** Modify user information
- **Features:**
  - Change profile picture
  - Upload photo from gallery/camera
  - Edit name/username
  - Update email address
  - Change bio/description
  - Modify learning goals
  - Update career interests
  - Save changes button
  - Form validation
  - Success/error feedback
- **File:** `lib/screens/edit_profile_screen.dart`

### 3. **Account Settings**
- **Purpose:** App preferences and security
- **Features:**
  - Change password
  - Two-factor authentication
  - Dark mode toggle
  - Notification preferences
  - Email notifications on/off
  - Push notifications settings
  - Language selection
  - Privacy settings
  - Data export
  - Account deletion
- **File:** `lib/screens/settings_screen.dart`

### 4. **Activity History Page**
- **Purpose:** Track user actions
- **Features:**
  - Chronological activity log
  - Module completions
  - Quiz attempts
  - AI session history
  - Community posts
  - Date filtering
  - Search functionality
  - Export history
- **File:** `lib/screens/activity_history_screen.dart` (to be implemented)

---

## **Community & Support (3 Screens)**

### 1. **Forum / Discussion Page**
- **Purpose:** Community engagement
- **Features:**
  - Topic/post list
  - Filter by category (Career, Skills, General)
  - Post title and preview
  - Author information with role badge
  - Comment count
  - Like/upvote count
  - Time posted
  - Search discussions
  - Sort options (recent, popular, trending)
  - Create new post button
- **File:** `lib/screens/community_screen.dart`

### 2. **Mentorship Page**
- **Purpose:** Connect with mentors
- **Features:**
  - Available mentors list
  - Mentor profiles and expertise
  - Schedule mentorship sessions
  - Chat with mentors
  - Session history
  - Mentor rating/reviews
  - Request mentorship button
  - Upcoming sessions calendar
  - Mentor matching suggestions
- **File:** `lib/screens/mentorship_screen.dart` (to be implemented)

### 3. **Help Center / Contact Us**
- **Purpose:** User support
- **Features:**
  - Frequently Asked Questions (FAQ)
  - Search FAQs
  - Troubleshooting guides
  - Contact form
  - Email support link
  - Live chat option (coming soon)
  - Video tutorials section
  - User guide access
  - Report a bug
  - Feature requests
- **File:** `lib/screens/help_support_screen.dart`

---

## **Implementation Status**

### ✅ **Fully Implemented**
- Splash Screen
- Login/Register
- Home Dashboard
- Main Navigation
- Notifications
- Career Overview
- Career Details
- Module Details
- AI Chatbot
- Community Forum
- Profile Management
- Edit Profile
- Help & Support

### 🚧 **Partially Implemented**
- Progress Tracking (basic implementation)
- Badges Screen (placeholder with sample data)
- Assessment/Quiz (structure exists, needs backend)

### ❌ **Not Yet Implemented**
- Resume Builder
- Skill Gap Analyzer
- Career Simulation
- Admin Dashboard
- User Management
- Data Analytics
- Feedback Management
- Content Management
- Activity History
- Mentorship System

---

## **Screen Count Summary**

| Category | Screens | Implemented | Pending |
|----------|---------|-------------|---------|
| Navigation | 5 | 5 | 0 |
| Career & Learning | 7 | 4 | 3 |
| AI Features | 5 | 2 | 3 |
| Admin/Backend | 5 | 0 | 5 |
| Profile/User | 4 | 3 | 1 |
| Community | 3 | 2 | 1 |
| **TOTAL** | **29** | **16** | **13** |

---

## **Navigation Flow**

```
Splash Screen
    ↓
Login/Register
    ↓
Main Navigation (Bottom Tabs)
    ├── Home (Dashboard)
    │   ├── Explore Careers → Careers Screen → Career Details → Module Details
    │   ├── Learning Modules → Careers Screen
    │   ├── AI Quiz → Quiz Screen → Results Screen
    │   ├── Badges → Badges Screen
    │   └── AI Mentor → Chatbot Screen
    │
    ├── Careers (Career Tracker)
    │   └── Career Cards → Career Details → Module Details
    │
    ├── Community
    │   ├── Forum Posts
    │   └── Create Post
    │
    └── Profile
        ├── View Profile
        ├── Edit Profile
        ├── Settings
        ├── Help & Support
        └── Logout
```

---

## **Key Features by User Role**

### **Student Role**
- Browse and select career paths
- Complete learning modules
- Take assessments/quizzes
- Get AI career recommendations
- Chat with AI mentor
- Track progress and earn badges
- Participate in community
- View profile and settings

### **Mentor Role** (Future)
- All student features
- Respond to student questions in community
- Schedule mentorship sessions
- View assigned students
- Provide career guidance
- Review student progress

### **Admin Role** (Future)
- All student features
- Access admin dashboard
- Manage users
- View analytics
- Handle feedback and reports
- Manage content/modules
- System configuration

---

## **Dependencies & Integrations**

### **External Services**
- Backend API (Node.js) - All data operations
- AI Service - Career recommendations and chatbot
- Email Service - Notifications and support
- Cloud Storage - Profile photos and documents (future)

### **Flutter Packages**
- `provider` - State management
- `http` - API calls
- `flutter_secure_storage` - Token storage
- `url_launcher` - Open external links
- Material Design - UI components

---

## **Future Enhancements**

1. **Offline Mode** - Cache modules for offline access
2. **Push Notifications** - Real-time alerts for mentorship and updates
3. **Social Sharing** - Share achievements on social media
4. **Video Content** - Embedded video tutorials
5. **Gamification** - Leaderboards and competitions
6. **Multi-language** - Support for multiple languages
7. **Dark Mode** - Complete dark theme implementation
8. **Voice Assistant** - Voice-based AI mentor interaction
9. **AR/VR** - Virtual career simulations
10. **Mobile App** - Native iOS/Android releases

---

*This document serves as the complete feature reference for the Hakbang application development.*
