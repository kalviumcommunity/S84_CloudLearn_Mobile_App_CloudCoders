// Example: Firebase Authentication Usage
import 'package:flut/services/auth_service.dart';

void exampleAuthentication() async {
  final authService = AuthService();
  
  // Sign up a new user
  try {
    final user = await authService.signUp(
      'user@example.com',
      'password123',
    );
    print('User created: ${user?.email}');
  } catch (e) {
    print('Sign up error: $e');
  }
  
  // Sign in existing user
  try {
    final user = await authService.signIn(
      'user@example.com',
      'password123',
    );
    print('User signed in: ${user?.email}');
  } catch (e) {
    print('Sign in error: $e');
  }
  
  // Sign out
  await authService.signOut();
  
  // Check auth state
  bool isSignedIn = authService.isSignedIn();
  print('Is signed in: $isSignedIn');
  
  // Listen to auth state changes
  authService.authStateChanges.listen((user) {
    if (user != null) {
      print('User is signed in: ${user.email}');
    } else {
      print('User is signed out');
    }
  });
}

// Example: Firestore Real-Time Data Usage
import 'package:flut/services/firestore_service.dart';
import 'package:flut/services/auth_service.dart';

void exampleFirestore() async {
  final firestoreService = FirestoreService();
  final authService = AuthService();
  final userId = authService.currentUser?.uid ?? '';
  
  // Add a task
  try {
    String taskId = await firestoreService.addTask(
      'Learn Firebase',
      userId,
    );
    print('Task created with ID: $taskId');
  } catch (e) {
    print('Error adding task: $e');
  }
  
  // Get real-time tasks stream
  firestoreService.getTasks(userId).listen((snapshot) {
    print('Tasks updated! Count: ${snapshot.docs.length}');
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      print('Task: ${data['title']}, Completed: ${data['completed']}');
    }
  });
  
  // Update task status
  await firestoreService.updateTaskStatus('taskId123', true);
  
  // Delete task
  await firestoreService.deleteTask('taskId123');
  
  // Add a note
  String noteId = await firestoreService.addNote(
    'Firebase Notes',
    'Cloud Firestore is amazing!',
    userId,
  );
  
  // Get real-time notes stream
  firestoreService.getNotes(userId).listen((snapshot) {
    print('Notes updated! Count: ${snapshot.docs.length}');
  });
  
  // Batch add multiple tasks
  await firestoreService.batchAddTasks(
    ['Task 1', 'Task 2', 'Task 3'],
    userId,
  );
}

// Example: Firebase Storage Usage
import 'dart:io';
import 'package:flut/services/storage_service.dart';

void exampleStorage() async {
  final storageService = StorageService();
  final userId = 'user123';
  
  // Upload a file with progress tracking
  File imageFile = File('/path/to/image.jpg');
  
  try {
    String downloadUrl = await storageService.uploadFile(
      file: imageFile,
      path: 'users/$userId/profile.jpg',
      onProgress: (progress) {
        print('Upload progress: ${(progress * 100).toStringAsFixed(0)}%');
      },
    );
    print('File uploaded! URL: $downloadUrl');
  } catch (e) {
    print('Upload error: $e');
  }
  
  // Upload profile picture (convenience method)
  String profileUrl = await storageService.uploadProfilePicture(
    imageFile,
    userId,
  );
  
  // Get download URL for existing file
  String url = await storageService.getDownloadUrl(
    'users/$userId/profile.jpg',
  );
  
  // Download file
  List<int> fileData = await storageService.downloadFile(
    'users/$userId/profile.jpg',
  );
  
  // Delete file
  await storageService.deleteFile('users/$userId/profile.jpg');
  
  // List files in directory
  List<String> files = await storageService.listFiles('users/$userId');
  print('Files in directory: $files');
  
  // Get file metadata
  var metadata = await storageService.getFileMetadata(
    'users/$userId/profile.jpg',
  );
  print('File size: ${metadata.size} bytes');
  print('Content type: ${metadata.contentType}');
}

// Example: Using StreamBuilder in UI
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flut/services/firestore_service.dart';
import 'package:flut/services/auth_service.dart';

class ExampleStreamBuilderWidget extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final userId = _authService.currentUser?.uid ?? '';
    
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getTasks(userId),
      builder: (context, snapshot) {
        // Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        // Handle error state
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        // Handle empty state
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No tasks yet!'));
        }
        
        // Display data
        final tasks = snapshot.data!.docs;
        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index].data() as Map<String, dynamic>;
            return ListTile(
              title: Text(task['title']),
              trailing: Checkbox(
                value: task['completed'],
                onChanged: (value) {
                  _firestoreService.updateTaskStatus(
                    tasks[index].id,
                    value ?? false,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

/*
 * KEY CONCEPTS EXPLAINED:
 * 
 * 1. REAL-TIME SYNCHRONIZATION:
 *    - Use .snapshots() instead of .get() for real-time data
 *    - StreamBuilder automatically rebuilds UI when data changes
 *    - No manual refresh needed!
 * 
 * 2. AUTHENTICATION STATE:
 *    - authStateChanges provides a stream of user login/logout events
 *    - Use StreamBuilder in main.dart to automatically navigate between
 *      auth screen and home screen based on login state
 * 
 * 3. ERROR HANDLING:
 *    - Always wrap Firebase operations in try-catch blocks
 *    - Firebase throws specific exceptions (FirebaseAuthException, etc.)
 *    - Display user-friendly error messages
 * 
 * 4. OFFLINE SUPPORT:
 *    - Firestore automatically caches data locally
 *    - Works offline by default
 *    - Syncs changes when connection is restored
 * 
 * 5. DATA MODELING:
 *    - Use subcollections for hierarchical data
 *    - Include userId field for security rules
 *    - Use Timestamp for dates (FieldValue.serverTimestamp())
 * 
 * 6. PERFORMANCE:
 *    - Use .where() to filter data on server side
 *    - Create indexes for complex queries
 *    - Paginate large datasets with .limit()
 * 
 * 7. SECURITY:
 *    - Never store sensitive data in Firestore without encryption
 *    - Use security rules to protect user data
 *    - Validate all inputs on client side
 * 
 * 8. BEST PRACTICES:
 *    - Dispose StreamSubscriptions to prevent memory leaks
 *    - Use const constructors where possible
 *    - Handle loading and error states in UI
 *    - Show user feedback for all operations (SnackBars, etc.)
 */

// Example: Complete CRUD Operations
class TaskRepository {
  final FirestoreService _firestore = FirestoreService();
  final AuthService _auth = AuthService();
  
  String get userId => _auth.currentUser?.uid ?? '';
  
  // CREATE
  Future<void> createTask(String title) async {
    await _firestore.addTask(title, userId);
  }
  
  // READ (Real-time stream)
  Stream<List<Map<String, dynamic>>> watchTasks() {
    return _firestore.getTasks(userId).map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;  // Add document ID to data
        return data;
      }).toList();
    });
  }
  
  // UPDATE
  Future<void> toggleTaskCompletion(String taskId, bool currentStatus) async {
    await _firestore.updateTaskStatus(taskId, !currentStatus);
  }
  
  // DELETE
  Future<void> removeTask(String taskId) async {
    await _firestore.deleteTask(taskId);
  }
  
  // BATCH OPERATIONS
  Future<void> createMultipleTasks(List<String> titles) async {
    await _firestore.batchAddTasks(titles, userId);
  }
}

/*
 * TESTING REAL-TIME SYNC:
 * 
 * 1. Open app on two devices/emulators
 * 2. Sign in with same account on both
 * 3. On Device 1: Add a task
 * 4. On Device 2: Task appears instantly (within milliseconds!)
 * 5. On Device 2: Mark task as complete
 * 6. On Device 1: Checkbox updates automatically
 * 7. On either device: Delete task
 * 8. On other device: Task disappears instantly
 * 
 * This is the magic of Firebase real-time sync! ✨
 */
