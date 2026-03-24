import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/course_progress_service.dart';

// ── Constants ─────────────────────────────────────────────────────────────────
const _kPurple = Color(0xFF6C5CE7);
const _kDeep = Color(0xFF2D1A4D);
const _kBg = Color(0xFFF3F0FF);
const _kCardShadow = [
  BoxShadow(color: Color(0x0F000000), blurRadius: 14, offset: Offset(0, 6)),
];

// ── Data models ───────────────────────────────────────────────────────────────
class VideoLesson {
  const VideoLesson({
    required this.id,
    required this.title,
    required this.duration,
    required this.youtubeUrl,
  });
  final String id;
  final String title;
  final String duration;
  final String youtubeUrl;
}

class CourseModule {
  const CourseModule({
    required this.title,
    required this.videos,
  });
  final String title;
  final List<VideoLesson> videos;
}

// ── Course video data ─────────────────────────────────────────────────────────
final Map<String, List<CourseModule>> courseModules = {
  'Cloud Computing Basics': [
    CourseModule(title: 'Module 1: Introduction to Cloud', videos: [
      VideoLesson(id: 'cc1_1', title: 'What is Cloud Computing?', duration: '8 min', youtubeUrl: 'https://www.youtube.com/watch?v=M988_fsOSWo'),
      VideoLesson(id: 'cc1_2', title: 'Cloud Service Models (IaaS, PaaS, SaaS)', duration: '10 min', youtubeUrl: 'https://www.youtube.com/watch?v=9CVBohl6w0Q'),
      VideoLesson(id: 'cc1_3', title: 'Public, Private & Hybrid Cloud', duration: '7 min', youtubeUrl: 'https://www.youtube.com/watch?v=3meFAfJBMf8'),
    ]),
    CourseModule(title: 'Module 2: Cloud Architecture', videos: [
      VideoLesson(id: 'cc2_1', title: 'Virtualization Explained', duration: '9 min', youtubeUrl: 'https://www.youtube.com/watch?v=FZR0rG3HKIk'),
      VideoLesson(id: 'cc2_2', title: 'Scalability & Load Balancing', duration: '11 min', youtubeUrl: 'https://www.youtube.com/watch?v=K0Ta65OqQkY'),
    ]),
    CourseModule(title: 'Module 3: Cloud Security', videos: [
      VideoLesson(id: 'cc3_1', title: 'Cloud Security Fundamentals', duration: '12 min', youtubeUrl: 'https://www.youtube.com/watch?v=0ldy8oTjMlI'),
      VideoLesson(id: 'cc3_2', title: 'Identity & Access Management', duration: '9 min', youtubeUrl: 'https://www.youtube.com/watch?v=y8cbKJAo3B4'),
    ]),
    CourseModule(title: 'Module 4: Deployment & DevOps', videos: [
      VideoLesson(id: 'cc4_1', title: 'CI/CD in the Cloud', duration: '14 min', youtubeUrl: 'https://www.youtube.com/watch?v=scEDHsr3APg'),
      VideoLesson(id: 'cc4_2', title: 'Containers vs VMs', duration: '8 min', youtubeUrl: 'https://www.youtube.com/watch?v=cjXI-yenr-0'),
    ]),
  ],
  'AWS Fundamentals': [
    CourseModule(title: 'Module 1: AWS Overview', videos: [
      VideoLesson(id: 'aws1_1', title: 'AWS Global Infrastructure', duration: '10 min', youtubeUrl: 'https://www.youtube.com/watch?v=a9__D53WsUs'),
      VideoLesson(id: 'aws1_2', title: 'AWS Management Console Tour', duration: '8 min', youtubeUrl: 'https://www.youtube.com/watch?v=IT1X42D1KeA'),
    ]),
    CourseModule(title: 'Module 2: Core AWS Services', videos: [
      VideoLesson(id: 'aws2_1', title: 'Amazon EC2 Explained', duration: '13 min', youtubeUrl: 'https://www.youtube.com/watch?v=TsRBftzZsQo'),
      VideoLesson(id: 'aws2_2', title: 'Amazon S3 Deep Dive', duration: '11 min', youtubeUrl: 'https://www.youtube.com/watch?v=77lMCiiMilo'),
      VideoLesson(id: 'aws2_3', title: 'AWS Lambda & Serverless', duration: '12 min', youtubeUrl: 'https://www.youtube.com/watch?v=eOBq__h4OJ4'),
    ]),
    CourseModule(title: 'Module 3: Networking on AWS', videos: [
      VideoLesson(id: 'aws3_1', title: 'VPC from Scratch', duration: '15 min', youtubeUrl: 'https://www.youtube.com/watch?v=g2JOHLHh4rI'),
      VideoLesson(id: 'aws3_2', title: 'Route 53 & DNS', duration: '9 min', youtubeUrl: 'https://www.youtube.com/watch?v=RGWgfhZByAI'),
    ]),
  ],
  'Azure for Beginners': [
    CourseModule(title: 'Module 1: Azure Basics', videos: [
      VideoLesson(id: 'az1_1', title: 'What is Microsoft Azure?', duration: '9 min', youtubeUrl: 'https://www.youtube.com/watch?v=3Arj5zlUderA'),
      VideoLesson(id: 'az1_2', title: 'Azure Portal Walkthrough', duration: '10 min', youtubeUrl: 'https://www.youtube.com/watch?v=NKEFWyqJ5XA'),
    ]),
    CourseModule(title: 'Module 2: Azure Compute', videos: [
      VideoLesson(id: 'az2_1', title: 'Azure Virtual Machines', duration: '12 min', youtubeUrl: 'https://www.youtube.com/watch?v=inaXkN2UrFE'),
      VideoLesson(id: 'az2_2', title: 'Azure App Service', duration: '10 min', youtubeUrl: 'https://www.youtube.com/watch?v=4BwyqmRTrx8'),
    ]),
    CourseModule(title: 'Module 3: Azure Storage & DB', videos: [
      VideoLesson(id: 'az3_1', title: 'Azure Blob Storage', duration: '8 min', youtubeUrl: 'https://www.youtube.com/watch?v=UJG6viKU_A8'),
      VideoLesson(id: 'az3_2', title: 'Azure SQL Database', duration: '11 min', youtubeUrl: 'https://www.youtube.com/watch?v=BgvEOkcR0Wk'),
    ]),
  ],
  'Kubernetes Essentials': [
    CourseModule(title: 'Module 1: Kubernetes Intro', videos: [
      VideoLesson(id: 'k8s1_1', title: 'Kubernetes in 5 Minutes', duration: '5 min', youtubeUrl: 'https://www.youtube.com/watch?v=PH-2FfFD2PU'),
      VideoLesson(id: 'k8s1_2', title: 'Pods, Nodes & Clusters', duration: '12 min', youtubeUrl: 'https://www.youtube.com/watch?v=QJ4fODH6DXI'),
    ]),
    CourseModule(title: 'Module 2: Deployments & Services', videos: [
      VideoLesson(id: 'k8s2_1', title: 'Kubernetes Deployments', duration: '14 min', youtubeUrl: 'https://www.youtube.com/watch?v=mxSmx9T5MpA'),
      VideoLesson(id: 'k8s2_2', title: 'Services & Networking', duration: '11 min', youtubeUrl: 'https://www.youtube.com/watch?v=5lzUpDtmWgM'),
      VideoLesson(id: 'k8s2_3', title: 'ConfigMaps & Secrets', duration: '9 min', youtubeUrl: 'https://www.youtube.com/watch?v=FAnQTgr04mU'),
    ]),
    CourseModule(title: 'Module 3: Advanced Kubernetes', videos: [
      VideoLesson(id: 'k8s3_1', title: 'Helm Charts Explained', duration: '13 min', youtubeUrl: 'https://www.youtube.com/watch?v=-ykwb1d0DXU'),
      VideoLesson(id: 'k8s3_2', title: 'Kubernetes Monitoring', duration: '10 min', youtubeUrl: 'https://www.youtube.com/watch?v=QoDqxm7ybLc'),
    ]),
  ],
};

// ── Screen ────────────────────────────────────────────────────────────────────
class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({
    super.key,
    required this.title,
    required this.color,
    required this.icon,
    required this.progress,
    required this.lessonsCompleted,
    required this.totalLessons,
  });

  final String title;
  final Color color;
  final IconData icon;
  final double progress;
  final int lessonsCompleted;
  final int totalLessons;

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late List<CourseModule> _modules;
  Set<String> _watchedIds = {};
  bool _loading = true;

  final _progressService = CourseProgressService();

  // Slug used as Firestore key (spaces → dashes, lowercase)
  String get _courseId =>
      widget.title.toLowerCase().replaceAll(' ', '-');

  @override
  void initState() {
    super.initState();
    _modules = courseModules[widget.title] ?? [];
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final saved = await _progressService.getWatchedVideoIds(_courseId);
    if (mounted) {
      setState(() {
        _watchedIds = saved;
        _loading = false;
      });
    }
  }

  int get _totalVideos =>
      _modules.fold(0, (sum, m) => sum + m.videos.length);

  double get _currentProgress =>
      _totalVideos == 0 ? 0 : _watchedIds.length / _totalVideos;

  bool get _isCompleted =>
      _watchedIds.length >= _totalVideos && _totalVideos > 0;

  void _toggleWatched(String id) {
    setState(() {
      if (_watchedIds.contains(id)) {
        _watchedIds.remove(id);
      } else {
        _watchedIds.add(id);
      }
    });
    // Persist to Firestore after every toggle
    _progressService.saveWatchedVideoIds(
      courseId: _courseId,
      courseTitle: widget.title,
      watchedIds: Set.from(_watchedIds),
      totalVideos: _totalVideos,
    );
  }

  Future<void> _openVideo(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: _kBg,
        body: const Center(
          child: CircularProgressIndicator(color: _kPurple),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _kBg,
      body: CustomScrollView(
        slivers: [
          // ── Hero App Bar ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: widget.color,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.color, widget.color.withValues(alpha: 0.7)],
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
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(widget.icon, color: Colors.white, size: 28),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.title,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_modules.length} modules • $_totalVideos videos',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Progress card ─────────────────────────────────────
                  _ProgressCard(
                    progress: _currentProgress,
                    watched: _watchedIds.length,
                    total: _totalVideos,
                    color: widget.color,
                    isCompleted: _isCompleted,
                  ),
                  const SizedBox(height: 20),

                  // ── Completed banner ──────────────────────────────────
                  if (_isCompleted) ...[
                    _CompletedBanner(courseTitle: widget.title),
                    const SizedBox(height: 20),
                  ],

                  // ── Modules ───────────────────────────────────────────
                  Text(
                    'Course Content',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _kDeep,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (int i = 0; i < _modules.length; i++)
                    _ModuleSection(
                      module: _modules[i],
                      moduleIndex: i + 1,
                      watchedIds: _watchedIds,
                      accentColor: widget.color,
                      onToggle: _toggleWatched,
                      onOpenVideo: _openVideo,
                    ),
                ],
              ),
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
    required this.progress,
    required this.watched,
    required this.total,
    required this.color,
    required this.isCompleted,
  });

  final double progress;
  final int watched;
  final int total;
  final Color color;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Text(
                isCompleted ? 'Course Completed 🎉' : 'Your Progress',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _kDeep,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}%',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                minHeight: 10,
                value: value,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCompleted ? const Color(0xFF00C9A7) : color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$watched of $total videos watched',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: _kDeep.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
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
        gradient: const LinearGradient(
          colors: [Color(0xFF00C9A7), Color(0xFF00B4D8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x2200C9A7), blurRadius: 16, offset: Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Congratulations!',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'You completed $courseTitle',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Certificate feature coming soon!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF00C9A7),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            child: Text(
              'Certificate',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Module Section ────────────────────────────────────────────────────────────
class _ModuleSection extends StatefulWidget {
  const _ModuleSection({
    required this.module,
    required this.moduleIndex,
    required this.watchedIds,
    required this.accentColor,
    required this.onToggle,
    required this.onOpenVideo,
  });

  final CourseModule module;
  final int moduleIndex;
  final Set<String> watchedIds;
  final Color accentColor;
  final void Function(String id) onToggle;
  final Future<void> Function(String url) onOpenVideo;

  @override
  State<_ModuleSection> createState() => _ModuleSectionState();
}

class _ModuleSectionState extends State<_ModuleSection> {
  bool _expanded = true;

  int get _watchedInModule =>
      widget.module.videos.where((v) => widget.watchedIds.contains(v.id)).length;

  bool get _moduleCompleted =>
      _watchedInModule == widget.module.videos.length;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: _kCardShadow,
      ),
      child: Column(
        children: [
          // Module header
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _moduleCompleted
                          ? const Color(0xFF00C9A7).withValues(alpha: 0.15)
                          : widget.accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: _moduleCompleted
                        ? const Icon(Icons.check_circle_rounded,
                            color: Color(0xFF00C9A7), size: 20)
                        : Text(
                            '${widget.moduleIndex}',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              color: widget.accentColor,
                              fontSize: 14,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.module.title,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _kDeep,
                          ),
                        ),
                        Text(
                          '$_watchedInModule/${widget.module.videos.length} watched',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: _kDeep.withValues(alpha: 0.45),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: _kDeep.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ),

          // Video list
          if (_expanded)
            Column(
              children: [
                const Divider(height: 1, indent: 14, endIndent: 14),
                for (final video in widget.module.videos)
                  _VideoRow(
                    video: video,
                    isWatched: widget.watchedIds.contains(video.id),
                    accentColor: widget.accentColor,
                    onToggle: () => widget.onToggle(video.id),
                    onOpen: () => widget.onOpenVideo(video.youtubeUrl),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

// ── Video Row ─────────────────────────────────────────────────────────────────
class _VideoRow extends StatelessWidget {
  const _VideoRow({
    required this.video,
    required this.isWatched,
    required this.accentColor,
    required this.onToggle,
    required this.onOpen,
  });

  final VideoLesson video;
  final bool isWatched;
  final Color accentColor;
  final VoidCallback onToggle;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          // Watch/unwatch toggle
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isWatched
                    ? const Color(0xFF00C9A7)
                    : Colors.transparent,
                border: Border.all(
                  color: isWatched
                      ? const Color(0xFF00C9A7)
                      : _kDeep.withValues(alpha: 0.2),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: isWatched
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 16)
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // Video info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isWatched
                        ? _kDeep.withValues(alpha: 0.4)
                        : _kDeep,
                    decoration:
                        isWatched ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  video.duration,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: _kDeep.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),

          // Play button
          GestureDetector(
            onTap: onOpen,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.play_arrow_rounded,
                  color: accentColor, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
