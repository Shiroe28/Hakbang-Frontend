# Phase 1 Integration Testing Guide

## Prerequisites

1. **Backend Running**: Your Node.js backend must be running on `http://localhost:3000`
2. **Endpoint Ready**: The `GET /api/auth/me` endpoint must be implemented and working
3. **Test Data**: Ensure you have:
   - At least one registered user account
   - At least one career with modules in the database

---

## Test Scenario 1: User Authentication & Welcome Message

### Steps:
1. Launch the app (`flutter run`)
2. If not logged in, you should see the **LoginScreen**
3. Enter valid credentials and tap **Login**
4. After successful login, you should be redirected to **MainScreen**
5. Navigate to the **Dashboard** tab

### Expected Results:
- ✅ Dashboard AppBar shows **"Welcome back, [username]!"** (not just "Dashboard")
- ✅ User card displays your role badge (STUDENT or MENTOR)
- ✅ Username and email are displayed on the dashboard card

### What to Check:
- Username matches what's in your backend database
- No loading spinner stuck on the dashboard
- No error messages in the console

---

## Test Scenario 2: Career Roadmap Display

### Steps:
1. From MainScreen, navigate to the **Careers** tab
2. You should see a list of available career paths
3. Tap on any career card

### Expected Results:
- ✅ **CareerDetailScreen** opens showing:
  - Career title in the AppBar
  - Career header with gradient background
  - Career description and salary range
  - "Learning Roadmap" section
- ✅ Modules are displayed in a list below the roadmap section
- ✅ Each module card shows:
  - Module number badge (or checkmark if completed)
  - Module title
  - Module description (truncated to 2 lines)
  - Content type badge (LINK, VIDEO, etc.)
  - Right arrow icon

### What to Check:
- Loading spinner shows briefly while modules are fetched
- If no modules exist, shows "No modules available yet" message
- If API error occurs, shows error message with "Retry" button

---

## Test Scenario 3: Module Detail & URL Launcher

### Steps:
1. From the **CareerDetailScreen**, tap on any module card
2. **ModuleDetailScreen** should open

### Expected Results:
- ✅ Screen shows:
  - Module title in gradient header
  - Content type icon and badge
  - "About This Module" section with full description
  - Blue "Learning Resource" info card
  - **"Start Learning"** button with external link icon
  - "Mark as Complete" button (disabled if already completed)
3. Tap the **"Start Learning"** button

### Expected Results:
- ✅ Device's default web browser opens
- ✅ The module's `contentURL` is loaded in the browser
- ✅ If URL can't be opened, a red SnackBar shows error message

### What to Check:
- URL opens correctly (not a 404 or broken link)
- App remains responsive after opening browser
- Can navigate back to the app using device back button

---

## Test Scenario 4: Navigation Flow (End-to-End)

### Complete User Journey:
1. **Start**: Launch app → Login
2. **Dashboard**: See "Welcome back, [username]!"
3. **Careers**: Navigate to Careers tab → See career list
4. **Career Detail**: Tap a career → See modules list
5. **Module Detail**: Tap a module → See module details
6. **External Learning**: Tap "Start Learning" → Browser opens with module URL
7. **Navigate Back**: Use back button through all screens
8. **Logout**: Tap logout from dashboard → Return to LoginScreen

### Expected Results:
- ✅ All navigation transitions are smooth
- ✅ No crashes or blank screens
- ✅ Data persists across navigation (username still shows after navigating back)
- ✅ After logout, username is cleared and LoginScreen shows

---

## Test Scenario 5: App Restart (Persistence Check)

### Steps:
1. Login to the app
2. Navigate to Dashboard (see username)
3. Close the app completely (force stop or swipe away)
4. Reopen the app

### Expected Results:
- ✅ App automatically shows **MainScreen** (not LoginScreen)
- ✅ Dashboard shows "Welcome back, [username]!" immediately
- ✅ User data is loaded from `/api/auth/me` on startup

### What to Check:
- Brief loading spinner on startup while checking auth status
- No "null" or empty username displayed
- If backend is down, app should still show cached username from secure storage

---

## Test Scenario 6: Error Handling

### Test 6A: Backend Down (Modules Fetch)
1. Stop your Node.js backend
2. Navigate to a career's detail screen
3. Expected: Error message shows with "Retry" button
4. Start backend again
5. Tap "Retry" → Modules load successfully

### Test 6B: Invalid URL
1. Manually edit a module's `contentURL` in the database to an invalid URL (e.g., "invalid-url")
2. Navigate to that module's detail screen
3. Tap "Start Learning"
4. Expected: Red SnackBar shows "Could not open the link"

### Test 6C: Network Timeout
1. Slow down your network (if possible)
2. Navigate to Career Detail
3. Expected: Loading spinner shows for longer, then either loads or shows error

---

## Common Issues & Fixes

### Issue 1: Username not showing on Dashboard
**Symptoms**: AppBar shows "Dashboard" instead of "Welcome back, [username]!"
**Possible Causes**:
- Backend `/api/auth/me` endpoint not implemented
- Token not saved correctly during login
- UserProvider not loading data on startup

**Debug Steps**:
1. Check console for API errors
2. Verify token exists in secure storage
3. Add print statements in `UserProvider.loadCurrentUser()`

---

### Issue 2: "Could not open the link" error
**Symptoms**: Browser doesn't open when tapping "Start Learning"
**Possible Causes**:
- Module's `contentURL` is malformed or empty
- url_launcher not properly configured for platform

**Debug Steps**:
1. Check module data in database (ensure `contentURL` is valid)
2. Test with a known-good URL (e.g., "https://www.google.com")
3. Check url_launcher platform setup (Android/iOS manifest/plist)

---

### Issue 3: Modules list is empty
**Symptoms**: "No modules available yet" message shows even though modules exist
**Possible Causes**:
- Career ID mismatch between frontend and backend
- Backend `/api/learning/modules?careerId=` not returning data

**Debug Steps**:
1. Check console logs for API response
2. Verify career ID being passed to API call
3. Test API endpoint directly with Postman/curl

---

## Automated Testing

Run the existing widget test:
```powershell
flutter test
```

**Expected Output**:
```
00:02 +1: All tests passed!
```

---

## Manual Testing Checklist

- [ ] Login with valid credentials → Dashboard shows username
- [ ] Navigate to Careers → See career list
- [ ] Tap a career → See modules list
- [ ] Tap a module → See module details
- [ ] Tap "Start Learning" → Browser opens with URL
- [ ] Navigate back through all screens → No crashes
- [ ] Logout → Return to LoginScreen
- [ ] Restart app → Auto-login and show username
- [ ] Test with backend down → Proper error messages
- [ ] Test with invalid URL → Proper error handling

---

## Performance Checks

- [ ] No visible lag when navigating between screens
- [ ] Loading spinners appear/disappear correctly
- [ ] No memory leaks (app doesn't slow down after extensive use)
- [ ] Images/gradients render smoothly
- [ ] ListView scrolling is smooth (no jank)

---

## Platform-Specific Testing

### Android
- [ ] Back button works correctly on all screens
- [ ] Browser opens correctly when tapping "Start Learning"
- [ ] Status bar color matches app theme

### iOS (if testing)
- [ ] Swipe-back gesture works correctly
- [ ] Safari opens correctly when tapping "Start Learning"
- [ ] Safe area insets respected

### Web (if testing)
- [ ] All screens render correctly
- [ ] URL launcher opens link in new tab
- [ ] Responsive layout works

---

## Success Criteria

Phase 1 is considered fully functional if:
1. ✅ User can login and see their username on the dashboard
2. ✅ User can browse careers and see their modules
3. ✅ User can tap a module and see its details
4. ✅ User can open module learning resource in browser
5. ✅ All navigation works smoothly without crashes
6. ✅ Errors are handled gracefully with user-friendly messages
7. ✅ Data persists across app restarts

---

## Next Steps After Testing

Once Phase 1 is validated:
- Proceed to **Phase 2**: AI Career Recommendation Quiz
- Implement profile editing functionality
- Add "Mark as Complete" feature for modules
- Build Phase 3 Community features

---

**Happy Testing! 🧪✨**
