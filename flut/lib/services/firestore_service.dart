import 'package:cloud_firestore/cloud_firestore.dart';

/// Service class for handling Cloud Firestore operations
/// Demonstrates real-time data synchronization with Firestore
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get tasksCollection => _db.collection('tasks');
  CollectionReference get notesCollection => _db.collection('notes');

  /// Add a new task to Firestore
  /// Returns the document ID of the created task
  Future<String> addTask(String title, String userId) async {
    try {
      DocumentReference docRef = await tasksCollection.add({
        'title': title,
        'userId': userId,
        'completed': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add task: $e');
    }
  }

  /// Get real-time stream of tasks for a specific user
  /// This demonstrates Firebase's real-time synchronization capability
  /// Any changes to tasks are immediately reflected in the UI
  Stream<QuerySnapshot> getTasks(String userId) {
    return tasksCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Update a task's completion status
  Future<void> updateTaskStatus(String taskId, bool completed) async {
    try {
      await tasksCollection.doc(taskId).update({
        'completed': completed,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  /// Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      await tasksCollection.doc(taskId).delete();
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  /// Add a new note to Firestore
  Future<String> addNote(String title, String content, String userId) async {
    try {
      DocumentReference docRef = await notesCollection.add({
        'title': title,
        'content': content,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add note: $e');
    }
  }

  /// Get real-time stream of notes for a specific user
  Stream<QuerySnapshot> getNotes(String userId) {
    return notesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Update a note
  Future<void> updateNote(String noteId, String title, String content) async {
    try {
      await notesCollection.doc(noteId).update({
        'title': title,
        'content': content,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }

  /// Delete a note
  Future<void> deleteNote(String noteId) async {
    try {
      await notesCollection.doc(noteId).delete();
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }

  /// Get a single document by ID
  Future<DocumentSnapshot> getDocument(String collection, String docId) async {
    try {
      return await _db.collection(collection).doc(docId).get();
    } catch (e) {
      throw Exception('Failed to get document: $e');
    }
  }

  /// Batch write example - useful for multiple operations
  Future<void> batchAddTasks(List<String> taskTitles, String userId) async {
    try {
      WriteBatch batch = _db.batch();
      
      for (String title in taskTitles) {
        DocumentReference docRef = tasksCollection.doc();
        batch.set(docRef, {
          'title': title,
          'userId': userId,
          'completed': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch add tasks: $e');
    }
  }
}
