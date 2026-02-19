import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// Service class for handling Firebase Storage operations
/// Manages file uploads, downloads, and deletion
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload a file to Firebase Storage
  /// Returns the download URL of the uploaded file
  /// 
  /// Example usage:
  /// ```dart
  /// File image = File('path/to/image.jpg');
  /// String url = await storageService.uploadFile(
  ///   file: image,
  ///   path: 'users/user123/profile.jpg'
  /// );
  /// ```
  Future<String> uploadFile({
    required File file,
    required String path,
    Function(double)? onProgress,
  }) async {
    try {
      // Create a reference to the file location
      Reference ref = _storage.ref().child(path);
      
      // Upload the file
      UploadTask uploadTask = ref.putFile(file);
      
      // Listen to upload progress (optional)
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }
      
      // Wait for upload to complete
      TaskSnapshot snapshot = await uploadTask;
      
      // Get the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  /// Upload a file with metadata (e.g., content type, custom metadata)
  Future<String> uploadFileWithMetadata({
    required File file,
    required String path,
    String? contentType,
    Map<String, String>? customMetadata,
  }) async {
    try {
      Reference ref = _storage.ref().child(path);
      
      // Set metadata
      SettableMetadata metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: customMetadata,
      );
      
      // Upload with metadata
      UploadTask uploadTask = ref.putFile(file, metadata);
      TaskSnapshot snapshot = await uploadTask;
      
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload file with metadata: $e');
    }
  }

  /// Download a file from Firebase Storage
  /// Returns the file as bytes
  Future<List<int>> downloadFile(String path) async {
    try {
      Reference ref = _storage.ref().child(path);
      final List<int> data = await ref.getData() as List<int>;
      return data;
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }

  /// Get download URL for a file
  Future<String> getDownloadUrl(String path) async {
    try {
      Reference ref = _storage.ref().child(path);
      String url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      throw Exception('Failed to get download URL: $e');
    }
  }

  /// Delete a file from Firebase Storage
  Future<void> deleteFile(String path) async {
    try {
      Reference ref = _storage.ref().child(path);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  /// List all files in a directory
  Future<List<String>> listFiles(String path) async {
    try {
      Reference ref = _storage.ref().child(path);
      ListResult result = await ref.listAll();
      
      List<String> fileNames = [];
      for (Reference item in result.items) {
        fileNames.add(item.name);
      }
      
      return fileNames;
    } catch (e) {
      throw Exception('Failed to list files: $e');
    }
  }

  /// Upload profile picture
  /// Convenience method for uploading user profile pictures
  Future<String> uploadProfilePicture(File imageFile, String userId) async {
    String path = 'users/$userId/profile.jpg';
    return await uploadFileWithMetadata(
      file: imageFile,
      path: path,
      contentType: 'image/jpeg',
      customMetadata: {'userId': userId, 'type': 'profile'},
    );
  }

  /// Upload course material
  Future<String> uploadCourseMaterial(
    File file,
    String userId,
    String courseId,
    String fileName,
  ) async {
    String path = 'courses/$courseId/materials/$userId/$fileName';
    return await uploadFile(file: file, path: path);
  }

  /// Get file metadata
  Future<FullMetadata> getFileMetadata(String path) async {
    try {
      Reference ref = _storage.ref().child(path);
      FullMetadata metadata = await ref.getMetadata();
      return metadata;
    } catch (e) {
      throw Exception('Failed to get file metadata: $e');
    }
  }
}
