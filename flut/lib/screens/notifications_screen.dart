import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _kPurple = Color(0xFF7C6CF6);
const _kDeep = Color(0xFF2D1A4D);

class _NotificationItem {
  const _NotificationItem({
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    this.isRead = false,
  });

  final String title;
  final String body;
  final String time;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final bool isRead;
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  final List<_NotificationItem> _notifications = [
    const _NotificationItem(
      title: 'Assignment Due Tomorrow',
      body: 'Cloud Computing Assignment 1 is due on 25 March 2026 at 11:59 PM.',
      time: '2 hours ago',
      icon: Icons.assignment_late_rounded,
      iconBg: Color(0xFFFFF0F2),
      iconColor: Color(0xFFE8637A),
    ),
    const _NotificationItem(
      title: 'New Course Available',
      body: 'AWS Solutions Architect – Beginner has been added to your catalog.',
      time: '5 hours ago',
      icon: Icons.school_rounded,
      iconBg: Color(0xFFF0EDFF),
      iconColor: _kPurple,
    ),
    const _NotificationItem(
      title: 'Daily Challenge Ready',
      body: 'Today\'s challenge: "What is a VPC?" — 2 min. Earn 10 XP!',
      time: '8 hours ago',
      icon: Icons.emoji_events_rounded,
      iconBg: Color(0xFFFFF8EC),
      iconColor: Color(0xFFE8A020),
    ),
    const _NotificationItem(
      title: 'Assignment Submitted',
      body: 'Your submission for Cloud Security Quiz was received successfully.',
      time: 'Yesterday',
      icon: Icons.check_circle_rounded,
      iconBg: Color(0xFFEBFAF8),
      iconColor: Color(0xFF00A896),
      isRead: true,
    ),
    const _NotificationItem(
      title: 'Streak Milestone',
      body: 'You\'ve maintained a 7-day learning streak. Keep it up!',
      time: 'Yesterday',
      icon: Icons.local_fire_department_rounded,
      iconBg: Color(0xFFFFF0F2),
      iconColor: Color(0xFFE8637A),
      isRead: true,
    ),
    const _NotificationItem(
      title: 'Module Completed',
      body: 'You completed Module 2 of Cloud Computing Basics. Module 3 is unlocked.',
      time: '2 days ago',
      icon: Icons.menu_book_rounded,
      iconBg: Color(0xFFF0EDFF),
      iconColor: _kPurple,
      isRead: true,
    ),
    const _NotificationItem(
      title: 'Weekly Progress Report',
      body: 'You studied 4.5 hours this week and completed 2 assignments.',
      time: '3 days ago',
      icon: Icons.auto_graph_rounded,
      iconBg: Color(0xFFEBFAF8),
      iconColor: Color(0xFF00A896),
      isRead: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _markAllRead() {
    setState(() {
      // In a real app this would update Firestore
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unread = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF5A4FCF)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: _kDeep,
          ),
        ),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: _markAllRead,
              child: Text(
                'Mark all read',
                style: GoogleFonts.poppins(
                  color: _kPurple,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
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
            opacity: _fadeAnim,
            child: _notifications.isEmpty
                ? _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _NotificationCard(
                        item: _notifications[index],
                        delayMs: 40 * index,
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatefulWidget {
  const _NotificationCard({required this.item, required this.delayMs});
  final _NotificationItem item;
  final int delayMs;

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: item.isRead
                ? null
                : Border.all(color: _kPurple.withValues(alpha: 0.25), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: item.iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: item.iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _kDeep,
                            ),
                          ),
                        ),
                        if (!item.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: _kPurple,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.body,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: _kDeep.withValues(alpha: 0.6),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.time,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFFBDBDBD),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _kPurple.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.notifications_off_rounded,
                size: 38, color: _kPurple),
          ),
          const SizedBox(height: 20),
          Text(
            'No notifications yet',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _kDeep,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'You\'re all caught up!',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: _kDeep.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}
