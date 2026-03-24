import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'course_detail_screen.dart';

// ── Constants ─────────────────────────────────────────────────────────────────
const _kPurple = Color(0xFF6C5CE7);
const _kDeep = Color(0xFF2D1A4D);
const _kBg = Color(0xFFF3F0FF);
const _kCardShadow = [
  BoxShadow(color: Color(0x0F000000), blurRadius: 14, offset: Offset(0, 6)),
];

// ── Model ─────────────────────────────────────────────────────────────────────
class _CourseItem {
  const _CourseItem({
    required this.title,
    required this.progress,
    required this.lessonsCompleted,
    required this.totalLessons,
    required this.color,
    required this.icon,
    required this.category,
    required this.estimatedHours,
  });

  final String title;
  final double progress;
  final int lessonsCompleted;
  final int totalLessons;
  final Color color;
  final IconData icon;
  final String category;
  final int estimatedHours;

  bool get isCompleted => progress >= 1.0;
}

enum _CourseFilter { all, inProgress, completed }

// ── Screen ────────────────────────────────────────────────────────────────────
class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  _CourseFilter _selectedFilter = _CourseFilter.all;

  final List<_CourseItem> _courses = const [
    _CourseItem(
      title: 'Cloud Computing Basics',
      progress: 0.60,
      lessonsCompleted: 12,
      totalLessons: 20,
      color: Color(0xFF7A68F9),
      icon: Icons.cloud_rounded,
      category: 'Cloud',
      estimatedHours: 8,
    ),
    _CourseItem(
      title: 'AWS Fundamentals',
      progress: 0.30,
      lessonsCompleted: 6,
      totalLessons: 20,
      color: Color(0xFF00C9A7),
      icon: Icons.storage_rounded,
      category: 'AWS',
      estimatedHours: 10,
    ),
    _CourseItem(
      title: 'Azure for Beginners',
      progress: 1.0,
      lessonsCompleted: 14,
      totalLessons: 14,
      color: Color(0xFF4C9AFF),
      icon: Icons.rocket_launch_rounded,
      category: 'Azure',
      estimatedHours: 6,
    ),
    _CourseItem(
      title: 'Kubernetes Essentials',
      progress: 0.45,
      lessonsCompleted: 9,
      totalLessons: 20,
      color: Color(0xFFFF8A65),
      icon: Icons.hub_rounded,
      category: 'DevOps',
      estimatedHours: 12,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_CourseItem> get _filteredCourses {
    return _courses.where((course) {
      final matchesSearch =
          course.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = switch (_selectedFilter) {
        _CourseFilter.all => true,
        _CourseFilter.inProgress => !course.isCompleted,
        _CourseFilter.completed => course.isCompleted,
      };
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final courses = _filteredCourses;
    final completedCount = _courses.where((c) => c.isCompleted).length;
    final inProgressCount = _courses.where((c) => !c.isCompleted).length;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        title: Text(
          'My Courses',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700, color: _kDeep),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kDeep),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // ── Summary row ───────────────────────────────────────────
            Row(
              children: [
                _SummaryChip(
                  label: 'Total',
                  value: '${_courses.length}',
                  color: _kPurple,
                ),
                const SizedBox(width: 10),
                _SummaryChip(
                  label: 'In Progress',
                  value: '$inProgressCount',
                  color: const Color(0xFFFF8A65),
                ),
                const SizedBox(width: 10),
                _SummaryChip(
                  label: 'Completed',
                  value: '$completedCount',
                  color: const Color(0xFF00C9A7),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Search ────────────────────────────────────────────────
            TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v.trim()),
              decoration: InputDecoration(
                hintText: 'Search courses...',
                hintStyle: GoogleFonts.poppins(
                    fontSize: 13, color: _kDeep.withValues(alpha: 0.4)),
                prefixIcon:
                    Icon(Icons.search_rounded, color: _kDeep.withValues(alpha: 0.4)),
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Filter chips ──────────────────────────────────────────
            Row(
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _selectedFilter == _CourseFilter.all,
                  onTap: () =>
                      setState(() => _selectedFilter = _CourseFilter.all),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'In Progress',
                  selected: _selectedFilter == _CourseFilter.inProgress,
                  onTap: () => setState(
                      () => _selectedFilter = _CourseFilter.inProgress),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Completed',
                  selected: _selectedFilter == _CourseFilter.completed,
                  onTap: () => setState(
                      () => _selectedFilter = _CourseFilter.completed),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Completed section header ───────────────────────────────
            if (_selectedFilter == _CourseFilter.completed &&
                courses.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    const Text('🎓', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      'Great work! Keep it up.',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF00C9A7),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Course cards ──────────────────────────────────────────
            if (courses.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.search_off_rounded,
                          size: 48, color: _kDeep.withValues(alpha: 0.2)),
                      const SizedBox(height: 10),
                      Text(
                        'No courses found',
                        style: GoogleFonts.poppins(
                            color: _kDeep.withValues(alpha: 0.4)),
                      ),
                    ],
                  ),
                ),
              )
            else
              for (final course in courses)
                course.isCompleted
                    ? _CompletedCourseCard(
                        course: course,
                        onTap: () => _openDetail(course),
                      )
                    : _InProgressCourseCard(
                        course: course,
                        onTap: () => _openDetail(course),
                      ),
          ],
        ),
      ),
    );
  }

  void _openDetail(_CourseItem course) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => CourseDetailScreen(
        title: course.title,
        color: course.color,
        icon: course.icon,
        progress: course.progress,
        lessonsCompleted: course.lessonsCompleted,
        totalLessons: course.totalLessons,
      ),
    ));
  }
}

// ── In-Progress Card ──────────────────────────────────────────────────────────
class _InProgressCourseCard extends StatelessWidget {
  const _InProgressCourseCard({required this.course, required this.onTap});
  final _CourseItem course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final percent = (course.progress * 100).round();
    final remaining = course.totalLessons - course.lessonsCompleted;
    final hoursLeft =
        ((course.estimatedHours * (1 - course.progress))).ceil();

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: course.color.withValues(alpha: 0.12),
                  ),
                  child: Icon(course.icon, color: course.color, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _kDeep,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: course.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          course.category,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: course.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: course.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$percent%',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: course.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: course.progress),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: value,
                  backgroundColor: course.color.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(course.color),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.play_circle_outline_rounded,
                    size: 14, color: _kDeep.withValues(alpha: 0.4)),
                const SizedBox(width: 4),
                Text(
                  '$remaining lessons left',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: _kDeep.withValues(alpha: 0.45)),
                ),
                const SizedBox(width: 10),
                Icon(Icons.timer_outlined,
                    size: 14, color: _kDeep.withValues(alpha: 0.4)),
                const SizedBox(width: 4),
                Text(
                  '~$hoursLeft hrs left',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: _kDeep.withValues(alpha: 0.45)),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.play_arrow_rounded, size: 16),
                  label: Text(
                    'Resume',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: course.color,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Completed Card ────────────────────────────────────────────────────────────
class _CompletedCourseCard extends StatelessWidget {
  const _CompletedCourseCard({required this.course, required this.onTap});
  final _CourseItem course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: const Color(0xFF00C9A7).withValues(alpha: 0.4), width: 1.5),
          boxShadow: _kCardShadow,
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: course.color.withValues(alpha: 0.12),
                  ),
                  child: Icon(course.icon, color: course.color, size: 28),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00C9A7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _kDeep,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.emoji_events_rounded,
                          size: 13, color: Color(0xFF00C9A7)),
                      const SizedBox(width: 4),
                      Text(
                        '${course.totalLessons} lessons completed',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF00C9A7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C9A7).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '100%',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF00C9A7),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Review →',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _kPurple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Summary Chip ──────────────────────────────────────────────────────────────
class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: _kCardShadow,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: _kDeep.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filter Chip ───────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _kPurple : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: _kCardShadow,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : _kDeep.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}
