import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Supported activity event types
enum ActivityType {
  login,
  logout,
  assignmentSubmitted,
  courseViewed,
  profileUpdated,
  taskCreated,
  taskCompleted,
}

extension ActivityTypeLabel on ActivityType {
  String get label {
    switch (this) {
      case ActivityType.login:
        return 'login';
      case ActivityType.logout:
        return 'logout';
      case ActivityType.assignmentSubmitted:
        return 'assignment_submitted';
      case ActivityType.courseViewed:
        return 'course_viewed';
      case ActivityType.profileUpdated:
        return 'profile_updated';
      case ActivityType.taskCreated:
        return 'task_created';
      case ActivityType.taskCompleted:
        return 'task_completed';
    }
  }
}

/// A single activity log entry
class ActivityLogEntry {
  const ActivityLogEntry({
    required this.id,
    required this.userId,
    required this.type,
    required this.description,
    required this.timestamp,
    this.metadata,
  });

  final String id;
  final String userId;
  final String type;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  factory ActivityLogEntry.fromMap(String id, Map<String, dynamic> map) {
    final ts = map['timestamp'];
    return ActivityLogEntry(
      id: id,
      userId: map['userId'] as String? ?? '',
      type: map['type'] as String? ?? '',
      description: map['description'] as String? ?? '',
      timestamp: ts is Timestamp ? ts.toDate() : DateTime.now(),
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// Activity Log Service
///
/// Logs user activity events to Firestore for audit/history purposes.
/// Fire-and-forget — errors are silently swallowed so they never
/// break existing flows.
class ActivityLogService {
  ActivityLogService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('activity_logs');

  /// Log an activity event. Safe to call anywhere — never throws.
  Future<void> log(
    ActivityType type,
    String description, {
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      await _col.add({
        'userId': uid,
        'type': type.label,
        'description': description,
        'metadata': metadata ?? {},
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Intentionally silent — activity logging must never break app flow
    }
  }

  /// Stream of recent activity logs for the current user.
  Stream<List<ActivityLogEntry>> watchRecentActivity({int limit = 30}) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _col
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ActivityLogEntry.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// One-time fetch of recent activity for the current user.
  Future<List<ActivityLogEntry>> getRecentActivity({int limit = 30}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    try {
      final snapshot = await _col
          .where('userId', isEqualTo: uid)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ActivityLogEntry.fromMap(doc.id, doc.data()))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
