import 'package:flutter/material.dart';
import '../../shared/widgets/app_logo.dart';

import 'auth_choice_screen.dart';
import 'login_screen.dart';
import 'widgets/auth_shell.dart';
import 'widgets/primary_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  bool _visible = false;
  late final AnimationController _cloudController;
  late final Animation<double> _cloudOffset;

  @override
  void initState() {
    super.initState();
    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
    _cloudOffset = Tween<double>(begin: -4, end: 6).animate(
      CurvedAnimation(parent: _cloudController, curve: Curves.easeOutCubic),
    );

    Future<void>.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  void dispose() {
    _cloudController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          offset: _visible ? Offset.zero : const Offset(0, 0.03),
          child: GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _cloudOffset,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _cloudOffset.value),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 210,
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEEDFFF), Color(0xFFD2B7FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5931BB).withValues(alpha: 0.22),
                          blurRadius: 28,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const AppLogo(
                      width: 176,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Welcome to CloudLearn',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF291451),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Master cloud concepts with elegant, project-first learning paths.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF291451).withValues(alpha: 0.62),
                    fontSize: 14.5,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 36),
                PrimaryButton(
                  label: 'Get Started',
                  onPressed: () {
                    Navigator.of(context).push(
                      buildAuthRoute(const AuthChoiceScreen()),
                    );
                  },
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      buildAuthRoute(const LoginScreen()),
                    );
                  },
                  child: Text(
                    'Already have an account? Log In',
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF3D2082).withValues(alpha: 0.82),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
