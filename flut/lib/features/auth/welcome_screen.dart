import 'package:flutter/material.dart';

import 'auth_choice_screen.dart';
import 'login_screen.dart';
import 'widgets/primary_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth > 480 ? 480.0 : constraints.maxWidth;
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: AnimatedOpacity(
                  opacity: _visible ? 1 : 0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  child: SizedBox(
                    width: maxWidth,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFF2ECFF),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.07),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.cloud_queue_rounded,
                                size: 52,
                                color: Color(0xFF7A5AF8),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Welcome to CloudLearn',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2F1F64),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Start learning cloud concepts with Firebase.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF625B71),
                                fontSize: 14.5,
                              ),
                            ),
                            const SizedBox(height: 28),
                            PrimaryButton(
                              label: 'Get Started',
                              onPressed: () {
                                Navigator.of(context).push(
                                  _fadeRoute(const AuthChoiceScreen()),
                                );
                              },
                            ),
                            const SizedBox(height: 14),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  _fadeRoute(const LoginScreen()),
                                );
                              },
                              child: const Text(
                                'Already have an account? Log In',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF4A347E),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

PageRouteBuilder<void> _fadeRoute(Widget page) {
  return PageRouteBuilder<void>(
    pageBuilder: (_, animation, __) => FadeTransition(
      opacity: animation,
      child: page,
    ),
    transitionDuration: const Duration(milliseconds: 320),
  );
}
