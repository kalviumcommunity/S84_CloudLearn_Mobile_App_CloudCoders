import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/firestore_service.dart';
import '../services/profile_service.dart';

const _kPurple = Color(0xFF6C5CE7);
const _kDeep = Color(0xFF2D1A4D);
const _kBg = Color(0xFFF3F0FF);
const _kCardShadow = [
  BoxShadow(color: Color(0x0F000000), blurRadius: 14, offset: Offset(0, 6)),
];

// ── Student model ─────────────────────────────────────────────────────────────
class _Student {
  const _Student({
    required this.name,
    required this.course,
    required this.assignmentsDone,
    required this.courseProgress,
    required this.totalPoints,
    required this.avatarColor,
    this.isMe = false,
  });
  final String name;
  final String course;
  final int assignmentsDone;
  final int courseProgress; // 0–100
  final int totalPoints;
  final Color avatarColor;
  final bool isMe;
}

// ── Static peer data ──────────────────────────────────────────────────────────
const _fakePeers = <_Student>[
  _Student(name: 'Ayesha Khan',   course: 'Cloud Computing',       assignmentsDone: 9, courseProgress: 92, totalPoints: 190, avatarColor: Color(0xFF7C6CF6)),
  _Student(name: 'Bilal Ahmed',   course: 'AWS Fundamentals',      assignmentsDone: 8, courseProgress: 85, totalPoints: 165, avatarColor: Color(0xFF00C9A7)),
  _Student(name: 'Sara Malik',    course: 'Azure for Beginners',   assignmentsDone: 7, courseProgress: 78, totalPoints: 148, avatarColor: Color(0xFFE8637A)),
  _Student(name: 'Usman Tariq',   course: 'Kubernetes Essentials', assignmentsDone: 6, courseProgress: 65, totalPoints: 125, avatarColor: Color(0xFFFF8A65)),
  _Student(name: 'Hira Baig',     course: 'Cloud Computing',       assignmentsDone: 6, courseProgress: 60, totalPoints: 118, avatarColor: Color(0xFF4C9AFF)),
  _Student(name: 'Zain Raza',     course: 'AWS Fundamentals',      assignmentsDone: 5, courseProgress: 55, totalPoints: 100, avatarColor: Color(0xFFE8A020)),
  _Student(name: 'Nadia Hussain', course: 'Azure for Beginners',   assignmentsDone: 4, courseProgress: 48, totalPoints: 85,  avatarColor: Color(0xFF9B59B6)),
  _Student(name: 'Hamza Sheikh',  course: 'Kubernetes Essentials', assignmentsDone: 3, courseProgress: 35, totalPoints: 65,  avatarColor: Color(0xFF2ECC71)),
  _Student(name: 'Fatima Zahra',  course: 'Cloud Computing',       assignmentsDone: 3, courseProgress: 30, totalPoints: 55,  avatarColor: Color(0xFFE74C3C)),
  _Student(name: 'Ali Hassan',    course: 'AWS Fundamentals',      assignmentsDone: 2, courseProgress: 20, totalPoints: 35,  avatarColor: Color(0xFF1ABC9C)),
];

// ── Merge real user into leaderboard ─────────────────────────────────────────
List<_Student> _buildLeaderboard({
  required Map<String, dynamic> userData,
  required StudentProfile? profile,
  required int assignmentsDone,
}) {
  final user = FirebaseAuth.instance.currentUser;
  final name = (profile?.name.trim().isNotEmpty == true)
      ? profile!.name
      : (user?.displayName?.trim().isNotEmpty == true)
          ? user!.displayName!
          : (user?.email?.split('@').first ?? 'You');

  final int points   = (userData['totalPoints'] as num?)?.toInt() ?? 0;
  final int progress = (userData['progress']    as num?)?.toInt() ?? 0;

  final me = _Student(
    name: name,
    course: profile?.course ?? 'Cloud Learning',
    assignmentsDone: assignmentsDone,
    courseProgress: progress,
    totalPoints: points,
    avatarColor: _kPurple,
    isMe: true,
  );

  return [..._fakePeers, me]
    ..sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
}

// ── Screen ────────────────────────────────────────────────────────────────────
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});
  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _firestoreService = FirestoreService();
  final _profileService   = ProfileService();

  StudentProfile? _profile;
  int _assignmentsDone = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserExtras();
  }

  // Load profile + assignment count once (these don't change mid-session)
  Future<void> _loadUserExtras() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final profile = await _profileService.getProfile(uid);
    final count   = await _profileService.getAssignmentsCompletedCount(uid);
    if (mounted) setState(() { _profile = profile; _assignmentsDone = count; });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        title: Text('Community',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: _kDeep)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kDeep),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13),
          labelColor: _kPurple,
          unselectedLabelColor: _kDeep.withValues(alpha: 0.45),
          indicatorColor: _kPurple,
          indicatorWeight: 3,
          tabs: const [Tab(text: 'Leaderboard'), Tab(text: 'All Students')],
        ),
      ),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: _firestoreService.getCurrentUserStream(),
        builder: (context, snapshot) {
          // Always render — use empty map as fallback until Firestore responds
          final ranked = _buildLeaderboard(
            userData: snapshot.data ?? {},
            profile: _profile,
            assignmentsDone: _assignmentsDone,
          );
          final myRank = ranked.indexWhere((s) => s.isMe) + 1;

          return TabBarView(
            controller: _tabController,
            children: [
              _LeaderboardTab(ranked: ranked, myRank: myRank),
              _AllStudentsTab(students: ranked),
            ],
          );
        },
      ),
    );
  }
}

// ── Leaderboard Tab ───────────────────────────────────────────────────────────
class _LeaderboardTab extends StatefulWidget {
  const _LeaderboardTab({required this.ranked, required this.myRank});
  final List<_Student> ranked;
  final int myRank;
  @override
  State<_LeaderboardTab> createState() => _LeaderboardTabState();
}

class _LeaderboardTabState extends State<_LeaderboardTab> {
  final _scrollController = ScrollController();
  static const double _rowHeight    = 74.0;
  static const double _headerHeight = 310.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToUser());
  }

  @override
  void didUpdateWidget(_LeaderboardTab old) {
    super.didUpdateWidget(old);
    if (old.myRank != widget.myRank) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToUser());
    }
  }

  void _scrollToUser() {
    if (!_scrollController.hasClients) return;
    final viewportH  = _scrollController.position.viewportDimension;
    final userRowTop = _headerHeight + (_rowHeight * (widget.myRank - 1));
    final target     = userRowTop - viewportH + _rowHeight + 16;
    if (target > 0) {
      _scrollController.animateTo(
        target.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() { _scrollController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final showSticky = widget.myRank > 3;
    final me = widget.ranked.firstWhere((s) => s.isMe);

    return Stack(
      children: [
        // opt3: PageStorageKey prevents scroll jump on rebuild
        ListView.builder(
          key: const PageStorageKey('leaderboard'),
          controller: _scrollController,
          padding: EdgeInsets.fromLTRB(16, 16, 16, showSticky ? 100 : 24),
          itemCount: widget.ranked.length + 3,
          itemBuilder: (context, index) {
            if (index == 0) return _PodiumRow(ranked: widget.ranked);
            if (index == 1) return const SizedBox(height: 20);
            if (index == 2)
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text('Rankings',
                    style: GoogleFonts.poppins(
                        fontSize: 15, fontWeight: FontWeight.w700, color: _kDeep)),
              );
            final i = index - 3;
            return _LeaderboardRow(student: widget.ranked[i], rank: i + 1);
          },
        ),

        // opt2: animated sticky card — slides in when rank > 3
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          bottom: showSticky ? 12 : -120,
          left: 12, right: 12,
          child: _StickyUserCard(student: me, rank: widget.myRank),
        ),
      ],
    );
  }
}

// ── Sticky User Card ──────────────────────────────────────────────────────────
class _StickyUserCard extends StatelessWidget {
  const _StickyUserCard({required this.student, required this.rank});
  final _Student student;
  final int rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C5CE7), Color(0xFF9B8BFF)],
          begin: Alignment.centerLeft, end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x556C5CE7), blurRadius: 20, offset: Offset(0, 8)),
        ],
      ),
      child: Row(children: [
        // Rank badge
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text('#$rank',
              style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
        ),
        const SizedBox(width: 12),
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white.withValues(alpha: 0.3),
          child: Text(student.name[0].toUpperCase(),
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700, color: Colors.white, fontSize: 14)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('Your Rank',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: Colors.white.withValues(alpha: 0.75))),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('You',
                    style: GoogleFonts.poppins(
                        fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ]),
            Text(student.name,
                style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${student.totalPoints} pts',
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
          Text('${student.courseProgress}% • ${student.assignmentsDone} done',
              style: GoogleFonts.poppins(
                  fontSize: 10, color: Colors.white.withValues(alpha: 0.75))),
        ]),
      ]),
    );
  }
}

// ── Podium ────────────────────────────────────────────────────────────────────
class _PodiumRow extends StatelessWidget {
  const _PodiumRow({required this.ranked});
  final List<_Student> ranked;

  @override
  Widget build(BuildContext context) {
    if (ranked.length < 3) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF7C6CF6), Color(0xFF9B8BFF)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x2E7C6CF6), blurRadius: 16, offset: Offset(0, 8)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _PodiumItem(student: ranked[1], rank: 2, height: 80),
          _PodiumItem(student: ranked[0], rank: 1, height: 100),
          _PodiumItem(student: ranked[2], rank: 3, height: 65),
        ],
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  const _PodiumItem({required this.student, required this.rank, required this.height});
  final _Student student;
  final int rank;
  final double height;

  String get _medal => rank == 1 ? '🥇' : rank == 2 ? '🥈' : '🥉';

  @override
  Widget build(BuildContext context) {
    final isMe = student.isMe;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(_medal, style: const TextStyle(fontSize: 22)),
      const SizedBox(height: 6),
      Stack(clipBehavior: Clip.none, children: [
        CircleAvatar(
          radius: rank == 1 ? 28 : 22,
          backgroundColor: isMe
              ? Colors.white.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.25),
          child: Text(student.name[0].toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: rank == 1 ? 20 : 16, fontWeight: FontWeight.w700,
                color: isMe ? _kPurple : Colors.white,
              )),
        ),
        if (isMe)
          Positioned(
            right: -2, top: -2,
            child: Container(
              width: 14, height: 14,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.star_rounded, size: 10, color: _kPurple),
            ),
          ),
      ]),
      const SizedBox(height: 6),
      Text(isMe ? 'You' : student.name.split(' ').first,
          style: GoogleFonts.poppins(
              fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
      Text('${student.totalPoints} pts',
          style: GoogleFonts.poppins(
              fontSize: 11, color: Colors.white.withValues(alpha: 0.8))),
      const SizedBox(height: 8),
      Container(
        width: 60, height: height,
        decoration: BoxDecoration(
          color: isMe
              ? Colors.white.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.2),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        ),
        alignment: Alignment.center,
        child: Text('#$rank',
            style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
      ),
    ]);
  }
}

// ── Leaderboard Row ───────────────────────────────────────────────────────────
class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.student, required this.rank});
  final _Student student;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final isTop3 = rank <= 3;
    final isMe   = student.isMe;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: isMe
            ? const LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFF9B8BFF)],
                begin: Alignment.centerLeft, end: Alignment.centerRight)
            : null,
        color: isMe ? null : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: !isMe && isTop3
            ? Border.all(color: _kPurple.withValues(alpha: 0.3), width: 1.5)
            : isMe
                ? Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5)
                : null,
        boxShadow: isMe
            ? const [BoxShadow(color: Color(0x446C5CE7), blurRadius: 16, offset: Offset(0, 6))]
            : _kCardShadow,
      ),
      child: Row(children: [
        // Rank badge
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: isMe
                ? Colors.white.withValues(alpha: 0.25)
                : isTop3 ? _kPurple.withValues(alpha: 0.12) : const Color(0xFFF0EDFF),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text('#$rank',
              style: GoogleFonts.poppins(
                fontSize: 12, fontWeight: FontWeight.w700,
                color: isMe ? Colors.white : isTop3 ? _kPurple : _kDeep.withValues(alpha: 0.5),
              )),
        ),
        const SizedBox(width: 10),
        // Avatar
        CircleAvatar(
          radius: 20,
          backgroundColor: isMe
              ? Colors.white.withValues(alpha: 0.25)
              : student.avatarColor.withValues(alpha: 0.18),
          child: Text(student.name[0].toUpperCase(),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: isMe ? Colors.white : student.avatarColor,
                fontSize: 15,
              )),
        ),
        const SizedBox(width: 10),
        // Name + course
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(student.name,
                  style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: isMe ? Colors.white : _kDeep)),
              if (isMe) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('You',
                      style: GoogleFonts.poppins(
                          fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ],
            ]),
            Text(student.course,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: isMe
                      ? Colors.white.withValues(alpha: 0.75)
                      : _kDeep.withValues(alpha: 0.45),
                )),
          ]),
        ),
        // Points + stats
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${student.totalPoints} pts',
              style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: isMe ? Colors.white : _kPurple)),
          Text('${student.courseProgress}% • ${student.assignmentsDone} done',
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: isMe
                    ? Colors.white.withValues(alpha: 0.75)
                    : _kDeep.withValues(alpha: 0.45),
              )),
        ]),
      ]),
    );
  }
}

// ── All Students Tab ──────────────────────────────────────────────────────────
class _AllStudentsTab extends StatelessWidget {
  const _AllStudentsTab({required this.students});
  final List<_Student> students;

  @override
  Widget build(BuildContext context) {
    final avgProgress = students.fold(0, (s, e) => s + e.courseProgress) ~/
        students.length;
    final totalPoints = students.fold(0, (s, e) => s + e.totalPoints);
    final totalAssignments = students.fold(0, (s, e) => s + e.assignmentsDone);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        // Summary row
        Row(children: [
          Expanded(child: _SummaryCard(label: 'Avg Progress', value: '$avgProgress%',
              icon: Icons.show_chart_rounded, color: _kPurple)),
          const SizedBox(width: 10),
          Expanded(child: _SummaryCard(label: 'Total Points', value: '$totalPoints',
              icon: Icons.star_rounded, color: const Color(0xFF00C9A7))),
          const SizedBox(width: 10),
          Expanded(child: _SummaryCard(label: 'Assignments', value: '$totalAssignments',
              icon: Icons.task_alt_rounded, color: const Color(0xFFE8637A))),
        ]),
        const SizedBox(height: 16),
        Text('Student Profiles',
            style: GoogleFonts.poppins(
                fontSize: 15, fontWeight: FontWeight.w700, color: _kDeep)),
        const SizedBox(height: 10),
        for (final s in students) _StudentCard(student: s),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value,
      required this.icon, required this.color});
  final String label, value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(16), boxShadow: _kCardShadow),
      child: Column(children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.poppins(
            fontSize: 15, fontWeight: FontWeight.w700, color: _kDeep)),
        Text(label, textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                fontSize: 10, color: _kDeep.withValues(alpha: 0.5))),
      ]),
    );
  }
}

// ── Student Card ──────────────────────────────────────────────────────────────
class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.student});
  final _Student student;

  @override
  Widget build(BuildContext context) {
    final isMe = student.isMe;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: isMe ? Border.all(color: _kPurple.withValues(alpha: 0.4), width: 1.5) : null,
        boxShadow: _kCardShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: student.avatarColor.withValues(alpha: 0.15),
            child: Text(student.name[0],
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: student.avatarColor, fontSize: 17)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(student.name,
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w700, color: _kDeep)),
              if (isMe) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: _kPurple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('You',
                      style: GoogleFonts.poppins(
                          fontSize: 10, fontWeight: FontWeight.w700, color: _kPurple)),
                ),
              ],
            ]),
            Text(student.course,
                style: GoogleFonts.poppins(
                    fontSize: 12, color: _kDeep.withValues(alpha: 0.45))),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: const Color(0xFFF0EDFF),
                borderRadius: BorderRadius.circular(20)),
            child: Text('${student.totalPoints} pts',
                style: GoogleFonts.poppins(
                    fontSize: 11, fontWeight: FontWeight.w700, color: _kPurple)),
          ),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Text('Course Progress',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: _kDeep.withValues(alpha: 0.6))),
          const Spacer(),
          Text('${student.courseProgress}%',
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w600, color: _kPurple)),
        ]),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: student.courseProgress / 100.0),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              minHeight: 8, value: value,
              backgroundColor: const Color(0xFFE4DEFF),
              valueColor: const AlwaysStoppedAnimation<Color>(_kPurple),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          _StatChip(icon: Icons.task_alt_rounded,
              label: '${student.assignmentsDone} Assignments',
              color: const Color(0xFFE8637A)),
          const SizedBox(width: 8),
          _StatChip(icon: Icons.star_rounded,
              label: '${student.totalPoints} pts', color: _kPurple),
        ]),
      ]),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }
}
