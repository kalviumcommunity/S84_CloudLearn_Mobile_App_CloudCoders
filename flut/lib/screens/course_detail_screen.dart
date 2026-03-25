import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/course_data.dart';
import '../services/course_progress_service.dart';

const _kPurple = Color(0xFF6C5CE7);
const _kDeep = Color(0xFF2D1A4D);
const _kBg = Color(0xFFF3F0FF);
const _kGreen = Color(0xFF00C9A7);
const _kCardShadow = [
  BoxShadow(color: Color(0x0F000000), blurRadius: 14, offset: Offset(0, 6)),
];

// ── Course Detail Screen ──────────────────────────────────────────────────────
class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({
    super.key,
    required this.course,
    required this.color,
    required this.icon,
  });
  final CourseInfo course;
  final Color color;
  final IconData icon;

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final _svc = CourseProgressService();

  // These are read directly from the singleton cache — always current.
  Set<String> get _watchedIds => _svc.getWatchedSync(widget.course.id);
  Map<String, DateTime> get _completedAt => _svc.getCompletedAtSync(widget.course.id);

  int get _totalLessons => widget.course.totalLessons;
  double get _progress =>
      _totalLessons == 0 ? 0 : (_watchedIds.length / _totalLessons).clamp(0.0, 1.0);
  bool get _isCompleted =>
      _watchedIds.length >= _totalLessons && _totalLessons > 0;

  @override
  void initState() {
    super.initState();
    // If cache wasn't warmed (e.g. deep-linked directly), sync this course
    if (!ProgressCache.instance.isLoaded) {
      _svc.syncCourse(widget.course.id).then((_) {
        if (mounted) setState(() {});
      });
    }
  }

  void _toggleLesson(String id) {
    // Update cache + fire Firestore persist — both synchronous from UI perspective
    _svc.toggleLesson(
      courseId: widget.course.id,
      courseTitle: widget.course.title,
      lessonId: id,
      totalVideos: _totalLessons,
    );
    setState(() {}); // rebuild from updated cache
  }

  void _openLesson(LessonContent lesson) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => LessonDetailScreen(
        lesson: lesson,
        accentColor: widget.color,
        isCompleted: _watchedIds.contains(lesson.id),
        completedAt: _completedAt[lesson.id],
        onMarkComplete: () => _toggleLesson(lesson.id),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: CustomScrollView(
        slivers: [
          // ── Hero header ───────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 210,
            pinned: true,
            backgroundColor: widget.color,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.color, widget.color.withValues(alpha: 0.75)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(widget.icon, color: Colors.white, size: 28),
                        ),
                        const SizedBox(height: 10),
                        Text(widget.course.title,
                          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('${widget.course.modules.length} modules • $_totalLessons lessons',
                          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _ProgressCard(
                  progress: _progress,
                  watched: _watchedIds.length,
                  total: _totalLessons,
                  color: widget.color,
                  isCompleted: _isCompleted,
                ),
                const SizedBox(height: 16),

                // ── Completion banner ─────────────────────────────────
                if (_isCompleted) ...[
                  _CompletedBanner(courseTitle: widget.course.title),
                  const SizedBox(height: 16),
                ],

                // ── Modules & lessons ─────────────────────────────────
                Text('Course Content',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: _kDeep)),
                const SizedBox(height: 12),

                for (int i = 0; i < widget.course.modules.length; i++)
                  _ModuleCard(
                    module: widget.course.modules[i],
                    moduleIndex: i + 1,
                    watchedIds: _watchedIds,
                    accentColor: widget.color,
                    onLessonTap: _openLesson,
                    onToggle: _toggleLesson,
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Progress Card ─────────────────────────────────────────────────────────────
class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.progress, required this.watched,
    required this.total, required this.color, required this.isCompleted,
  });
  final double progress; final int watched; final int total;
  final Color color; final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: _kCardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(isCompleted ? 'Course Completed 🎉' : 'Your Progress',
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: _kDeep)),
          const Spacer(),
          Text('${(progress * 100).round()}%',
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: isCompleted ? _kGreen : color)),
        ]),
        const SizedBox(height: 10),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              minHeight: 10, value: value,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(isCompleted ? _kGreen : color),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text('$watched of $total lessons completed',
          style: GoogleFonts.poppins(fontSize: 12, color: _kDeep.withValues(alpha: 0.5))),
      ]),
    );
  }
}

// ── Completed Banner ──────────────────────────────────────────────────────────
class _CompletedBanner extends StatelessWidget {
  const _CompletedBanner({required this.courseTitle});
  final String courseTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(colors: [_kGreen, Color(0xFF00B4D8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: const [BoxShadow(color: Color(0x22009A7A), blurRadius: 16, offset: Offset(0, 8))],
      ),
      child: Row(children: [
        const Text('🏆', style: TextStyle(fontSize: 36)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Congratulations!', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
          Text('You completed $courseTitle', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withValues(alpha: 0.85))),
        ])),
        ElevatedButton(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Certificate coming soon!'))),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, foregroundColor: _kGreen, elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
          child: Text('Certificate', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 12)),
        ),
      ]),
    );
  }
}

// ── Module Card ───────────────────────────────────────────────────────────────
class _ModuleCard extends StatefulWidget {
  const _ModuleCard({
    required this.module, required this.moduleIndex, required this.watchedIds,
    required this.accentColor, required this.onLessonTap, required this.onToggle,
  });
  final CourseModule module;
  final int moduleIndex;
  final Set<String> watchedIds;
  final Color accentColor;
  final void Function(LessonContent) onLessonTap;
  final void Function(String) onToggle;

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard> {
  bool _expanded = true;

  int get _doneCount => widget.module.lessons.where((l) => widget.watchedIds.contains(l.id)).length;
  bool get _moduleComplete => _doneCount == widget.module.lessons.length;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: _kCardShadow),
      child: Column(children: [
        // Module header
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: _moduleComplete ? _kGreen.withValues(alpha: 0.15) : widget.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: _moduleComplete
                    ? const Icon(Icons.check_circle_rounded, color: _kGreen, size: 20)
                    : Text('${widget.moduleIndex}',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: widget.accentColor, fontSize: 14)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.module.title,
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: _kDeep)),
                Text('$_doneCount/${widget.module.lessons.length} completed',
                  style: GoogleFonts.poppins(fontSize: 11, color: _kDeep.withValues(alpha: 0.45))),
              ])),
              Icon(_expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                color: _kDeep.withValues(alpha: 0.4)),
            ]),
          ),
        ),

        if (_expanded) ...[
          const Divider(height: 1, indent: 14, endIndent: 14),
          for (final lesson in widget.module.lessons)
            _LessonRow(
              lesson: lesson,
              isDone: widget.watchedIds.contains(lesson.id),
              accentColor: widget.accentColor,
              onTap: () => widget.onLessonTap(lesson),
              onToggle: () => widget.onToggle(lesson.id),
            ),
        ],
      ]),
    );
  }
}

// ── Lesson Row ────────────────────────────────────────────────────────────────
class _LessonRow extends StatelessWidget {
  const _LessonRow({
    required this.lesson, required this.isDone, required this.accentColor,
    required this.onTap, required this.onToggle,
  });
  final LessonContent lesson;
  final bool isDone;
  final Color accentColor;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(children: [
          // Green dot / empty circle indicator
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26, height: 26,
              decoration: BoxDecoration(
                color: isDone ? _kGreen : Colors.transparent,
                border: Border.all(color: isDone ? _kGreen : _kDeep.withValues(alpha: 0.2), width: 2),
                shape: BoxShape.circle,
              ),
              child: isDone ? const Icon(Icons.check_rounded, color: Colors.white, size: 14) : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(lesson.title,
              style: GoogleFonts.poppins(
                fontSize: 13, fontWeight: FontWeight.w500,
                color: isDone ? _kDeep.withValues(alpha: 0.4) : _kDeep,
                decoration: isDone ? TextDecoration.lineThrough : null,
              )),
            Text(lesson.duration,
              style: GoogleFonts.poppins(fontSize: 11, color: _kDeep.withValues(alpha: 0.4))),
          ])),
          // Open lesson arrow
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.arrow_forward_ios_rounded, color: accentColor, size: 14),
          ),
        ]),
      ),
    );
  }
}

// ── Lesson Detail Screen ──────────────────────────────────────────────────────
class LessonDetailScreen extends StatefulWidget {
  const LessonDetailScreen({
    super.key,
    required this.lesson,
    required this.accentColor,
    required this.isCompleted,
    required this.onMarkComplete,
    this.completedAt,
  });
  final LessonContent lesson;
  final Color accentColor;
  final bool isCompleted;
  final VoidCallback onMarkComplete;
  final DateTime? completedAt;

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  late bool _done;
  DateTime? _completedAt;

  @override
  void initState() {
    super.initState();
    _done = widget.isCompleted;
    _completedAt = widget.completedAt;
  }

  Future<void> _openVideo() async {
    final uri = Uri.parse(widget.lesson.youtubeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _markDone() {
    if (!_done) {
      final now = DateTime.now();
      setState(() { _done = true; _completedAt = now; });
      widget.onMarkComplete();
    }
  }

  String _formatCompletedAt(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        title: Text('Lesson', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: _kDeep)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kDeep),
        actions: [
          if (_done)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.check_circle_rounded, color: _kGreen, size: 18),
                const SizedBox(width: 4),
                Text('Done', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: _kGreen)),
              ]),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // ── Title card ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: _kCardShadow,
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: widget.accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.menu_book_rounded, color: widget.accentColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.lesson.title,
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: _kDeep)),
                  Text(widget.lesson.duration,
                    style: GoogleFonts.poppins(fontSize: 12, color: _kDeep.withValues(alpha: 0.45))),
                ])),
              ]),
            ]),
          ),
          const SizedBox(height: 14),

          // ── Watch video button ────────────────────────────────────
          GestureDetector(
            onTap: _openVideo,
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: [widget.accentColor, widget.accentColor.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                boxShadow: [BoxShadow(color: widget.accentColor.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 8))],
              ),
              child: Stack(alignment: Alignment.center, children: [
                Icon(Icons.play_circle_filled_rounded, size: 64, color: Colors.white.withValues(alpha: 0.9)),
                Positioned(bottom: 14, left: 16, right: 16,
                  child: Row(children: [
                    const Icon(Icons.youtube_searched_for_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text('Watch on YouTube', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                      child: Text(widget.lesson.duration, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white)),
                    ),
                  ]),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 14),

          // ── Summary ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: _kCardShadow),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: const Color(0xFFF0EDFF), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.article_rounded, color: _kPurple, size: 18),
                ),
                const SizedBox(width: 10),
                Text('Lesson Summary', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: _kDeep)),
              ]),
              const SizedBox(height: 12),
              Text(widget.lesson.summary,
                style: GoogleFonts.poppins(fontSize: 13, color: _kDeep.withValues(alpha: 0.75), height: 1.6)),
            ]),
          ),
          const SizedBox(height: 14),

          // ── Key Points ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: _kCardShadow),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: _kGreen.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.lightbulb_rounded, color: _kGreen, size: 18),
                ),
                const SizedBox(width: 10),
                Text('Key Points', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: _kDeep)),
              ]),
              const SizedBox(height: 12),
              for (final point in widget.lesson.keyPoints)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      width: 8, height: 8,
                      decoration: BoxDecoration(color: widget.accentColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(point,
                      style: GoogleFonts.poppins(fontSize: 13, color: _kDeep.withValues(alpha: 0.75), height: 1.5))),
                  ]),
                ),
            ]),
          ),
          const SizedBox(height: 20),

          // ── Mark Complete button ──────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: _done
                ? Column(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _kGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _kGreen.withValues(alpha: 0.4)),
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.check_circle_rounded, color: _kGreen, size: 20),
                        const SizedBox(width: 8),
                        Text('Lesson Completed', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: _kGreen)),
                      ]),
                    ),
                    if (_completedAt != null) ...[
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.access_time_rounded, size: 13, color: _kDeep.withValues(alpha: 0.4)),
                        const SizedBox(width: 4),
                        Text(
                          'Completed on ${_formatCompletedAt(_completedAt!)}',
                          style: GoogleFonts.poppins(fontSize: 11, color: _kDeep.withValues(alpha: 0.45)),
                        ),
                      ]),
                    ],
                  ])
                : FilledButton.icon(
                    onPressed: _markDone,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: Text('Mark as Complete', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                    style: FilledButton.styleFrom(
                      backgroundColor: widget.accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
