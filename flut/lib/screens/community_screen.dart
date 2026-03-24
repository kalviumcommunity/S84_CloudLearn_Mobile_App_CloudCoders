import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Shared constants (matches app-wide style) ─────────────────────────────────
const _kPurple = Color(0xFF6C5CE7);
const _kDeep = Color(0xFF2D1A4D);
const _kBg = Color(0xFFF3F0FF);
const _kCardShadow = [
  BoxShadow(color: Color(0x0F000000), blurRadius: 14, offset: Offset(0, 6)),
];

// ── Fake student data ─────────────────────────────────────────────────────────
class _Student {
  const _Student({
    required this.name,
    required this.course,
    required this.assignmentsDone,
    required this.courseProgress,
    required this.accuracy,
    required this.avatarColor,
  });

  final String name;
  final String course;
  final int assignmentsDone;
  final double courseProgress; // 0.0 – 1.0
  final double accuracy;       // 0.0 – 1.0
  final Color avatarColor;

  int get score =>
      (assignmentsDone * 10) + (courseProgress * 100).round() + (accuracy * 50).round();
}

const _students = <_Student>[
  _Student(
    name: 'Ayesha Khan',
    course: 'Cloud Computing',
    assignmentsDone: 9,
    courseProgress: 0.92,
    accuracy: 0.95,
    avatarColor: Color(0xFF7C6CF6),
  ),
  _Student(
    name: 'Bilal Ahmed',
    course: 'AWS Fundamentals',
    assignmentsDone: 8,
    courseProgress: 0.85,
    accuracy: 0.88,
    avatarColor: Color(0xFF00C9A7),
  ),
  _Student(
    name: 'Sara Malik',
    course: 'Azure for Beginners',
    assignmentsDone: 7,
    courseProgress: 0.78,
    accuracy: 0.91,
    avatarColor: Color(0xFFE8637A),
  ),
  _Student(
    name: 'Usman Tariq',
    course: 'Kubernetes Essentials',
    assignmentsDone: 6,
    courseProgress: 0.65,
    accuracy: 0.82,
    avatarColor: Color(0xFFFF8A65),
  ),
  _Student(
    name: 'Hira Baig',
    course: 'Cloud Computing',
    assignmentsDone: 6,
    courseProgress: 0.60,
    accuracy: 0.79,
    avatarColor: Color(0xFF4C9AFF),
  ),
  _Student(
    name: 'Zain Raza',
    course: 'AWS Fundamentals',
    assignmentsDone: 5,
    courseProgress: 0.55,
    accuracy: 0.74,
    avatarColor: Color(0xFFE8A020),
  ),
  _Student(
    name: 'Nadia Hussain',
    course: 'Azure for Beginners',
    assignmentsDone: 4,
    courseProgress: 0.48,
    accuracy: 0.70,
    avatarColor: Color(0xFF9B59B6),
  ),
  _Student(
    name: 'Hamza Sheikh',
    course: 'Kubernetes Essentials',
    assignmentsDone: 3,
    courseProgress: 0.35,
    accuracy: 0.65,
    avatarColor: Color(0xFF2ECC71),
  ),
  _Student(
    name: 'Fatima Zahra',
    course: 'Cloud Computing',
    assignmentsDone: 3,
    courseProgress: 0.30,
    accuracy: 0.60,
    avatarColor: Color(0xFFE74C3C),
  ),
  _Student(
    name: 'Ali Hassan',
    course: 'AWS Fundamentals',
    assignmentsDone: 2,
    courseProgress: 0.20,
    accuracy: 0.55,
    avatarColor: Color(0xFF1ABC9C),
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Sort leaderboard by score descending
  late final List<_Student> _ranked;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _ranked = [..._students]..sort((a, b) => b.score.compareTo(a.score));
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
        title: Text(
          'Community',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: _kDeep),
        ),
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
          tabs: const [
            Tab(text: 'Leaderboard'),
            Tab(text: 'All Students'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LeaderboardTab(ranked: _ranked),
          _AllStudentsTab(students: _students),
        ],
      ),
    );
  }
}

// ── Leaderboard Tab ───────────────────────────────────────────────────────────
class _LeaderboardTab extends StatelessWidget {
  const _LeaderboardTab({required this.ranked});
  final List<_Student> ranked;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        // Top 3 podium
        _PodiumRow(ranked: ranked),
        const SizedBox(height: 20),
        // Rest of the list
        Text(
          'Rankings',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _kDeep,
          ),
        ),
        const SizedBox(height: 10),
        for (int i = 0; i < ranked.length; i++)
          _LeaderboardRow(student: ranked[i], rank: i + 1),
      ],
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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
  const _PodiumItem({
    required this.student,
    required this.rank,
    required this.height,
  });

  final _Student student;
  final int rank;
  final double height;

  String get _medal {
    if (rank == 1) return '🥇';
    if (rank == 2) return '🥈';
    return '🥉';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_medal, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 6),
        CircleAvatar(
          radius: rank == 1 ? 28 : 22,
          backgroundColor: Colors.white.withValues(alpha: 0.25),
          child: Text(
            student.name[0],
            style: GoogleFonts.poppins(
              fontSize: rank == 1 ? 20 : 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          student.name.split(' ').first,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Text(
          '${student.score} pts',
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          ),
          alignment: Alignment.center,
          child: Text(
            '#$rank',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
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

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isTop3
            ? Border.all(color: _kPurple.withValues(alpha: 0.3), width: 1.5)
            : null,
        boxShadow: _kCardShadow,
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isTop3
                  ? _kPurple.withValues(alpha: 0.12)
                  : const Color(0xFFF0EDFF),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              '#$rank',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isTop3 ? _kPurple : _kDeep.withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: student.avatarColor.withValues(alpha: 0.18),
            child: Text(
              student.name[0],
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: student.avatarColor,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Name + course
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _kDeep,
                  ),
                ),
                Text(
                  student.course,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: _kDeep.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
          // Stats column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${student.score} pts',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _kPurple,
                ),
              ),
              Text(
                '${(student.courseProgress * 100).round()}% • ${student.assignmentsDone} done',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: _kDeep.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── All Students Tab ──────────────────────────────────────────────────────────
class _AllStudentsTab extends StatelessWidget {
  const _AllStudentsTab({required this.students});
  final List<_Student> students;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        // Summary stats row
        _SummaryRow(students: students),
        const SizedBox(height: 16),
        Text(
          'Student Profiles',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _kDeep,
          ),
        ),
        const SizedBox(height: 10),
        for (final s in students) _StudentCard(student: s),
      ],
    );
  }
}

// ── Summary Row ───────────────────────────────────────────────────────────────
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.students});
  final List<_Student> students;

  @override
  Widget build(BuildContext context) {
    final avgProgress = students.fold(0.0, (s, e) => s + e.courseProgress) /
        students.length;
    final avgAccuracy = students.fold(0.0, (s, e) => s + e.accuracy) /
        students.length;
    final totalAssignments =
        students.fold(0, (s, e) => s + e.assignmentsDone);

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Avg Progress',
            value: '${(avgProgress * 100).round()}%',
            icon: Icons.show_chart_rounded,
            color: _kPurple,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            label: 'Avg Accuracy',
            value: '${(avgAccuracy * 100).round()}%',
            icon: Icons.gps_fixed_rounded,
            color: const Color(0xFF00C9A7),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            label: 'Assignments',
            value: '$totalAssignments',
            icon: Icons.task_alt_rounded,
            color: const Color(0xFFE8637A),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _kCardShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _kDeep,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: _kDeep.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Student Card ──────────────────────────────────────────────────────────────
class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.student});
  final _Student student;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: _kCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: student.avatarColor.withValues(alpha: 0.15),
                child: Text(
                  student.name[0],
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: student.avatarColor,
                    fontSize: 17,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _kDeep,
                      ),
                    ),
                    Text(
                      student.course,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: _kDeep.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EDFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${student.score} pts',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _kPurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Course progress bar
          Row(
            children: [
              Text(
                'Course Progress',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: _kDeep.withValues(alpha: 0.6)),
              ),
              const Spacer(),
              Text(
                '${(student.courseProgress * 100).round()}%',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _kPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: student.courseProgress),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: value,
                backgroundColor: const Color(0xFFE4DEFF),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(_kPurple),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Stats chips row
          Row(
            children: [
              _StatChip(
                icon: Icons.task_alt_rounded,
                label: '${student.assignmentsDone} Assignments',
                color: const Color(0xFFE8637A),
              ),
              const SizedBox(width: 8),
              _StatChip(
                icon: Icons.gps_fixed_rounded,
                label: '${(student.accuracy * 100).round()}% Accuracy',
                color: const Color(0xFF00C9A7),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
