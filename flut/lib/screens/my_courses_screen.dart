import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

enum _CourseFilter { all, inProgress, completed }

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
    ),
    _CourseItem(
      title: 'AWS Fundamentals',
      progress: 0.30,
      lessonsCompleted: 6,
      totalLessons: 20,
      color: Color(0xFF00C9A7),
      icon: Icons.storage_rounded,
    ),
    _CourseItem(
      title: 'Azure for Beginners',
      progress: 1.0,
      lessonsCompleted: 14,
      totalLessons: 14,
      color: Color(0xFF4C9AFF),
      icon: Icons.rocket_launch_rounded,
    ),
    _CourseItem(
      title: 'Kubernetes Essentials',
      progress: 0.45,
      lessonsCompleted: 9,
      totalLessons: 20,
      color: Color(0xFFFF8A65),
      icon: Icons.hub_rounded,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_CourseItem> get _filteredCourses {
    return _courses.where((course) {
      final matchesSearch = course.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = switch (_selectedFilter) {
        _CourseFilter.all => true,
        _CourseFilter.inProgress => course.progress < 1.0,
        _CourseFilter.completed => course.progress >= 1.0,
      };
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final courses = _filteredCourses;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F0FF),
      appBar: AppBar(
        title: Text(
          'My Courses',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value.trim()),
              decoration: InputDecoration(
                hintText: 'Search courses',
                prefixIcon: const Icon(Icons.search_rounded),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _selectedFilter == _CourseFilter.all,
                  onSelected: (_) => setState(() => _selectedFilter = _CourseFilter.all),
                ),
                ChoiceChip(
                  label: const Text('In Progress'),
                  selected: _selectedFilter == _CourseFilter.inProgress,
                  onSelected: (_) => setState(() => _selectedFilter = _CourseFilter.inProgress),
                ),
                ChoiceChip(
                  label: const Text('Completed'),
                  selected: _selectedFilter == _CourseFilter.completed,
                  onSelected: (_) => setState(() => _selectedFilter = _CourseFilter.completed),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (courses.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 32),
                child: Center(child: Text('No courses found for current filters.')),
              )
            else
              ...courses.map((course) => _CourseCard(course: course)),
          ],
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final _CourseItem course;

  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final percent = (course.progress * 100).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: course.color.withValues(alpha: 0.15),
                ),
                child: Icon(course.icon, color: course.color, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  course.title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D1A4D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Progress: $percent%',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF5A4C78),
            ),
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: course.progress),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  minHeight: 10,
                  value: value,
                  backgroundColor: course.color.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(course.color),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '${course.lessonsCompleted}/${course.totalLessons} lessons completed',
                style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6D5D8F)),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Resuming ${course.title}...')),
                  );
                },
                child: const Text('Resume'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CourseItem {
  final String title;
  final double progress;
  final int lessonsCompleted;
  final int totalLessons;
  final Color color;
  final IconData icon;

  const _CourseItem({
    required this.title,
    required this.progress,
    required this.lessonsCompleted,
    required this.totalLessons,
    required this.color,
    required this.icon,
  });
}