import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final name = user?.displayName?.split(' ').first ?? 'Learner';

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEEE9FF), Color(0xFFD9D4FF), Color(0xFFC9C3FF)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back,',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF2D1A4D).withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF7C6CF6),
                ),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.1,
                  children: const [
                    _DashCard(
                      icon: Icons.school_rounded,
                      label: 'My Courses',
                      iconColor: Color(0xFF7C6CF6),
                      bgColor: Color(0xFFF0EDFF),
                    ),
                    _DashCard(
                      icon: Icons.emoji_events_rounded,
                      label: 'Achievements',
                      iconColor: Color(0xFFE8A020),
                      bgColor: Color(0xFFFFF8EC),
                    ),
                    _DashCard(
                      icon: Icons.people_alt_rounded,
                      label: 'Community',
                      iconColor: Color(0xFF00A896),
                      bgColor: Color(0xFFEBFAF8),
                    ),
                    _DashCard(
                      icon: Icons.settings_rounded,
                      label: 'Settings',
                      iconColor: Color(0xFF9E9E9E),
                      bgColor: Color(0xFFF5F5F5),
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

class _DashCard extends StatelessWidget {
  const _DashCard({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.bgColor,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: const Color(0xFF2D1A4D),
            ),
          ),
        ],
      ),
    );
  }
}
