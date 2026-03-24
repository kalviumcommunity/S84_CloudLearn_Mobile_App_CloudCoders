import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/course_data.dart';
import '../services/course_progress_service.dart';
import 'course_detail_screen.dart';

const _kPurple = Color(0xFF6C5CE7);
const _kDeep = Color(0xFF2D1A4D);
const _kBg = Color(0xFFF3F0FF);
const _kGreen = Color(0xFF00C9A7);
const _kCardShadow = [
  BoxShadow(color: Color(0x0F000000), blurRadius: 14, offset: Offset(0, 6)),
];

const _courseColors = {
  'cloud-computing-basics': Color(0xFF7A68F9),
  'aws-fundamentals': Color(0xFF00C9A7),
  'azure-for-beginners': Color(0xFF4C9AFF),
  'kubernetes-essentials': Color(0xFFFF8A65),
};

const _courseIcons = {
  'cloud-computing-basics': Icons.cloud_rounded,
  'aws-fundamentals': Icons.storage_rounded,
  'azure-for-beginners': Icons.rocket_launch_rounded,
  'kubernetes-essentials': Icons.hub_rounded,
};

enum _CourseFilter { all, inProgress, completed }

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});
  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  final _progressService = CourseProgressService();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  _CourseFilter _selectedFilter = _CourseFilter.all;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Warm up cache from Firestore once; subsequent opens are instant
    await _progressService.warmUpCache(allCourses.map((c) => c.id).toList());
    if (mounted) setState(() => _loading = false);
  }

  // Refresh from Firestore (pull-to-refresh)
  Future<void> _refresh() async {
    _progressService.invalidateCache();
    await _progressService.warmUpCache(allCourses.map((c) => c.id).toList());
    if (mounted) setState(() {});
  }

  int _watchedCount(CourseInfo c) =>
      _progressService.getCachedWatchedCount(c.id);

  double _progress(CourseInfo c) {
    final total = c.totalLessons;
    if (total == 0) return 0;
    return (_watchedCount(c) / total).clamp(0.0, 1.0);
  }

  bool _isCompleted(CourseInfo c) => _progress(c) >= 1.0;
  bool _isStarted(CourseInfo c) => _watchedCount(c) > 0;

  List<CourseInfo> get _filtered => allCourses.where((c) {
        final matchSearch =
            c.title.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchFilter = switch (_selectedFilter) {
          _CourseFilter.all => true,
          _CourseFilter.inProgress => _isStarted(c) && !_isCompleted(c),
          _CourseFilter.completed => _isCompleted(c),
        };
        return matchSearch && matchFilter;
      }).toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = allCourses.where(_isCompleted).length;
    final inProgressCount =
        allCourses.where((c) => _isStarted(c) && !_isCompleted(c)).length;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        title: Text('My Courses',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700, color: _kDeep)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kDeep),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _kPurple))
          : RefreshIndicator(
              color: _kPurple,
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  Row(children: [
                    _SummaryChip(
                        label: 'Total',
                        value: '${allCourses.length}',
                        color: _kPurple),
                    const SizedBox(width: 10),
                    _SummaryChip(
                        label: 'In Progress',
                        value: '$inProgressCount',
                        color: const Color(0xFFFF8A65)),
                    const SizedBox(width: 10),
                    _SummaryChip(
                        label: 'Completed',
                        value: '$completedCount',
                        color: _kGreen),
                  ]),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _searchController,
                    onChanged: (v) =>
                        setState(() => _searchQuery = v.trim()),
                    decoration: InputDecoration(
                      hintText: 'Search courses...',
                      hintStyle: GoogleFonts.poppins(
                          fontSize: 13,
                          color: _kDeep.withValues(alpha: 0.4)),
                      prefixIcon: Icon(Icons.search_rounded,
                          color: _kDeep.withValues(alpha: 0.4)),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    _FilterChip(
                        label: 'All',
                        selected:
                            _selectedFilter == _CourseFilter.all,
                        onTap: () => setState(
                            () => _selectedFilter = _CourseFilter.all)),
                    const SizedBox(width: 8),
                    _FilterChip(
                        label: 'In Progress',
                        selected: _selectedFilter ==
                            _CourseFilter.inProgress,
                        onTap: () => setState(() =>
                            _selectedFilter = _CourseFilter.inProgress)),
                    const SizedBox(width: 8),
                    _FilterChip(
                        label: 'Completed',
                        selected: _selectedFilter ==
                            _CourseFilter.completed,
                        onTap: () => setState(() =>
                            _selectedFilter = _CourseFilter.completed)),
                  ]),
                  const SizedBox(height: 14),
                  if (_selectedFilter == _CourseFilter.completed &&
                      _filtered.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(children: [
                        const Text('🎓',
                            style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text('Great work! Keep it up.',
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _kGreen)),
                      ]),
                    ),
                  if (_filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(
                          child: Column(children: [
                        Icon(Icons.search_off_rounded,
                            size: 48,
                            color: _kDeep.withValues(alpha: 0.2)),
                        const SizedBox(height: 10),
                        Text('No courses found',
                            style: GoogleFonts.poppins(
                                color: _kDeep.withValues(alpha: 0.4))),
                      ])),
                    )
                  else
                    for (final course in _filtered)
                      _CourseCard(
                        course: course,
                        color: _courseColors[course.id] ??
                            const Color(0xFF7A68F9),
                        icon: _courseIcons[course.id] ??
                            Icons.school_rounded,
                        progress: _progress(course),
                        watchedCount: _watchedCount(course),
                        isCompleted: _isCompleted(course),
                        isStarted: _isStarted(course),
                        onTap: () => _openDetail(course),
                      ),
                ],
              ),
            ),
    );
  }

  void _openDetail(CourseInfo course) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => CourseDetailScreen(
        course: course,
        color: _courseColors[course.id] ?? const Color(0xFF7A68F9),
        icon: _courseIcons[course.id] ?? Icons.school_rounded,
      ),
    ));
    // Refresh UI from cache (already updated by CourseDetailScreen)
    if (mounted) setState(() {});
  }
}

// ── Course Card ───────────────────────────────────────────────────────────────
class _CourseCard extends StatelessWidget {
  const _CourseCard({
    required this.course,
    required this.color,
    required this.icon,
    required this.progress,
    required this.watchedCount,
    required this.isCompleted,
    required this.isStarted,
    required this.onTap,
  });
  final CourseInfo course;
  final Color color;
  final IconData icon;
  final double progress;
  final int watchedCount;
  final bool isCompleted;
  final bool isStarted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();
    final remaining = course.totalLessons - watchedCount;
    final hoursLeft = (course.estimatedHours * (1 - progress)).ceil();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: isCompleted
              ? Border.all(
                  color: _kGreen.withValues(alpha: 0.4), width: 1.5)
              : null,
          boxShadow: _kCardShadow,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Stack(children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: color.withValues(alpha: 0.12)),
                child: Icon(icon, color: color, size: 28),
              ),
              if (isCompleted)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                        color: _kGreen, shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 12),
                  ),
                ),
            ]),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(course.title,
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _kDeep)),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(course.category,
                        style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: color)),
                  ),
                ])),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isCompleted
                    ? _kGreen.withValues(alpha: 0.1)
                    : color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(isCompleted ? '100%' : '$percent%',
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isCompleted ? _kGreen : color)),
            ),
          ]),
          const SizedBox(height: 14),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: value,
                backgroundColor: color.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? _kGreen : color),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(children: [
            if (isCompleted) ...[
              const Icon(Icons.emoji_events_rounded,
                  size: 13, color: _kGreen),
              const SizedBox(width: 4),
              Text('${course.totalLessons} lessons completed',
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: _kGreen,
                      fontWeight: FontWeight.w500)),
            ] else if (isStarted) ...[
              Icon(Icons.play_circle_outline_rounded,
                  size: 13, color: _kDeep.withValues(alpha: 0.4)),
              const SizedBox(width: 4),
              Text('$remaining left',
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: _kDeep.withValues(alpha: 0.45))),
              const SizedBox(width: 8),
              Icon(Icons.timer_outlined,
                  size: 13, color: _kDeep.withValues(alpha: 0.4)),
              const SizedBox(width: 4),
              Text('~$hoursLeft hrs',
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: _kDeep.withValues(alpha: 0.45))),
            ] else ...[
              Icon(Icons.menu_book_outlined,
                  size: 13, color: _kDeep.withValues(alpha: 0.4)),
              const SizedBox(width: 4),
              Text(
                  '${course.totalLessons} lessons • ${course.estimatedHours} hrs',
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: _kDeep.withValues(alpha: 0.45))),
            ],
            const Spacer(),
            FilledButton.icon(
              onPressed: onTap,
              icon: Icon(
                  isCompleted
                      ? Icons.replay_rounded
                      : isStarted
                          ? Icons.play_arrow_rounded
                          : Icons.rocket_launch_rounded,
                  size: 15),
              label: Text(
                  isCompleted
                      ? 'Review'
                      : isStarted
                          ? 'Resume'
                          : 'Start',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, fontSize: 12)),
              style: FilledButton.styleFrom(
                backgroundColor: isCompleted ? _kGreen : color,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

// ── Summary Chip ──────────────────────────────────────────────────────────────
class _SummaryChip extends StatelessWidget {
  const _SummaryChip(
      {required this.label, required this.value, required this.color});
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
            boxShadow: _kCardShadow),
        child: Column(children: [
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color)),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 10, color: _kDeep.withValues(alpha: 0.5))),
        ]),
      ),
    );
  }
}

// ── Filter Chip ───────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  const _FilterChip(
      {required this.label,
      required this.selected,
      required this.onTap});
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
        child: Text(label,
            style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white
                    : _kDeep.withValues(alpha: 0.5))),
      ),
    );
  }
}
