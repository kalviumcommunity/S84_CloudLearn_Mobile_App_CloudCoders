import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ── In-memory progress cache (singleton) ─────────────────────────────────────
// All screens read from this cache so progress is instantly consistent across
// the whole app without waiting for Firestore round-trips.
class _ProgressCache {
  _ProgressCache._();
  static final instance = _ProgressCache._();

  // courseId → set of watched lesson IDs
  final Map<String, Set<String>> _watchedIds = {};
  // courseId → lessonId → completedAt
  final Map<String, Map<String, DateTime>> _completedAt = {};

  bool _loaded = false;

  Set<String> getWatched(String courseId) =>
      Set.unmodifiable(_watchedIds[courseId] ?? {});

  Map<String, DateTime> getCompletedAt(String courseId) =>
      Map.unmodifiable(_completedAt[courseId] ?? {});

  void markWatched(String courseId, String lessonId) {
    _watchedIds.putIfAbsent(courseId, () => {}).add(lessonId);
    _completedAt.putIfAbsent(courseId, () => {})[lessonId] = DateTime.now();
  }

  void markUnwatched(String courseId, String lessonId) {
    _watchedIds[courseId]?.remove(lessonId);
    _completedAt[courseId]?.remove(lessonId);
  }

  void setFromFirestore(
    String courseId,
    List<String> ids,
    Map<String, DateTime> times,
  ) {
    _watchedIds[courseId] = Set.from(ids);
    _completedAt[courseId] = Map.from(times);
  }

  bool get isLoaded => _loaded;
  void markLoaded() => _loaded = true;
  void invalidate() => _loaded = false;
}

// ── CourseProgress model ──────────────────────────────────────────────────────
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
      rawTimes.forEach((key, value) {
        if (value is Timestamp) completedAt[key.toString()] = value.toDate();
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

// ── CourseProgressService ─────────────────────────────────────────────────────
class CourseProgressService {
  CourseProgressService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final _cache = _ProgressCache.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('course_progress');

  String _docId(String userId, String courseId) => '${userId}_$courseId';

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // ── Warm up cache from Firestore for all courses ──────────────────────────
  // Call once at app start or when user signs in. After that, all reads are
  // instant from the in-memory cache.
  Future<void> warmUpCache(List<String> courseIds) async {
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
          rawTimes.forEach((key, value) {
            if (value is Timestamp) times[key.toString()] = value.toDate();
          });
        }

        _cache.setFromFirestore(courseId, ids, times);
      } catch (_) {
        // keep going — cache stays empty for this course
      }
    }
    _cache.markLoaded();
  }

  // ── Get watched IDs (cache-first) ─────────────────────────────────────────
  Future<Set<String>> getWatchedVideoIds(String courseId) async {
    if (_cache.isLoaded) return _cache.getWatched(courseId);

    // fallback: fetch directly if cache not warmed
    try {
      final uid = _uid;
      if (uid == null) return {};
      final doc = await _col
          .doc(_docId(uid, courseId))
          .get()
          .timeout(const Duration(seconds: 8));
      if (!doc.exists || doc.data() == null) return {};
      final raw = doc.data()!['watchedVideoIds'];
      final ids = raw is List ? Set<String>.from(raw) : <String>{};
      _cache.setFromFirestore(courseId, ids.toList(), {});
      return ids;
    } catch (_) {
      return {};
    }
  }

  // ── Get per-lesson completion timestamps (cache-first) ────────────────────
  Future<Map<String, DateTime>> getLessonCompletedAt(String courseId) async {
    return _cache.getCompletedAt(courseId);
  }

  // ── Toggle a lesson: update cache immediately, persist async ─────────────
  void toggleLesson({
    required String courseId,
    required String courseTitle,
    required String lessonId,
    required int totalVideos,
  }) {
    final wasWatched = _cache.getWatched(courseId).contains(lessonId);
    if (wasWatched) {
      _cache.markUnwatched(courseId, lessonId);
    } else {
      _cache.markWatched(courseId, lessonId);
    }
    // Persist to Firestore in background — don't await
    _persistProgress(
      courseId: courseId,
      courseTitle: courseTitle,
      totalVideos: totalVideos,
      newlyCompletedId: wasWatched ? null : lessonId, // only stamp time on completion
    );
  }

  // ── Save watched IDs (legacy API kept for compatibility) ──────────────────
  Future<void> saveWatchedVideoIds({
    required String courseId,
    required String courseTitle,
    required Set<String> watchedIds,
    required int totalVideos,
    String? newlyCompletedId,
  }) async {
    // Update cache first
    _cache.setFromFirestore(
      courseId,
      watchedIds.toList(),
      _cache.getCompletedAt(courseId),
    );
    if (newlyCompletedId != null) {
      _cache.markWatched(courseId, newlyCompletedId);
    }
    await _persistProgress(
      courseId: courseId,
      courseTitle: courseTitle,
      totalVideos: totalVideos,
      newlyCompletedId: newlyCompletedId,
    );
  }

  Future<void> _persistProgress({
    required String courseId,
    required String courseTitle,
    required int totalVideos,
    String? newlyCompletedId,
  }) async {
    try {
      final uid = _uid;
      if (uid == null) return;

      final watchedIds = _cache.getWatched(courseId);
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

      if (newlyCompletedId != null) {
        data['lessonCompletedAt.$newlyCompletedId'] =
            FieldValue.serverTimestamp();
      }

      await _col
          .doc(_docId(uid, courseId))
          .set(data, SetOptions(merge: true))
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      // silent — cache is still correct, will retry next save
    }
  }

  // ── Sync helpers used by UI ───────────────────────────────────────────────
  /// Returns watched count directly from cache (no async needed).
  int getCachedWatchedCount(String courseId) =>
      _cache.getWatched(courseId).length;

  /// Force cache reload on next warmUp call.
  void invalidateCache() => _cache.invalidate();

  // ── Stream all progress (for analytics screens) ───────────────────────────
  Stream<List<CourseProgress>> watchAllProgress() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _col
        .where('userId', isEqualTo: uid)
        .orderBy('lastAccessedAt', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => CourseProgress.fromMap(d.data())).toList());
  }

  Future<CourseProgress?> getCourseProgress(String courseId) async {
    final uid = _uid;
    if (uid == null) return null;
    final doc = await _col.doc(_docId(uid, courseId)).get();
    if (!doc.exists || doc.data() == null) return null;
    return CourseProgress.fromMap(doc.data()!);
  }

  Future<double> getOverallProgress() async {
    final uid = _uid;
    if (uid == null) return 0.0;
    final snapshot = await _col.where('userId', isEqualTo: uid).get();
    if (snapshot.docs.isEmpty) return 0.0;
    int totalWatched = 0, totalVideos = 0;
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
