import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Singleton in-memory cache — single source of truth for all screens.
// Firestore is only used for initial load and background persistence.
// ─────────────────────────────────────────────────────────────────────────────
class ProgressCache {
  ProgressCache._();
  static final ProgressCache instance = ProgressCache._();

  final Map<String, Set<String>> _watched = {};       // courseId → lessonIds
  final Map<String, Map<String, DateTime>> _times = {}; // courseId → lessonId → completedAt
  bool _loaded = false;

  bool get isLoaded => _loaded;

  Set<String> watched(String courseId) =>
      Set.unmodifiable(_watched[courseId] ?? const {});

  Map<String, DateTime> completedAt(String courseId) =>
      Map.unmodifiable(_times[courseId] ?? const {});

  int watchedCount(String courseId) => (_watched[courseId] ?? {}).length;

  void _ensureCourse(String courseId) {
    _watched.putIfAbsent(courseId, () => {});
    _times.putIfAbsent(courseId, () => {});
  }

  void setFromFirestore(String courseId, List<String> ids, Map<String, DateTime> times) {
    _watched[courseId] = Set.from(ids);
    _times[courseId] = Map.from(times);
  }

  /// Mark a lesson complete — returns true if it was newly completed.
  bool complete(String courseId, String lessonId) {
    _ensureCourse(courseId);
    if (_watched[courseId]!.contains(lessonId)) return false;
    _watched[courseId]!.add(lessonId);
    _times[courseId]![lessonId] = DateTime.now();
    return true;
  }

  /// Unmark a lesson — returns true if it was previously completed.
  bool uncomplete(String courseId, String lessonId) {
    _ensureCourse(courseId);
    final removed = _watched[courseId]!.remove(lessonId);
    _times[courseId]!.remove(lessonId);
    return removed;
  }

  void markLoaded() => _loaded = true;
  void invalidate() => _loaded = false;

  void clear() {
    _watched.clear();
    _times.clear();
    _loaded = false;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CourseProgress model
// ─────────────────────────────────────────────────────────────────────────────
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
  final Map<String, DateTime> lessonCompletedAt;

  int get watchedCount => watchedVideoIds.length;
  double get progressFraction =>
      totalVideos == 0 ? 0.0 : (watchedCount / totalVideos).clamp(0.0, 1.0);
  String get progressLabel => '${(progressFraction * 100).round()}%';
  bool get isCompleted => watchedCount >= totalVideos && totalVideos > 0;

  factory CourseProgress.fromMap(Map<String, dynamic> map) {
    final ts = map['lastAccessedAt'];
    final rawIds = map['watchedVideoIds'];
    final rawTimes = map['lessonCompletedAt'];
    final Map<String, DateTime> completedAt = {};
    if (rawTimes is Map) {
      rawTimes.forEach((k, v) {
        if (v is Timestamp) completedAt[k.toString()] = v.toDate();
      });
    }
    return CourseProgress(
      courseId: map['courseId'] as String? ?? '',
      courseTitle: map['courseTitle'] as String? ?? '',
      watchedVideoIds: rawIds is List ? List<String>.from(rawIds) : [],
      totalVideos: map['totalVideos'] as int? ?? 0,
      lastAccessedAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
      lessonCompletedAt: completedAt,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CourseProgressService
// ─────────────────────────────────────────────────────────────────────────────
class CourseProgressService {
  CourseProgressService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  final _cache = ProgressCache.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('course_progress');

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  String _docId(String uid, String courseId) => '${uid}_$courseId';

  // ── Load all courses from Firestore into cache (call once on login / app start)
  Future<void> warmUp(List<String> courseIds) async {
    final uid = _uid;
    if (uid == null) return;
    for (final courseId in courseIds) {
      try {
        final doc = await _col
            .doc(_docId(uid, courseId))
            .get()
            .timeout(const Duration(seconds: 8));
        if (!doc.exists || doc.data() == null) continue;
        final data = doc.data()!;
        final rawIds = data['watchedVideoIds'];
        final ids = rawIds is List ? List<String>.from(rawIds) : <String>[];
        final rawTimes = data['lessonCompletedAt'];
        final times = <String, DateTime>{};
        if (rawTimes is Map) {
          rawTimes.forEach((k, v) {
            if (v is Timestamp) times[k.toString()] = v.toDate();
          });
        }
        _cache.setFromFirestore(courseId, ids, times);
      } catch (_) {}
    }
    _cache.markLoaded();
  }

  // ── Sync a single course from Firestore (used when opening a course detail)
  Future<void> syncCourse(String courseId) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      final doc = await _col
          .doc(_docId(uid, courseId))
          .get()
          .timeout(const Duration(seconds: 8));
      if (!doc.exists || doc.data() == null) return;
      final data = doc.data()!;
      final rawIds = data['watchedVideoIds'];
      final ids = rawIds is List ? List<String>.from(rawIds) : <String>[];
      final rawTimes = data['lessonCompletedAt'];
      final times = <String, DateTime>{};
      if (rawTimes is Map) {
        rawTimes.forEach((k, v) {
          if (v is Timestamp) times[k.toString()] = v.toDate();
        });
      }
      _cache.setFromFirestore(courseId, ids, times);
    } catch (_) {}
  }

  // ── Read from cache (synchronous — always up to date)
  Set<String> getWatchedSync(String courseId) => _cache.watched(courseId);
  Map<String, DateTime> getCompletedAtSync(String courseId) => _cache.completedAt(courseId);
  int getWatchedCountSync(String courseId) => _cache.watchedCount(courseId);

  // ── Toggle a lesson complete/incomplete
  // Updates cache immediately (UI reflects instantly), persists to Firestore async.
  void toggleLesson({
    required String courseId,
    required String courseTitle,
    required String lessonId,
    required int totalVideos,
  }) {
    final wasComplete = _cache.watched(courseId).contains(lessonId);
    if (wasComplete) {
      _cache.uncomplete(courseId, lessonId);
    } else {
      _cache.complete(courseId, lessonId);
    }
    // Fire-and-forget persist
    _persist(
      courseId: courseId,
      courseTitle: courseTitle,
      totalVideos: totalVideos,
      newlyCompletedId: wasComplete ? null : lessonId,
    );
  }

  Future<void> _persist({
    required String courseId,
    required String courseTitle,
    required int totalVideos,
    String? newlyCompletedId,
  }) async {
    try {
      final uid = _uid;
      if (uid == null) return;
      final watched = _cache.watched(courseId);
      final data = <String, dynamic>{
        'userId': uid,
        'courseId': courseId,
        'courseTitle': courseTitle,
        'watchedVideoIds': watched.toList(),
        'watchedCount': watched.length,
        'totalVideos': totalVideos,
        'progressFraction': totalVideos == 0
            ? 0.0
            : (watched.length / totalVideos).clamp(0.0, 1.0),
        'lastAccessedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (newlyCompletedId != null) {
        data['lessonCompletedAt.$newlyCompletedId'] = FieldValue.serverTimestamp();
      }
      await _col
          .doc(_docId(uid, courseId))
          .set(data, SetOptions(merge: true))
          .timeout(const Duration(seconds: 10));
    } catch (_) {}
  }

  // ── Overall progress across all courses (0.0–1.0) from cache
  double overallProgressSync(List<String> courseIds, Map<String, int> totalLessonsMap) {
    int totalWatched = 0, totalLessons = 0;
    for (final id in courseIds) {
      totalWatched += _cache.watchedCount(id);
      totalLessons += totalLessonsMap[id] ?? 0;
    }
    if (totalLessons == 0) return 0.0;
    return (totalWatched / totalLessons).clamp(0.0, 1.0);
  }

  // ── Firestore stream (for analytics — real-time)
  Stream<List<CourseProgress>> watchAllProgress() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _col
        .where('userId', isEqualTo: uid)
        .orderBy('lastAccessedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => CourseProgress.fromMap(d.data())).toList());
  }

  void invalidateCache() => _cache.invalidate();
  void clearCache() => _cache.clear();
}
