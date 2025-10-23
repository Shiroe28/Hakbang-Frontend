# ✅ Hakbang App - Testing Checklist

Use this checklist to verify all fixes are working correctly.

## Prerequisites
- [ ] Backend is running on `http://localhost:3000`
- [ ] Flutter app is running (`flutter run -d chrome`)
- [ ] You have a test account created

---

## 🧪 Test Cases

### 1. Username Display on Homepage
- [ ] Login with your account
- [ ] Navigate to Dashboard (Home tab)
- [ ] Check if "Welcome back, [Your Username]!" appears
- [ ] Username should match what you registered with
- **Expected:** Username loads from API within 1-2 seconds

---

### 2. Career-Specific Module Filtering
- [ ] Go to Careers tab
- [ ] Click on "Web Developer" career
- [ ] Count the modules shown
- [ ] Go back and click on "Data Scientist" career
- [ ] Verify modules are different for each career
- **Expected:** Each career shows only its own modules, not all modules

---

### 3. Learning Modules Card Navigation
- [ ] Go to Dashboard (Home tab)
- [ ] Scroll to "Learning Modules" card
- [ ] Click on the card
- **Expected:** App switches to Careers tab

---

### 4. AI Career Recommendation Quiz
- [ ] Go to Dashboard (Home tab)
- [ ] Click "AI Career Recommendations" card
- [ ] Answer all 8 questions
- [ ] Click "Submit" button
- [ ] Wait for results screen
- **Expected:** See recommended careers with match percentages

---

### 5. AI Career Mentor Chatbot
- [ ] Go to Dashboard (Home tab)
- [ ] Click "AI Career Mentor" card
- [ ] Type: "What career should I choose?"
- [ ] Press Send
- [ ] Type: "Tell me about web development"
- [ ] Press Send
- [ ] Type: "How much can I earn?"
- [ ] Press Send
- **Expected:** Get detailed, helpful responses to each question

---

### 6. Notifications System
- [ ] Click the bell icon in the app bar
- [ ] Check if 4 sample notifications appear
- [ ] Note how many are unread (should show badge)
- [ ] Tap on an unread notification
- [ ] Verify it becomes grayed out (marked as read)
- [ ] Click "Mark all read" button at top
- [ ] Verify all notifications are now read
- **Expected:** Notifications are interactive and update visual state

---

### 7. Help & Support Features
- [ ] Go to Profile tab
- [ ] Click "Help & Support"
- [ ] Click "Search FAQs" card
- [ ] Read through the FAQ dialog
- [ ] Close the dialog
- [ ] Click "Live Chat" card
- [ ] Note the message pointing to AI Mentor
- [ ] Click "Email Support" card
- [ ] Check if email client opens or shows email address
- **Expected:** FAQs dialog opens with helpful information

---

### 8. Create Community Post
- [ ] Go to Community tab
- [ ] Click the blue + (floating action button)
- [ ] Enter a test title (e.g., "My First Post")
- [ ] Enter test content (e.g., "Hello everyone!")
- [ ] Click "Post" button
- [ ] Wait for loading to finish
- [ ] Check for success message
- [ ] Scroll through community feed
- [ ] Verify your post appears (if backend works)
- **Expected:** Post creation dialog works, shows loading, displays success/error

---

### 9. Edit Profile Access
- [ ] Go to Profile tab
- [ ] Wait for profile to load (username should appear)
- [ ] Click "Edit Profile" card
- [ ] Verify Edit Profile screen opens
- [ ] See your current username, email displayed
- [ ] Check if fields are editable
- [ ] Try changing username
- [ ] Click "Update Profile" button
- **Expected:** Edit Profile screen opens and allows editing

---

## 🔍 Common Issues & Solutions

### ❌ Username doesn't show
**Solution:** 
1. Wait 2-3 seconds after login (API is fetching data)
2. Check browser console for errors
3. Verify backend is running
4. Try hot reload (press `r` in terminal)

### ❌ Modules not filtered
**Solution:**
1. Check backend `/api/learning/modules?careerId={id}` endpoint
2. Verify backend is filtering by careerId parameter
3. Check database has careerId field on modules

### ❌ Quiz doesn't show results
**Solution:**
1. Check backend `/api/ai/recommendations` endpoint is working
2. Open browser console to see error messages
3. Verify backend returns array of careers

### ❌ Can't create posts
**Solution:**
1. Verify backend has POST `/api/community/posts` endpoint
2. Check if you're logged in (token exists)
3. Check backend logs for errors

### ❌ Edit Profile won't open
**Solution:**
1. Make sure username appeared on dashboard first
2. Wait for user data to load (fixed in Issue #1)
3. Check console for errors

---

## 📊 Results

Mark each test as:
- ✅ PASS - Feature works as expected
- ⚠️ PARTIAL - Feature works but has minor issues
- ❌ FAIL - Feature doesn't work
- ⏭️ SKIP - Can't test (missing backend, etc.)

### Overall Status: _____ / 9 tests passed

---

## 📝 Notes

Use this space to write down any issues you encounter:

```
1. 

2. 

3. 

```

---

## 🚀 Next Steps After Testing

If all tests pass:
- ✅ App is fully functional!
- Consider adding real AI API for better chatbot
- Implement backend photo upload for profiles
- Add more community features (comments, likes)

If some tests fail:
- Check the ISSUES_FIXED.md troubleshooting section
- Verify backend endpoints are working
- Check browser console for errors
- Review backend logs for API errors

---

**Testing Date:** __________________  
**Tester Name:** __________________  
**Browser/Platform:** __________________
