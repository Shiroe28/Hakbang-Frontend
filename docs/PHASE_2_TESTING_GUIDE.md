# 🧪 Phase 2 Testing Guide

## Overview
This guide provides step-by-step testing procedures for Phase 2 features: AI Career Quiz and Profile Management.

---

## Prerequisites

### Backend Requirements
Ensure these endpoints are implemented:

1. **POST /api/ai/recommendations** (Protected)
   ```json
   Request: {
     "quizResponses": [
       {"question": "...", "answer": "...", "answerIndex": 0}
     ]
   }
   Response: [Career objects array]
   ```

2. **PUT /api/users/profile** (Protected)
   ```json
   Request: {"username": "newname", "email": "new@email.com"}
   Response: {"success": true, "data": {updated user}}
   ```

### Setup
```powershell
# Terminal 1: Start Backend
cd C:\dev\Backend
npm start

# Terminal 2: Run Flutter App
cd C:\dev\Frontend
flutter run
```

---

## 🎯 Test Suite 1: AI Career Recommendation Quiz

### Test 1.1: Quiz Navigation & UI
**Steps:**
1. Login to the app
2. Navigate to **Home** tab
3. Locate "AI Career Recommendations" card
4. Tap the card

**Expected Results:**
- ✅ RecommendationQuizScreen opens
- ✅ Question 1 of 5 is displayed
- ✅ Progress indicator shows "1/5"
- ✅ Four answer options are visible
- ✅ "Previous" button is hidden (first question)
- ✅ "Next" button is disabled (no answer selected yet)

---

### Test 1.2: Answer Selection
**Steps:**
1. On Question 1, tap an answer option
2. Observe UI changes

**Expected Results:**
- ✅ Selected option is highlighted
- ✅ "Next" button becomes enabled
- ✅ Can change answer by tapping another option
- ✅ Progress indicator still shows "1/5"

---

### Test 1.3: Question Navigation
**Steps:**
1. Answer Question 1, tap "Next"
2. Answer Question 2, tap "Next"
3. Answer Question 3, tap "Previous"
4. Tap "Next" twice

**Expected Results:**
- ✅ Progress indicator updates (2/5, 3/5, etc.)
- ✅ "Previous" button appears after Question 1
- ✅ Going back preserves previous answers
- ✅ Navigation is smooth and responsive
- ✅ Question text and options change correctly

---

### Test 1.4: Quiz Submission
**Steps:**
1. Answer all 5 questions
2. On Question 5, tap "Get Recommendations" button
3. Wait for API response

**Expected Results:**
- ✅ Button text changes to "Get Recommendations" on last question
- ✅ Loading indicator appears
- ✅ API call is made to `/api/ai/recommendations`
- ✅ Quiz responses are sent in correct format
- ✅ RecommendationResultsScreen opens on success

---

### Test 1.5: Results Display
**Steps:**
1. View the results screen after quiz submission

**Expected Results:**
- ✅ "Your Personalized IT Career Matches!" header shows
- ✅ Recommended careers are displayed as cards
- ✅ Each card shows:
  - Rank badge (#1, #2, #3, etc.)
  - Career title
  - Description preview
  - Salary range
- ✅ Top 3 ranks have special colors (gold/silver/bronze)
- ✅ Can scroll if many results

---

### Test 1.6: Navigate to Career Details
**Steps:**
1. From results screen, tap a career card
2. View career detail screen

**Expected Results:**
- ✅ CareerDetailScreen opens
- ✅ Career title and full description display
- ✅ Modules list loads (if available)
- ✅ Can navigate back to results
- ✅ Can tap module to view details

---

### Test 1.7: Quiz Validation
**Steps:**
1. Start quiz
2. Do NOT answer Question 1
3. Try to tap "Next" button

**Expected Results:**
- ✅ "Next" button is disabled
- ✅ Cannot proceed without selecting answer
- ✅ No error messages shown (graceful prevention)

---

### Test 1.8: Quiz Error Handling
**Steps:**
1. Start quiz, answer all questions
2. **Stop the backend** (Ctrl+C in backend terminal)
3. Tap "Get Recommendations"

**Expected Results:**
- ✅ Loading indicator shows
- ✅ After timeout, error message appears
- ✅ SnackBar shows user-friendly error (e.g., "Failed to get recommendations")
- ✅ Stays on quiz screen (can retry when backend is back)

**Recovery:**
1. Restart backend
2. User can retake quiz or go back

---

## 👤 Test Suite 2: Profile Management

### Test 2.1: View Profile
**Steps:**
1. Navigate to **Profile** tab
2. Observe profile screen

**Expected Results:**
- ✅ User avatar displays (placeholder with icon)
- ✅ Username displays correctly
- ✅ Email displays correctly
- ✅ Role displays (Student/Mentor)
- ✅ "Edit Profile" option is visible
- ✅ "Logout" option is visible

---

### Test 2.2: Open Edit Profile
**Steps:**
1. From Profile screen, tap "Edit Profile"

**Expected Results:**
- ✅ EditProfileScreen opens
- ✅ Username field is pre-filled with current username
- ✅ Email field is pre-filled with current email
- ✅ Role field is read-only (shows role with lock icon)
- ✅ Avatar with camera icon displays (placeholder)
- ✅ "Save Changes" button is enabled

---

### Test 2.3: Edit Username
**Steps:**
1. In username field, change text to "NewTestUser"
2. Tap "Save Changes"
3. Wait for response

**Expected Results:**
- ✅ Button shows loading indicator
- ✅ API call made to `PUT /api/users/profile`
- ✅ Success SnackBar appears: "Profile updated successfully!"
- ✅ Automatically navigates back to Profile screen
- ✅ Profile screen shows updated username "NewTestUser"
- ✅ Dashboard also shows "Welcome back, NewTestUser!"

---

### Test 2.4: Edit Email
**Steps:**
1. Open edit profile
2. Change email to "newemail@test.com"
3. Save changes

**Expected Results:**
- ✅ Email updates successfully
- ✅ Profile screen reflects new email
- ✅ Can still login with new email on next app start

---

### Test 2.5: Edit Both Username and Email
**Steps:**
1. Open edit profile
2. Change username to "TestUser2"
3. Change email to "testuser2@example.com"
4. Save changes

**Expected Results:**
- ✅ Both fields update successfully
- ✅ UserProvider refreshes
- ✅ All screens show updated data

---

### Test 2.6: Username Validation
**Steps:**
1. Open edit profile
2. Clear username field
3. Type "ab" (less than 3 characters)
4. Try to tap "Save Changes"

**Expected Results:**
- ✅ Error message shows: "Username must be at least 3 characters"
- ✅ Save button triggers validation
- ✅ API call is NOT made
- ✅ Stays on edit screen

---

### Test 2.7: Email Validation
**Steps:**
1. Open edit profile
2. Change email to "invalidemail" (no @ symbol)
3. Try to save

**Expected Results:**
- ✅ Error message shows: "Please enter a valid email"
- ✅ API call is NOT made
- ✅ Form prevents submission

---

### Test 2.8: Cancel Edit
**Steps:**
1. Open edit profile
2. Make changes to username
3. Press back button (don't save)
4. View profile screen

**Expected Results:**
- ✅ Returns to profile screen
- ✅ Changes are NOT saved
- ✅ Profile shows original username

---

### Test 2.9: Profile Edit Error Handling
**Steps:**
1. Open edit profile
2. **Stop the backend**
3. Try to save changes

**Expected Results:**
- ✅ Loading indicator shows
- ✅ After timeout, error SnackBar appears
- ✅ Error message is user-friendly
- ✅ Stays on edit screen (can retry)
- ✅ Changes are preserved in form fields

---

### Test 2.10: Duplicate Email Error
**Steps:**
1. Open edit profile
2. Change email to another user's email (if backend validates)
3. Save

**Expected Results:**
- ✅ Backend returns 400/409 error
- ✅ App shows backend error message
- ✅ Stays on edit screen
- ✅ User can correct email

---

## 🔄 Test Suite 3: Integration Flows

### Test 3.1: Complete User Journey
**Full Flow:**
1. Login as new user
2. View dashboard (shows username)
3. Take AI quiz → View recommendations
4. Tap career → View modules
5. Tap module → Open external link
6. Go to Profile → Edit username/email
7. Return to dashboard → Verify updated username displays

**Expected Results:**
- ✅ All screens show consistent user data
- ✅ UserProvider keeps state synchronized
- ✅ Navigation flows smoothly
- ✅ No crashes or freezes

---

### Test 3.2: Provider State Synchronization
**Steps:**
1. Edit profile and change username to "UpdatedUser"
2. Without restarting app, navigate to:
   - Dashboard screen
   - Profile screen
   - Take quiz (shouldn't affect username)
   - Return to dashboard

**Expected Results:**
- ✅ All screens show "UpdatedUser"
- ✅ UserProvider.user is updated everywhere
- ✅ No need to logout/login to see changes

---

### Test 3.3: App Restart Persistence
**Steps:**
1. Edit profile, change username
2. Close app completely
3. Reopen app (should auto-login with stored token)
4. Check dashboard and profile

**Expected Results:**
- ✅ Auto-login works
- ✅ Updated username persists
- ✅ UserProvider loads from `/auth/me` on startup
- ✅ All data is correct

---

## 📊 Test Results Template

Use this template to track test results:

```markdown
## Test Execution Report

**Date:** 2025-10-15
**Tester:** [Your Name]
**App Version:** Phase 2
**Backend Status:** Running ✅

### AI Quiz Tests
- [ ] Test 1.1: Quiz Navigation & UI
- [ ] Test 1.2: Answer Selection
- [ ] Test 1.3: Question Navigation
- [ ] Test 1.4: Quiz Submission
- [ ] Test 1.5: Results Display
- [ ] Test 1.6: Navigate to Career Details
- [ ] Test 1.7: Quiz Validation
- [ ] Test 1.8: Quiz Error Handling

### Profile Tests
- [ ] Test 2.1: View Profile
- [ ] Test 2.2: Open Edit Profile
- [ ] Test 2.3: Edit Username
- [ ] Test 2.4: Edit Email
- [ ] Test 2.5: Edit Both Fields
- [ ] Test 2.6: Username Validation
- [ ] Test 2.7: Email Validation
- [ ] Test 2.8: Cancel Edit
- [ ] Test 2.9: Error Handling
- [ ] Test 2.10: Duplicate Email Error

### Integration Tests
- [ ] Test 3.1: Complete User Journey
- [ ] Test 3.2: Provider State Sync
- [ ] Test 3.3: App Restart Persistence

**Issues Found:** [List any bugs or issues]
**Overall Status:** [Pass/Fail]
```

---

## 🐛 Common Issues & Troubleshooting

### Issue 1: "Failed to get recommendations"
**Cause:** Backend `/api/ai/recommendations` not implemented
**Fix:** 
- Check backend has the endpoint
- Verify it returns array of Career objects
- Check auth token is included in request

### Issue 2: Profile changes don't show on dashboard
**Cause:** UserProvider not refreshing
**Fix:**
- Check `EditProfileScreen` calls `provider.loadCurrentUser()` after save
- Verify `/auth/me` endpoint returns updated user

### Issue 3: Quiz crashes on submission
**Cause:** Missing quiz response data
**Fix:**
- Check all 5 questions are answered
- Verify `_answers` map has 5 entries
- Check request body format

### Issue 4: Can't open module URLs
**Cause:** url_launcher not configured
**Fix:**
- Android: Check `AndroidManifest.xml` has queries
- iOS: Check `Info.plist` has LSApplicationQueriesSchemes

---

## ✅ Phase 2 Testing Checklist

Before marking Phase 2 as complete, ensure:

- [ ] Backend endpoints are implemented and working
- [ ] All 18 test cases pass
- [ ] No crashes or unhandled exceptions
- [ ] Loading states display correctly
- [ ] Error messages are user-friendly
- [ ] Form validation works properly
- [ ] UserProvider state synchronizes across screens
- [ ] Data persists after app restart
- [ ] Navigation flows are intuitive
- [ ] UI is responsive and polished

---

**Happy Testing! 🚀**

If you find any issues, document them and create bug reports. Phase 2 is production-ready when all tests pass! ✅
