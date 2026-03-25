import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firestore Service for Real-Time Data Management
/// 
/// Provides methods to interact with Cloud Firestore for real-time data sync
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Reference to the tasks collection
  CollectionReference<Map<String, dynamic>> get tasks =>
      _firestore.collection('tasks');

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('User must be signed in to access tasks.');
    }
    return uid;
  }

  // ── User document stream ──────────────────────────────────────────────────

  /// Real-time stream of the current user's document from the users collection.
  /// Emits an empty map if the document doesn't exist yet.
  Stream<Map<String, dynamic>> getCurrentUserStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) => doc.data() ?? {});
  }

  /// Ensures the users/{uid} document exists with default fields.
  /// Call this on first login / sign-up so the stream never returns empty data.
  Future<void> ensureUserDocument() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final ref = _firestore.collection('users').doc(user.uid);
    final doc = await ref.get();
    if (!doc.exists) {
      await ref.set({
        'totalPoints': 0,
        'progress': 0,
        'completedLessons': {},
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Add a new task to Firestore
  /// 
  /// Automatically syncs across all connected devices in real-time
  Future<DocumentReference<Map<String, dynamic>>> addTask(String title) {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      throw Exception('Task title cannot be empty.');
    }

    final uid = _uid;
    return tasks.add({
      'title': trimmedTitle,
      'userId': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'completed': false,
    });
  }

  /// Get all tasks as a real-time stream
  /// 
  /// Stream automatically updates when data changes in Firestore
  /// No manual refresh needed - this is the power of Firebase real-time sync!
  Stream<QuerySnapshot<Map<String, dynamic>>> getTasks() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return const Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
    }

    return tasks
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Update a task
  Future<void> updateTask(String taskId, Map<String, dynamic> data) {
    return tasks.doc(taskId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete a task
  Future<void> deleteTask(String taskId) {
    return tasks.doc(taskId).delete();
  }

  /// Mark task as completed
  Future<void> toggleTaskCompletion(String taskId, bool completed) {
    return tasks.doc(taskId).update({
      'completed': !completed,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get a specific task by ID
  Future<DocumentSnapshot<Map<String, dynamic>>> getTaskById(String taskId) {
    return tasks.doc(taskId).get();
  }

  /// Get completed tasks only
  Stream<QuerySnapshot<Map<String, dynamic>>> getCompletedTasks() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return const Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
    }

    return tasks
        .where('userId', isEqualTo: uid)
        .where('completed', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Get pending tasks only
  Stream<QuerySnapshot<Map<String, dynamic>>> getPendingTasks() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return const Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
    }

    return tasks
        .where('userId', isEqualTo: uid)
        .where('completed', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ── User document stream ──────────────────────────────────────────────────

  /// Real-time stream of the current user's document from the users collection.
  /// Returns empty map silently if rules deny access (e.g. before rules are deployed).
  Stream<Map<String, dynamic>> getCurrentUserStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) => doc.data() ?? {})
        .handleError((_) => <String, dynamic>{}); // swallow permission-denied silently
  }

  /// Ensures the users/{uid} document exists with default fields.
  /// Fully silent — never throws, never blocks login.
  Future<void> ensureUserDocument() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      final ref = _firestore.collection('users').doc(user.uid);
      final doc = await ref.get();
      if (!doc.exists) {
        await ref.set({
          'totalPoints': 0,
          'progress': 0,
          'completedLessons': {},
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {
      // Silently ignore — permission-denied until Firestore rules are deployed
    }
  }
}
