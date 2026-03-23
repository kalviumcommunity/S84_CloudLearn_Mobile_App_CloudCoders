import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Represents progress for a single course
class CourseProgress {
  const CourseProgress({
    required this.courseId,
    required this.courseTitle,
    required this.completedModules,
    required this.totalModules,
    required this.lastAccessedAt,
  });

  final String courseId;
  final String courseTitle;
  final int completedModules;
  final int totalModules;
  final DateTime lastAccessedAt;

  /// Progress as a value between 0.0 and 1.0
  double get progressFraction =>
      totalModules == 0 ? 0.0 : (completedModules / totalModules).clamp(0.0, 1.0);

  /// Progress as a percentage string e.g. "60%"
  String get progressLabel => '${(progressFraction * 100).round()}%';

  bool get isCompleted => completedModules >= totalModules && totalModules > 0;

  factory CourseProgress.fromMap(Map<String, dynamic> map) {
    final ts = map['lastAccessedAt'];
    return CourseProgress(
      courseId: map['courseId'] as String? ?? '',
      courseTitle: map['courseTitle'] as String? ?? 'Untitled Course',
      completedModules: map['completedModules'] as int? ?? 0,
      totalModules: map['totalModules'] as int? ?? 1,
      lastAccessedAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
    );
  }
}

/// Course Progress Service
///
/// Tracks per-course module completion progress in Firestore.
/// Stored in 'course_progress' collection, keyed by userId_courseId.
/// Fully independent — does not touch any existing service or screen.
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

  /// Record module completion for a course.
  /// Creates the progress document if it doesn't exist yet.
  Future<void> markModuleCompleted({
    required String courseId,
    required String courseTitle,
    required int totalModules,
    required int completedModules,
  }) async {
    final uid = _uid;
    await _col.doc(_docId(uid, courseId)).set({
      'userId': uid,
      'courseId': courseId,
      'courseTitle': courseTitle,
      'completedModules': completedModules,
      'totalModules': totalModules,
      'lastAccessedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Increment completed modules by 1 (convenience method).
  Future<void> incrementProgress({
    required String courseId,
    required String courseTitle,
    required int totalModules,
  }) async {
    final uid = _uid;
    final docId = _docId(uid, courseId);
    final existing = await _col.doc(docId).get();

    final current = existing.exists
        ? (existing.data()?['completedModules'] as int? ?? 0)
        : 0;
    final updated = (current + 1).clamp(0, totalModules);

    await _col.doc(docId).set({
      'userId': uid,
      'courseId': courseId,
      'courseTitle': courseTitle,
      'completedModules': updated,
      'totalModules': totalModules,
      'lastAccessedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
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

    int totalCompleted = 0;
    int totalModules = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      totalCompleted += data['completedModules'] as int? ?? 0;
      totalModules += data['totalModules'] as int? ?? 0;
    }

    if (totalModules == 0) return 0.0;
    return (totalCompleted / totalModules).clamp(0.0, 1.0);
  }
}
