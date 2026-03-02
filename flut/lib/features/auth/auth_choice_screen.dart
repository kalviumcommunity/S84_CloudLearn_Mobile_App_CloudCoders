import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'signup_screen.dart';
import 'widgets/primary_button.dart';
import 'widgets/secondary_button.dart';

class AuthChoiceScreen extends StatefulWidget {
  const AuthChoiceScreen({super.key});

  @override
  State<AuthChoiceScreen> createState() => _AuthChoiceScreenState();
}

class _AuthChoiceScreenState extends State<AuthChoiceScreen> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 60), () {
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
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOut,
                  child: SizedBox(
                    width: maxWidth,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Create your account',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2F1F64),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Save your progress, track cloud modules, and continue learning anywhere.',
                              style: TextStyle(
                                color: Color(0xFF625B71),
                              ),
                            ),
                            const SizedBox(height: 26),
                            PrimaryButton(
                              label: 'Log In',
                              onPressed: () {
                                Navigator.of(context).push(
                                  _fadeRoute(const LoginScreen()),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            SecondaryButton(
                              label: 'Sign Up',
                              onPressed: () {
                                Navigator.of(context).push(
                                  _fadeRoute(const SignupScreen()),
                                );
                              },
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
