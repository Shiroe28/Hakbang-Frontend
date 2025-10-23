# 🧪 Quick Test Guide - Career Exploration Feature

## ⚡ Hot Reload Now!

If your app is running in Chrome, **press `r` in your terminal** to see the new features!

---

## 🎯 Test Checklist

### 1. Login/Main Screen
- [ ] Login with your account
- [ ] See MainScreen with 4 tabs at bottom:
  - Home
  - Careers  
  - Community
  - Profile

---

### 2. Home Tab
- [ ] See welcome message with your username
- [ ] See your role badge (Student/Mentor)
- [ ] See "Your Journey" section with cards
- [ ] Tap "Explore Careers" card
- [ ] **Expected:** Switches to Careers tab

---

### 3. Careers Tab (List)
- [ ] See "IT Careers" in AppBar
- [ ] **If backend has data:** See list of career cards
- [ ] **If backend is empty:** See "No careers available" message
- [ ] Each career card shows:
  - [ ] Work icon
  - [ ] Career title
  - [ ] Description (3 lines)
  - [ ] Salary range with money icon
  - [ ] Arrow icon
- [ ] Pull down to refresh (spinner appears)
- [ ] Tap any career card

---

### 4. Career Detail Screen
- [ ] See gradient header with:
  - [ ] Career icon
  - [ ] Career title
  - [ ] Full description
  - [ ] Salary badge
- [ ] Scroll down to "Learning Roadmap"
- [ ] See module cards:
  - [ ] Module numbers (1, 2, 3...)
  - [ ] Module titles
  - [ ] Module descriptions
  - [ ] Content type badges (LINK, VIDEO, etc.)
- [ ] **If no modules:** See "No modules available yet"
- [ ] Tap back button to return to list

---

### 5. Community Tab
- [ ] Switch to Community tab
- [ ] See "Coming Soon" message
- [ ] See forum icon

---

### 6. Profile Tab
- [ ] Switch to Profile tab
- [ ] See your avatar with role icon
- [ ] See your username
- [ ] See role badge (STUDENT or MENTOR)
- [ ] See profile info card:
  - [ ] Username
  - [ ] Email
  - [ ] Role
- [ ] See settings options:
  - [ ] Edit Profile
  - [ ] Notifications
  - [ ] Help & Support
- [ ] Tap "Edit Profile" → See "coming soon" message
- [ ] See red Logout button
- [ ] Tap Logout
- [ ] **Expected:** Confirmation dialog appears
- [ ] Tap "Logout" in dialog
- [ ] **Expected:** Redirected to login screen

---

## 🔄 Navigation Test

- [ ] Login again
- [ ] Switch between all 4 tabs
- [ ] **Expected:** Each tab remembers its state
- [ ] Go to Careers → tap a career → see details
- [ ] Tap back → return to careers list
- [ ] Switch to different tab → switch back to Careers
- [ ] **Expected:** Still see the careers list (not reset)

---

## 🐛 What If...

### No Careers Showing?
**Check:**
1. Is backend running? (`npm start` in backend directory)
2. Backend accessible at `http://localhost:3000`?
3. Check browser console (F12) for errors
4. Try pull-to-refresh in the app

### No Modules Showing?
**Check:**
1. Does this career have modules in the database?
2. Check browser console for API errors
3. Backend should have modules with `careerId` matching the career

### App Shows Error?
1. Check browser console (F12)
2. Check terminal where Flutter is running
3. Check backend terminal for errors
4. Try hot restart (press `R` in terminal)

---

## 📊 Expected API Calls

When testing, these API calls should happen:

### On Careers Tab:
```
GET http://localhost:3000/api/careers
```

### On Career Detail:
```
GET http://localhost:3000/api/learning/modules?careerId=<career_id>
```

You can see these in:
- Chrome DevTools → Network tab
- Backend terminal (should show requests)

---

## 🎨 Visual Checklist

### Color Coding
- [ ] Blue primary color throughout
- [ ] Blue badges for Students
- [ ] Purple badges for Mentors
- [ ] Green for salary ranges
- [ ] Red for logout button

### Icons Present
- [ ] Home icon in bottom nav
- [ ] Work/briefcase icon in Careers tab
- [ ] Forum icon in Community tab
- [ ] Person icon in Profile tab
- [ ] Icons in career cards
- [ ] Module number badges

### Animations
- [ ] Smooth tab switching
- [ ] Card tap feedback (ripple effect)
- [ ] Loading spinners
- [ ] Pull-to-refresh indicator

---

## ✅ Success Criteria

Your implementation is working if:

1. ✅ You can see all 4 tabs in bottom navigation
2. ✅ Careers tab shows list of careers (if backend has data)
3. ✅ Tapping a career shows its details
4. ✅ Career detail shows modules (if career has modules)
5. ✅ Profile shows your correct information
6. ✅ Logout works and returns to login screen
7. ✅ No errors in console
8. ✅ Navigation is smooth and responsive

---

## 🚀 Quick Commands

```bash
# Hot reload (fast updates)
Press 'r' in terminal

# Hot restart (full restart)
Press 'R' in terminal

# If stuck, restart completely:
Press 'q' to quit
flutter run -d chrome
```

---

## 💡 Sample Data for Testing

If you don't have data in your backend yet, you can:

1. **Use the React admin panel** to add careers and modules
2. **Add via backend API** directly
3. **Test with empty states** - the app handles it gracefully!

### Minimum Test Data:
- At least 2-3 careers
- Each career should have 3-5 modules
- Modules should have `careerId` matching the career `_id`

---

## 📱 Best Testing Flow

1. **First Run:**
   - Login
   - Explore each tab
   - Check everything appears

2. **Career Flow:**
   - Go to Careers tab
   - Scroll through list
   - Tap a career
   - View modules
   - Go back
   - Tap another career

3. **Navigation:**
   - Switch between tabs multiple times
   - Verify state persistence

4. **Logout:**
   - Go to Profile
   - Logout
   - Login again

5. **Error Handling:**
   - Stop backend
   - Try to load careers
   - See error message
   - Start backend
   - Tap retry
   - See careers load

---

## 🎉 You Did It!

If everything above works, your Career Exploration feature is **fully functional**!

**Next up:** Build the Module Detail screen and Quiz feature! 🚀
