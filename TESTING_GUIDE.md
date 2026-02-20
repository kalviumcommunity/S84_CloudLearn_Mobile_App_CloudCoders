# Firebase Integration - Quick Testing Guide

## 🧪 Quick Test Checklist

Use this guide to quickly verify all Firebase features are working correctly.

### Before You Start
- [ ] Emulator or physical device is ready
- [ ] Internet connection is available
- [ ] Firebase Project is active in console
- [ ] Firebase Console tab is open for verification

---

## Test 1: User Registration ⟳

**Objective**: Create a new user account via Firebase

**Steps**:
1. Launch the app
2. On AuthScreen, ensure "Sign Up" mode is selected
3. Enter:
   - Email: `testuser@cloudlearn.com`
   - Password: `SecurePass123`
4. Click "Sign Up" button
5. Verify success message appears

**Verification**:
- ✅ No error messages
- ✅ App navigates to HomeScreen
- ✅ User email displayed in info dialog
- ✅ Check Firebase Console → Authentication tab shows new user

**Firebase Console Check**:
- Go to: Firebase Console → Authentication
- Verify user appears with email and creation date

---

## Test 2: User Login 🔐

**Objective**: Sign in with existing credentials

**Steps**:
1. Close and reopen the app
2. AuthScreen appears (sign out worked)
3. Switch to "Sign In" mode
4. Enter:
   - Email: `testuser@cloudlearn.com`
   - Password: `SecurePass123`
5. Click "Sign In" button

**Verification**:
- ✅ Success message displays
- ✅ Redirects to HomeScreen
- ✅ User email shown in info dialog
- ✅ Session persists (close and reopen app - still logged in)

---

## Test 3: Create Task 📝

**Objective**: Add a task to Firestore and verify real-time display

**Steps**:
1. Navigate to Tasks screen (bottom navigation)
2. In the input field, enter: `Learn Firebase Firestore`
3. Click add button / press enter
4. Verify task appears in list instantly

**Verification**:
- ✅ Task appears in list immediately
- ✅ Checkbox can toggle task completion
- ✅ Delete button works with confirmation
- ✅ Empty state disappears when list has items

**Firebase Console Check**:
- Go to: Firebase Console → Firestore Database → Collections → tasks
- Verify new document with:
  - `title`: "Learn Firebase Firestore"
  - `userId`: Your user ID
  - `completed`: false
  - `createdAt`: Current timestamp

### Multiple Tasks
Add several more tasks:
- `Understand Cloud Architecture`
- `Set up CI/CD Pipeline`
- `Configure Security Rules`

---

## Test 4: Real-time Task Update 🔄

**Objective**: Verify real-time synchronization from Firestore

**Steps**:
1. Create a task in the app
2. Copy the task ID from Firestore console
3. In Firebase Console → Firestore, find the task document
4. Edit the `title` field directly in console
5. Switch back to app

**Verification**:
- ✅ Task title updates immediately in app
- ✅ No manual refresh needed
- ✅ The update reflected across all app instances

---

## Test 5: Task Completion Toggle ✓

**Objective**: Update task completion status

**Steps**:
1. In Tasks screen, click checkbox next to a task
2. Observe visual change (completed state)
3. Click again to uncheck

**Verification**:
- ✅ Checkbox toggles on/off
- ✅ Visual feedback with UI changes
- ✅ In Firestore, `completed` field toggles between true/false
- ✅ `updatedAt` timestamp updates

---

## Test 6: Delete Task 🗑️

**Objective**: Remove task from Firestore

**Steps**:
1. In Tasks screen, click delete icon on any task
2. Confirm deletion in dialog
3. Task disappears from list instantly

**Verification**:
- ✅ Task removes from app list
- ✅ Document deleted from Firestore console
- ✅ Confirmation prevents accidental deletion

---

## Test 7: Create Note 📓

**Objective**: Add a note to Firestore

**Steps**:
1. Navigate to Notes screen
2. Click "+ Add Note" button
3. In dialog, enter:
   - Title: `Cloud Architecture Notes`
   - Content: `Microservices enable scalability and resilience`
4. Click Save

**Verification**:
- ✅ Dialog closes
- ✅ Note appears in notes list instantly
- ✅ Note displays title and preview of content

**Firebase Console Check**:
- Go to: Firestore Database → Collections → notes
- Verify new document contains your note data

---

## Test 8: Edit Note ✏️

**Objective**: Update existing note content

**Steps**:
1. In Notes screen, click edit icon on a note
2. Dialog opens with current content
3. Modify the content
4. Click Save

**Verification**:
- ✅ Dialog closes
- ✅ Updated note displays in list
- ✅ Changes reflected in Firestore console
- ✅ `updatedAt` timestamp is recent

---

## Test 9: Delete Note 🗑️

**Objective**: Remove note from Firestore

**Steps**:
1. Click delete icon on any note
2. Confirm deletion
3. Note disappears from list

**Verification**:
- ✅ Note removes from app
- ✅ Document deleted from Firestore
- ✅ Confirmation dialog prevents accidents

---

## Test 10: Offline Persistence 📴

**Objective**: Verify data queues offline and syncs when online

**Steps**:
1. Create a task online
2. Enable Airplane Mode (or disable network)
3. Attempt to create another task
4. Task appears in list (queued locally)
5. Disable Airplane Mode (restore network)
6. Wait 5-10 seconds
7. Check Firestore console

**Verification**:
- ✅ App allows creating task while offline
- ✅ Task appears in local list
- ✅ Task syncs to Firestore when online
- ✅ Both tasks appear in Firestore console

---

## Test 11: Session Persistence 🔐

**Objective**: Verify user stays logged in after app restart

**Steps**:
1. Close the app completely
2. Terminate from recent apps (force close)
3. Reopen the app
4. App should skip AuthScreen

**Verification**:
- ✅ HomeScreen loads directly
- ✅ User email displayed
- ✅ All data persists
- ✅ Tasks and notes still visible

---

## Test 12: Sign Out 🚪

**Objective**: Properly sign out and return to authentication

**Steps**:
1. In HomeScreen, click logout icon (⊗ or 🚪)
2. Confirm sign out if prompted

**Verification**:
- ✅ Session clears
- ✅ Redirects to AuthScreen
- ✅ AuthScreen is in Sign In mode
- ✅ Cannot access HomeScreen without login

---

## Test 13: Error Handling 🚨

### Invalid Email Format
**Steps**:
1. Try signing up with: `invalidemail`
2. Should show validation error

### Weak Password
**Steps**:
1. Try signing up with password: `123`
2. Should show "Password must be at least 6 characters"

### Email Already Exists
**Steps**:
1. Sign up with: `testuser@cloudlearn.com` (existing)
2. Should show "An account already exists for that email"

### Wrong Password
**Steps**:
1. Try signing in with correct email but wrong password
2. Should show "Wrong password provided"

**All should show**: ✅ Clear error messages in SnackBar with red background

---

## Test 14: Data Isolation 🔒

**Objective**: Verify each user only sees their own data

**Steps**:
1. Create tasks as User 1
2. Sign out
3. Sign in/Sign up as User 2
4. Check Tasks screen

**Verification**:
- ✅ User 2 sees NO tasks from User 1
- ✅ Each user only sees their own data
- ✅ Firestore queries correctly filter by userId

---

## Performance Tests ⚡

### Quick Response
- [ ] Sign in: < 2 seconds
- [ ] Task creation: < 1 second
- [ ] Note creation: < 1 second
- [ ] Real-time update: < 500ms after Firestore change

### Data Integrity
- [ ] No duplicate documents
- [ ] No orphaned data
- [ ] Timestamps are server-generated
- [ ] userId always matches current user

---

## 📊 Verification Matrix

| Feature | Status | Notes |
|---------|--------|-------|
| Sign Up | ✅ | |
| Sign In | ✅ | |
| Sign Out | ✅ | |
| Create Task | ✅ | |
| Read Tasks (Real-time) | ✅ | |
| Update Task | ✅ | |
| Delete Task | ✅ | |
| Create Note | ✅ | |
| Read Notes (Real-time) | ✅ | |
| Update Note | ✅ | |
| Delete Note | ✅ | |
| Offline Support | ✅ | |
| Session Persistence | ✅ | |
| Error Handling | ✅ | |
| Data Isolation | ✅ | |

---

## 🐛 Troubleshooting

### App not connecting to Firebase
- [ ] Check internet connection
- [ ] Verify firebase_options.dart has correct project ID
- [ ] Check Firebase project is active

### Data not syncing
- [ ] Close app and reopen
- [ ] Check Firestore rules allow your user access
- [ ] Verify userId in Firestore matches auth user

### Real-time updates not working
- [ ] Check StreamBuilder is properly connected
- [ ] Verify Firestore collection is receiving data
- [ ] Restart app and try again

### Sign up/Sign in failing
- [ ] Check email format is valid
- [ ] Password must be 6+ characters
- [ ] Check no special characters in email
- [ ] Verify Firebase project allows passwords auth

---

## ✅ Final Checklist

Complete all tests and check off:
- [ ] All 14 tests completed successfully
- [ ] No errors or warnings in console
- [ ] Firebase Console shows all data
- [ ] Real-time sync working instantly
- [ ] Offline persistence working
- [ ] Session persistence working
- [ ] Data isolation verified
- [ ] Error handling working properly

**Status**: Ready for Production ✅

---

**Last Updated**: February 20, 2026
**For Issues**: Check Flutter logs with `flutter logs`
**Firebase Support**: https://firebase.google.com/support
