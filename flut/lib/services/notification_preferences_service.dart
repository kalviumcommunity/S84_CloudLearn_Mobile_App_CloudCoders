import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Notification Preferences Service
/// 
/// Manages user notification settings and preferences stored in Firestore.
/// Allows users to customize which types of notifications they receive.
class NotificationPreferencesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('User must be signed in to access notification preferences.');
    }
    return uid;
  }

  /// Reference to the notification preferences collection
  CollectionReference<Map<String, dynamic>> get notificationPreferences =>
      _firestore.collection('notification_preferences');

  /// Create default notification preferences for a new user
  /// 
  /// Called automatically when a user signs up
  Future<void> createDefaultPreferences(String uid) async {
    try {
      await notificationPreferences.doc(uid).set({
        'userId': uid,
        'emailNotifications': true,
        'assignmentReminders': true,
        'courseUpdates': true,
        'weeklyDigest': true,
        'pushNotifications': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create notification preferences: $e');
    }
  }

  /// Get user's notification preferences as a stream
  /// 
  /// Returns real-time updates whenever preferences change
  Stream<DocumentSnapshot<Map<String, dynamic>>> getPreferencesStream() {
    return notificationPreferences.doc(_uid).snapshots();
  }

  /// Get user's notification preferences (one-time fetch)
  /// 
  /// Useful for checking preferences without setting up a stream
  Future<Map<String, dynamic>> getPreferences() async {
    try {
      final doc = await notificationPreferences.doc(_uid).get();
      if (!doc.exists) {
        // Auto-create if missing
        await createDefaultPreferences(_uid);
        return {
          'emailNotifications': true,
          'assignmentReminders': true,
          'courseUpdates': true,
          'weeklyDigest': true,
          'pushNotifications': true,
        };
      }
      return doc.data() ?? {};
    } catch (e) {
      throw Exception('Failed to fetch notification preferences: $e');
    }
  }

  /// Update email notifications preference
  Future<void> setEmailNotifications(bool enabled) {
    return _updatePreference('emailNotifications', enabled);
  }

  /// Update assignment reminder preference
  Future<void> setAssignmentReminders(bool enabled) {
    return _updatePreference('assignmentReminders', enabled);
  }

  /// Update course updates preference
  Future<void> setCourseUpdates(bool enabled) {
    return _updatePreference('courseUpdates', enabled);
  }

  /// Update weekly digest preference
  Future<void> setWeeklyDigest(bool enabled) {
    return _updatePreference('weeklyDigest', enabled);
  }

  /// Update push notifications preference
  Future<void> setPushNotifications(bool enabled) {
    return _updatePreference('pushNotifications', enabled);
  }

  /// Generic preference update helper
  /// 
  /// Updates a single preference field with server timestamp
  Future<void> _updatePreference(String field, dynamic value) {
    try {
      return notificationPreferences.doc(_uid).update({
        field: value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update preference: $e');
    }
  }

  /// Batch update multiple preferences
  /// 
  /// More efficient than making multiple update calls
  Future<void> updateMultiplePreferences(
      Map<String, dynamic> preferences) async {
    try {
      if (preferences.isEmpty) {
        throw Exception('No preferences to update.');
      }

      preferences['updatedAt'] = FieldValue.serverTimestamp();
      await notificationPreferences.doc(_uid).update(preferences);
    } catch (e) {
      throw Exception('Failed to batch update preferences: $e');
    }
  }

  /// Check if a specific notification type is enabled
  Future<bool> isNotificationTypeEnabled(String notificationType) async {
    try {
      final preferences = await getPreferences();
      return preferences[notificationType] as bool? ?? true;
    } catch (e) {
      throw Exception('Failed to check notification status: $e');
    }
  }

  /// Get all enabled notification types
  /// 
  /// Useful for filtering which notifications should be sent
  Future<List<String>> getEnabledNotificationTypes() async {
    try {
      final preferences = await getPreferences();
      final enabledTypes = <String>[];

      final notificationFields = [
        'emailNotifications',
        'assignmentReminders',
        'courseUpdates',
        'weeklyDigest',
        'pushNotifications',
      ];

      for (final field in notificationFields) {
        if (preferences[field] as bool? ?? true) {
          enabledTypes.add(field);
        }
      }

      return enabledTypes;
    } catch (e) {
      throw Exception('Failed to get enabled notification types: $e');
    }
  }

  /// Reset preferences to defaults
  /// 
  /// Restores all notification preferences to enabled state
  Future<void> resetToDefaults() async {
    try {
      final uid = _uid;
      await notificationPreferences.doc(uid).set({
        'userId': uid,
        'emailNotifications': true,
        'assignmentReminders': true,
        'courseUpdates': true,
        'weeklyDigest': true,
        'pushNotifications': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to reset preferences: $e');
    }
  }
}
