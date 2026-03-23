import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Represents a single leaderboard entry
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.userId,
    required this.name,
    required this.avatarUrl,
    required this.score,
    required this.streak,
    required this.assignmentsCompleted,
    required this.rank,
  });

  final String userId;
  final String name;
  final String avatarUrl;
  final int score;
  final int streak;
  final int assignmentsCompleted;
  final int rank;

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map, int rank) {
    return LeaderboardEntry(
      userId: map['userId'] as String? ?? '',
      name: map['name'] as String? ?? 'Anonymous',
      avatarUrl: map['avatarUrl'] as String? ?? '',
      score: map['score'] as int? ?? 0,
      streak: map['streak'] as int? ?? 0,
      assignmentsCompleted: map['assignmentsCompleted'] as int? ?? 0,
      rank: rank,
    );
  }
}

/// Leaderboard Service
///
/// Tracks and ranks students by score (assignments completed + streak).
/// Stored in the 'leaderboard' Firestore collection.
/// Completely independent — does not affect any existing service.
class LeaderboardService {
  LeaderboardService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('leaderboard');

  /// Update or create the current user's leaderboard entry.
  /// Call this after an assignment is submitted or streak changes.
  Future<void> updateScore({
    required String userId,
    required String name,
    required String avatarUrl,
    required int assignmentsCompleted,
    required int streak,
  }) async {
    // Score formula: each assignment = 10pts, each streak day = 5pts
    final score = (assignmentsCompleted * 10) + (streak * 5);
    await _col.doc(userId).set({
      'userId': userId,
      'name': name.trim().isEmpty ? 'Anonymous' : name.trim(),
      'avatarUrl': avatarUrl,
      'score': score,
      'streak': streak,
      'assignmentsCompleted': assignmentsCompleted,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Stream of top [limit] leaderboard entries, ordered by score descending.
  Stream<List<LeaderboardEntry>> watchTopEntries({int limit = 20}) {
    return _col
        .orderBy('score', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.asMap().entries.map((e) {
        return LeaderboardEntry.fromMap(e.value.data(), e.key + 1);
      }).toList();
    });
  }

  /// Get the current user's rank and entry (one-time fetch).
  Future<LeaderboardEntry?> getCurrentUserEntry() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _col.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;

    final userScore = doc.data()!['score'] as int? ?? 0;
    final above = await _col
        .where('score', isGreaterThan: userScore)
        .count()
        .get();
    final rank = (above.count ?? 0) + 1;

    return LeaderboardEntry.fromMap(doc.data()!, rank);
  }
}
