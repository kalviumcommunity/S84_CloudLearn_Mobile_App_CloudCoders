import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'progress_analytics_screen.dart';

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
    _FeatureItem(label: 'My Courses', icon: Icons.menu_book_rounded, color: Color(0xFF7A68F9)),
    _FeatureItem(label: 'Assignments', icon: Icons.assignment_rounded, color: Color(0xFFFF6B9D)),
    _FeatureItem(label: 'Progress', icon: Icons.auto_graph_rounded, color: Color(0xFF00C9A7)),
    _FeatureItem(label: 'Community', icon: Icons.people_alt_rounded, color: Color(0xFFFFB347)),
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
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEAFF),
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEEE9FF),
              Color(0xFFD9D4FF),
              Color(0xFFC9C3FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 104),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Bar
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _greeting(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: const Color(0xFF2D1A4D).withValues(alpha: 0.65),
                                    ),
                                  ),
                                  Text(
                                    _userName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF2D1A4D),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                    child: Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.55),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.4),
                                        ),
                                      ),
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(Icons.notifications_rounded),
                                        color: const Color(0xFF2D1A4D),
                                        onPressed: () {
                                          setState(() => _notificationCount = 0);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                if (_notificationCount > 0)
                                  Positioned(
                                    right: 6,
                                    top: 6,
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFF4757),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '$_notificationCount',
                                        style: const TextStyle(
                                          fontSize: 9,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Continue Learning Card
                        _ContinueLearningCard(progressAnimation: _progressAnimation),
                        const SizedBox(height: 18),

                        // Daily Challenge Card
                        const _DailyChallengeCard(),
                        const SizedBox(height: 24),

                        // Feature Grid
                        Text(
                          'Quick Access',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2D1A4D),
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 1.1,
                          children: [
                            for (int i = 0; i < _features.length; i++)
                              _FeatureCard(item: _features[i], delayMs: 80 * i),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Stats
                        Text(
                          'Your Stats',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2D1A4D),
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
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: NavigationBar(
                height: 68,
                selectedIndex: _selectedIndex,
                backgroundColor: Colors.transparent,
                indicatorColor: const Color(0xFF6C5CE7).withValues(alpha: 0.18),
                labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
                onDestinationSelected: (index) {
                  if (index == 2) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProgressAnalyticsScreen()),
                    );
                    return;
                  }

                  setState(() => _selectedIndex = index);
                },
                destinations: const [
                  NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
                  NavigationDestination(icon: Icon(Icons.menu_book_rounded), label: 'Courses'),
                  NavigationDestination(icon: Icon(Icons.auto_graph_rounded), label: 'Progress'),
                  NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profile'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Continue Learning Card
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
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
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7A68F9), Color(0xFFB26BFF)],
                  ),
                ),
                child: const Icon(Icons.cloud_done_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Continue Learning',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2D1A4D),
                      ),
                    ),
                    Text(
                      'Cloud Computing Basics • Module 3',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF2D1A4D).withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '60%',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6C5CE7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AnimatedBuilder(
            animation: progressAnimation,
            builder: (context, _) => ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: progressAnimation.value,
                backgroundColor: const Color(0xFFF0EEFF),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: Text(
                'Resume Course',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFF6C5CE7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Daily Challenge Card
class _DailyChallengeCard extends StatelessWidget {
  const _DailyChallengeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF6C5CE7), Color(0xFFB26BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF6C5CE7),
            blurRadius: 18,
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white24,
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
                const SizedBox(height: 8),
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
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF6C5CE7),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    'Start',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.emoji_events_rounded, size: 72, color: Colors.white24),
        ],
      ),
    );
  }
}

// Feature Card
class _FeatureCard extends StatefulWidget {
  final _FeatureItem item;
  final int delayMs;
  const _FeatureCard({required this.item, required this.delayMs});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 380 + widget.delayMs),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: () {},
          child: AnimatedScale(
            duration: const Duration(milliseconds: 150),
            scale: _isPressed ? 0.96 : 1,
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 16,
                    offset: Offset(0, _isPressed ? 4 : 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.item.color.withValues(alpha: 0.14),
                    ),
                    child: Icon(widget.item.icon, color: widget.item.color, size: 28),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.item.label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: const Color(0xFF2D1A4D),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Stat Card
class _StatCard extends StatelessWidget {
  final _StatItem item;
  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF6C5CE7).withValues(alpha: 0.12),
            ),
            child: Icon(item.icon, size: 18, color: const Color(0xFF6C5CE7)),
          ),
          const SizedBox(height: 8),
          Text(
            item.value,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D1A4D),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2D1A4D).withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}

// Models
class _FeatureItem {
  final String label;
  final IconData icon;
  final Color color;
  const _FeatureItem({required this.label, required this.icon, required this.color});
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  const _StatItem({required this.label, required this.value, required this.icon});
}
