import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'assignments_screen.dart';
import 'community_screen.dart';
import 'progress_analytics_screen.dart';
import 'profile_screen.dart';
import 'my_courses_screen.dart';
import 'notifications_screen.dart';

// ── Shared constants ──────────────────────────────────────────────────────────
const _kPurple = Color(0xFF6C5CE7);
const _kDeep = Color(0xFF2D1A4D);

const _kCardShadow = [
  BoxShadow(
    color: Color(0x12000000),
    blurRadius: 14,
    offset: Offset(0, 6),
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────
class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _progressAnimation;

  int _selectedIndex = 0;
  int _notificationCount = 3;

  String get _userName {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'Learner';
    if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
      return user.displayName!.split(' ').first;
    }
    final email = user.email ?? '';
    return email.isNotEmpty ? email.split('@').first : 'Learner';
  }

  final List<_FeatureItem> _features = const [
    _FeatureItem(
      label: 'My Courses',
      icon: Icons.menu_book_rounded,
      color: Color(0xFF7C6CF6),
      bgColor: Color(0xFFF0EDFF),
    ),
    _FeatureItem(
      label: 'Assignments',
      icon: Icons.assignment_rounded,
      color: Color(0xFFE8637A),
      bgColor: Color(0xFFFFF0F2),
    ),
    _FeatureItem(
      label: 'Progress',
      icon: Icons.auto_graph_rounded,
      color: Color(0xFF00A896),
      bgColor: Color(0xFFEBFAF8),
    ),
    _FeatureItem(
      label: 'Community',
      icon: Icons.people_alt_rounded,
      color: Color(0xFFE8A020),
      bgColor: Color(0xFFFFF8EC),
    ),
  ];

  final List<_StatItem> _stats = const [
    _StatItem(label: 'Courses', value: '8', icon: Icons.school_rounded),
    _StatItem(label: 'Pending', value: '3', icon: Icons.pending_actions_rounded),
    _StatItem(label: 'Progress', value: '60%', icon: Icons.show_chart_rounded),
    _StatItem(label: 'Streak', value: '12d', icon: Icons.local_fire_department_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _progressAnimation = Tween<double>(begin: 0, end: 0.6).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning ☀️';
    if (hour < 17) return 'Good afternoon 🌤️';
    return 'Good evening 🌙';
  }

  void _openFeature(String label) {
    switch (label) {
      case 'Assignments':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const AssignmentsScreen()));
      case 'My Courses':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const MyCoursesScreen()));
      case 'Progress':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const ProgressAnalyticsScreen()));
      case 'Community':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const CommunityScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEEE9FF), Color(0xFFD9D4FF), Color(0xFFC9C3FF)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ───────────────────────────────────────────
                  _Header(
                    greeting: _greeting(),
                    userName: _userName,
                    notificationCount: _notificationCount,
                    onNotificationTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const NotificationsScreen(),
                          ),
                        );
                        setState(() => _notificationCount = 0);
                      },
                  ),
                  const SizedBox(height: 24),

                  // ── Continue Learning ────────────────────────────────
                  _ContinueLearningCard(progressAnimation: _progressAnimation),
                  const SizedBox(height: 16),

                  // ── Daily Challenge ──────────────────────────────────
                  const _DailyChallengeCard(),
                  const SizedBox(height: 26),

                  // ── Quick Access ─────────────────────────────────────
                  Text(
                    'Quick Access',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _kDeep,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.15,
                    children: [
                      for (int i = 0; i < _features.length; i++)
                        _FeatureCard(
                          item: _features[i],
                          onTap: () => _openFeature(_features[i].label),
                        ),
                    ],
                  ),
                  const SizedBox(height: 26),

                  // ── Stats ────────────────────────────────────────────
                  Text(
                    'Your Stats',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _kDeep,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      for (int i = 0; i < _stats.length; i++) ...[
                        Expanded(child: _StatCard(item: _stats[i])),
                        if (i < _stats.length - 1) const SizedBox(width: 10),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _BottomNav(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              setState(() => _selectedIndex = 0);
            case 1:
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MyCoursesScreen()));
            case 2:
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ProgressAnalyticsScreen()));
            case 3:
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()));
          }
        },
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({
    required this.greeting,
    required this.userName,
    required this.notificationCount,
    required this.onNotificationTap,
  });

  final String greeting;
  final String userName;
  final int notificationCount;
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: _kDeep.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                userName,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _kDeep,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: _kCardShadow,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.notifications_outlined, size: 22),
                color: _kDeep,
                onPressed: onNotificationTap,
              ),
            ),
            if (notificationCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE53935),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$notificationCount',
                    style: const TextStyle(
                      fontSize: 8,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ── Continue Learning Card ────────────────────────────────────────────────────
class _ContinueLearningCard extends StatelessWidget {
  final Animation<double> progressAnimation;
  const _ContinueLearningCard({required this.progressAnimation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: _kCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EDFF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.cloud_done_rounded,
                    color: _kPurple, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Continue Learning',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _kDeep,
                      ),
                    ),
                    Text(
                      'Cloud Computing Basics • Module 3',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: _kDeep.withValues(alpha: 0.5),
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
                  '60%',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _kPurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: progressAnimation,
            builder: (context, _) => ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                minHeight: 7,
                value: progressAnimation.value,
                backgroundColor: const Color(0xFFF0EDFF),
                valueColor: const AlwaysStoppedAnimation<Color>(_kPurple),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: Text(
                'Resume Course',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: _kPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Daily Challenge Card ──────────────────────────────────────────────────────
class _DailyChallengeCard extends StatelessWidget {
  const _DailyChallengeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF7C6CF6), Color(0xFF9B8BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2E7C6CF6),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Daily Challenge',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'What is a VPC?',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cloud Networking • 2 min',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.white,
                    foregroundColor: _kPurple,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Start',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.emoji_events_rounded,
            size: 64,
            color: Colors.white.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }
}

// ── Feature Card ──────────────────────────────────────────────────────────────
class _FeatureCard extends StatefulWidget {
  final _FeatureItem item;
  final VoidCallback onTap;
  const _FeatureCard({required this.item, required this.onTap});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: _kCardShadow,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: widget.item.bgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(widget.item.icon,
                    color: widget.item.color, size: 26),
              ),
              const SizedBox(height: 12),
              Text(
                widget.item.label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: _kDeep,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final _StatItem item;
  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: _kCardShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EDFF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, size: 18, color: _kPurple),
          ),
          const SizedBox(height: 8),
          Text(
            item.value,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _kDeep,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
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

// ── Bottom Navigation ─────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.selectedIndex, required this.onTap});
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              selected: selectedIndex == 0,
              onTap: () => onTap(0)),
          _NavItem(
              icon: Icons.menu_book_rounded,
              label: 'Courses',
              selected: selectedIndex == 1,
              onTap: () => onTap(1)),
          _NavItem(
              icon: Icons.auto_graph_rounded,
              label: 'Progress',
              selected: selectedIndex == 2,
              onTap: () => onTap(2)),
          _NavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              selected: selectedIndex == 3,
              onTap: () => onTap(3)),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFF0EDFF)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: selected ? _kPurple : _kDeep.withValues(alpha: 0.4),
            ),
            if (selected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _kPurple,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Models ────────────────────────────────────────────────────────────────────
class _FeatureItem {
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;
  const _FeatureItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  const _StatItem(
      {required this.label, required this.value, required this.icon});
}
