import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore Service for Real-Time Data Management
/// 
/// Provides methods to interact with Cloud Firestore for real-time data sync
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Reference to the tasks collection
  CollectionReference get tasks => _firestore.collection('tasks');

  /// Add a new task to Firestore
  /// 
  /// Automatically syncs across all connected devices in real-time
  Future<DocumentReference> addTask(String title) {
    return tasks.add({
      'title': title,
      'createdAt': Timestamp.now(),
      'completed': false,
    });
  }

  /// Get all tasks as a real-time stream
  /// 
  /// Stream automatically updates when data changes in Firestore
  /// No manual refresh needed - this is the power of Firebase real-time sync!
  Stream<QuerySnapshot> getTasks() {
    return tasks.orderBy('createdAt', descending: true).snapshots();
  }

  /// Update a task
  Future<void> updateTask(String taskId, Map<String, dynamic> data) {
    return tasks.doc(taskId).update(data);
  }

  /// Delete a task
  Future<void> deleteTask(String taskId) {
    return tasks.doc(taskId).delete();
  }

  /// Mark task as completed
  Future<void> toggleTaskCompletion(String taskId, bool completed) {
    return tasks.doc(taskId).update({'completed': !completed});
  }

  /// Get a specific task by ID
  Future<DocumentSnapshot> getTaskById(String taskId) {
    return tasks.doc(taskId).get();
  }

  /// Get completed tasks only
  Stream<QuerySnapshot> getCompletedTasks() {
    return tasks
        .where('completed', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Get pending tasks only
  Stream<QuerySnapshot> getPendingTasks() {
    return tasks
        .where('completed', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
