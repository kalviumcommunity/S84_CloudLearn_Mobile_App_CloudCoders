import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Represents progress for a single course
class CourseProgress {
  const CourseProgress({
    required this.courseId,
    required this.courseTitle,
    required this.watchedVideoIds,
    required this.totalVideos,
    required this.lastAccessedAt,
    this.lessonCompletedAt = const {},
  });

  final String courseId;
  final String courseTitle;
  final List<String> watchedVideoIds;
  final int totalVideos;
  final DateTime lastAccessedAt;

  /// Maps lessonId → DateTime when it was completed
  final Map<String, DateTime> lessonCompletedAt;

  int get watchedCount => watchedVideoIds.length;

  double get progressFraction =>
      totalVideos == 0 ? 0.0 : (watchedCount / totalVideos).clamp(0.0, 1.0);

  String get progressLabel => '${(progressFraction * 100).round()}%';

  bool get isCompleted => watchedCount >= totalVideos && totalVideos > 0;

  factory CourseProgress.fromMap(Map<String, dynamic> map) {
    final ts = map['lastAccessedAt'];
    final rawIds = map['watchedVideoIds'];

    // Parse per-lesson completion timestamps
    final rawTimes = map['lessonCompletedAt'];
    final Map<String, DateTime> completedAt = {};
    if (rawTimes is Map) {
      rawTimes.forEach((key, value) {
        if (value is Timestamp) {
          completedAt[key.toString()] = value.toDate();
        }
      });
    }

    return CourseProgress(
      courseId: map['courseId'] as String? ?? '',
      courseTitle: map['courseTitle'] as String? ?? 'Untitled Course',
      watchedVideoIds: rawIds is List ? List<String>.from(rawIds) : [],
      totalVideos: map['totalVideos'] as int? ?? 0,
      lastAccessedAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
      lessonCompletedAt: completedAt,
    );
  }
}

/// Course Progress Service
///
/// Persists watched video IDs + per-lesson completion timestamps per user per
/// course in Firestore.
/// Document key: userId_courseId in 'course_progress' collection.
class CourseProgressService {
  CourseProgressService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('course_progress');

  String _docId(String userId, String courseId) => '${userId}_$courseId';

  String get _uid {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('User must be signed in.');
    return uid;
  }

  /// Load watched video IDs for a course. Returns empty set if none saved or on error.
  Future<Set<String>> getWatchedVideoIds(String courseId) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return {};

      final doc = await _col
          .doc(_docId(uid, courseId))
          .get()
          .timeout(const Duration(seconds: 8));
      if (!doc.exists || doc.data() == null) return {};

      final raw = doc.data()!['watchedVideoIds'];
      if (raw is List) return Set<String>.from(raw);
      return {};
    } catch (_) {
      return {};
    }
  }

  /// Load full progress including per-lesson timestamps.
  Future<Map<String, DateTime>> getLessonCompletedAt(String courseId) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return {};

      final doc = await _col
          .doc(_docId(uid, courseId))
          .get()
          .timeout(const Duration(seconds: 8));
      if (!doc.exists || doc.data() == null) return {};

      final raw = doc.data()!['lessonCompletedAt'];
      if (raw is! Map) return {};

      final result = <String, DateTime>{};
      raw.forEach((key, value) {
        if (value is Timestamp) result[key.toString()] = value.toDate();
      });
      return result;
    } catch (_) {
      return {};
    }
  }

  /// Save the full set of watched video IDs for a course.
  /// [newlyCompletedId] — if provided, records the completion timestamp for
  /// that lesson (only written once; existing timestamps are preserved via merge).
  Future<void> saveWatchedVideoIds({
    required String courseId,
    required String courseTitle,
    required Set<String> watchedIds,
    required int totalVideos,
    String? newlyCompletedId,
  }) async {
    try {
      final uid = _uid;
      final data = <String, dynamic>{
        'userId': uid,
        'courseId': courseId,
        'courseTitle': courseTitle,
        'watchedVideoIds': watchedIds.toList(),
        'watchedCount': watchedIds.length,
        'totalVideos': totalVideos,
        'progressFraction': totalVideos == 0
            ? 0.0
            : (watchedIds.length / totalVideos).clamp(0.0, 1.0),
        'lastAccessedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Record per-lesson completion timestamp (server time)
      if (newlyCompletedId != null) {
        data['lessonCompletedAt.$newlyCompletedId'] = FieldValue.serverTimestamp();
      }

      await _col
          .doc(_docId(uid, courseId))
          .set(data, SetOptions(merge: true))
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      // Silent fail — progress will sync next time
    }
  }

  /// Stream of all course progress entries for the current user.
  Stream<List<CourseProgress>> watchAllProgress() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _col
        .where('userId', isEqualTo: uid)
        .orderBy('lastAccessedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CourseProgress.fromMap(doc.data()))
            .toList());
  }

  /// Get progress for a specific course (one-time fetch).
  Future<CourseProgress?> getCourseProgress(String courseId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _col.doc(_docId(uid, courseId)).get();
    if (!doc.exists || doc.data() == null) return null;
    return CourseProgress.fromMap(doc.data()!);
  }

  /// Get overall progress across all courses as a fraction (0.0 – 1.0).
  Future<double> getOverallProgress() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return 0.0;

    final snapshot = await _col.where('userId', isEqualTo: uid).get();
    if (snapshot.docs.isEmpty) return 0.0;

    int totalWatched = 0;
    int totalVideos = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final raw = data['watchedVideoIds'];
      totalWatched += raw is List ? raw.length : 0;
      totalVideos += data['totalVideos'] as int? ?? 0;
    }

    if (totalVideos == 0) return 0.0;
    return (totalWatched / totalVideos).clamp(0.0, 1.0);
  }
}
