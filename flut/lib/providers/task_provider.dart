import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class TaskProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  // Tasks stream directly from Firestore
  Stream<QuerySnapshot> get tasksStream => _firestoreService.getTasks();

  Future<void> addTask(String title) async {
    await _firestoreService.addTask(title);
    // No need to notifyListeners because StreamBuilder handles updates
  }

  Future<void> toggleTaskCompletion(String taskId, bool currentStatus) async {
    await _firestoreService.toggleTaskCompletion(taskId, currentStatus);
  }

  Future<void> deleteTask(String taskId) async {
    await _firestoreService.deleteTask(taskId);
  }
}
