// LeaderboardService — DEPRECATED Firestore 'leaderboard' collection removed.
// Ranking is now driven by the 'users' collection via getCurrentUserStream()
// in FirestoreService, merged with peer data in community_screen.dart.
//
// This file is kept as a stub in case score-based features (assignments,
// streaks) need a dedicated collection in the future.

/// Represents a single leaderboard entry.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.userId,
    required this.name,
    required this.avatarUrl,
    required this.totalPoints,
    required this.progress,
    required this.rank,
  });

  final String userId;
  final String name;
  final String avatarUrl;
  final int totalPoints;
  final int progress; // 0–100
  final int rank;
}
