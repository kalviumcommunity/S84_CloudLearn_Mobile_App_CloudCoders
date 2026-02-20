import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

/// Firebase Storage Service
/// 
/// Handles file uploads and media management for the app
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload a file to Firebase Storage
  /// 
  /// Returns the download URL of the uploaded file
  Future<String> uploadFile(File file, String path) async {
    try {
      final storageRef = _storage.ref().child(path);
      final uploadTask = await storageRef.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('File upload failed: $e');
    }
  }

  /// Upload an image file
  /// 
  /// Specifically for image uploads with a standardized path
  Future<String> uploadImage(File imageFile, String fileName) async {
    final path = 'uploads/images/$fileName';
    return uploadFile(imageFile, path);
  }

  /// Delete a file from Firebase Storage
  Future<void> deleteFile(String path) async {
    try {
      final storageRef = _storage.ref().child(path);
      await storageRef.delete();
    } catch (e) {
      throw Exception('File deletion failed: $e');
    }
  }

  /// Get download URL for a file
  Future<String> getDownloadUrl(String path) async {
    try {
      final storageRef = _storage.ref().child(path);
      return await storageRef.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to get download URL: $e');
    }
  }
}
