import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/course_data.dart';
import '../services/course_progress_service.dart';
import '../services/firestore_service.dart';

const _kPurple = Color(0xFF6C5CE7);
const _kDeep = Color(0xFF2D1A4D);
const _kGreen = Color(0xFF00C9A7);
const _kBg = Color(0xFFF3F0FF);
const _kCardShadow = [
  BoxShadow(color: Color(0x0F000000), blurRadius: 14, offset: Offset(0, 6)),
];

const _courseColors = {
  'cloud-computing-basics': Color(0xFF7A68F9),
  'aws-fundamentals': Color(0xFF00C9A7),
  'azure-for-beginners': Color(0xFF4C9AFF),
  'kubernetes-essentials': Color(0xFFFF8A65),
};

class ProgressAnalyticsScreen extends StatefulWidget {
  const ProgressAnalyticsScreen({super.key});
  @override
  State<ProgressAnalyticsScreen> createState() =>
      _ProgressAnalyticsScreenState();
}

class _ProgressAnalyticsScreenState extends State<ProgressAnalyticsScreen> {
  final _svc = CourseProgressService();
  final _firestoreService = FirestoreService();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (!ProgressCache.instance.isLoaded) {
      await _svc.warmUp(allCourses.map((c) => c.id).toList());
    }
    if (mounted) setState(() => _loading = false);
  }

  double _progress(CourseInfo c) {
    final t = c.totalLessons;
    return t == 0 ? 0 : (_svc.getWatchedCountSync(c.id) / t).clamp(0.0, 1.0);
  }

  int get _completedCourses =>
      allCourses.where((c) => _progress(c) >= 1.0).length;

  int get _totalLessonsCompleted =>
      allCourses.fold(0, (s, c) => s + _svc.getWatchedCountSync(c.id));

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: _kBg,
        body: Center(child: CircularProgressIndicator(color: _kPurple)),
      );
    }

    const chartData = <double>[1.5, 2.0, 2.8, 1.2, 3.3, 4.0, 3.2];
    const maxY = 5.0;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        title: Text('Progress Overview',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700, color: _kDeep)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kDeep),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: _kCardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📊 Weekly Learning Chart',
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _kDeep)),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 220,
                    child: BarChart(BarChartData(
                      maxY: maxY,
                      alignment: BarChartAlignment.spaceAround,
                      gridData: FlGridData(
                        show: true,
                        horizontalInterval: 1,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => const FlLine(
                            color: Color(0xFFE4DEFF), strokeWidth: 1),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            interval: 1,
                            getTitlesWidget: (v, _) => Text('${v.toInt()}h',
                                style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: const Color(0xFF7A6B9A))),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              const days = [
                                'Mon','Tue','Wed','Thu','Fri','Sat','Sun'
                              ];
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(days[v.toInt()],
                                    style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: const Color(0xFF7A6B9A))),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: [
                        for (int i = 0; i < chartData.length; i++)
                          BarChartGroupData(x: i, barRods: [
                            BarChartRodData(
                              toY: chartData[i],
                              width: 18,
                              borderRadius: BorderRadius.circular(6),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7A68F9), Color(0xFF00C9A7)],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ]),
                      ],
                    )),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            StreamBuilder<Map<String, dynamic>>(
              stream: _firestoreService.getCurrentUserStream(),
              builder: (context, snapshot) {
                final userData = snapshot.data ?? {};
                final totalPoints = userData['totalPoints'] as int? ?? 0;
                final completedLessons = userData['completedLessons'];
                final lessonsFromFirestore = completedLessons is Map
                    ? completedLessons.length
                    : _totalLessonsCompleted;
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.5,
                  children: [
                    _StatCard(
                        title: 'Courses Completed',
                        value: '$_completedCourses',
                        icon: Icons.school_rounded),
                    _StatCard(
                        title: 'Lessons Done',
                        value: '$lessonsFromFirestore',
                        icon: Icons.task_alt_rounded),
                    _StatCard(
                        title: 'Total Points',
                        value: '$totalPoints',
                        icon: Icons.star_rounded),
                    const _StatCard(
                        title: 'Current Streak',
                        value: '—',
                        icon: Icons.local_fire_department_rounded),
                  ],
                );
              },
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: _kCardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Course Completion',
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _kDeep)),
                  const SizedBox(height: 10),
                  for (final course in allCourses)
                    _CourseProgressRow(
                      course: course,
                      progress: _progress(course),
                      color: _courseColors[course.id] ?? _kPurple,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseProgressRow extends StatelessWidget {
  const _CourseProgressRow({
    required this.course,
    required this.progress,
    required this.color,
  });
  final CourseInfo course;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();
    final watched = (progress * course.totalLessons).round();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(course.title,
                  style: GoogleFonts.poppins(fontSize: 13, color: _kDeep))),
          Text(
            '$watched/${course.totalLessons} • $percent%',
            style: GoogleFonts.poppins(
                fontSize: 12,
                color: progress >= 1.0
                    ? _kGreen
                    : _kDeep.withValues(alpha: 0.5),
                fontWeight: progress >= 1.0
                    ? FontWeight.w600
                    : FontWeight.normal),
          ),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            minHeight: 9,
            value: progress,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? _kGreen : color),
          ),
        ),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _StatCard(
      {required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: _kPurple),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _kDeep)),
          Text(title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                  fontSize: 11, color: const Color(0xFF7A6B9A))),
        ],
      ),
    );
  }
}
