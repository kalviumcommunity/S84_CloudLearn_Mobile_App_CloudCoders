import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  bool _loading = false;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _resendVerificationEmail() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await _authService.resendVerificationEmail();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email sent. Check your inbox.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _iHaveVerified() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final verified = await _authService.isCurrentUserEmailVerified();
      if (!mounted) return;
      if (!verified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Email not verified yet. Please check your inbox.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = _authService.currentUser?.email ?? 'your email';

    return Scaffold(
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
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7C6CF6).withValues(alpha: 0.2),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.mark_email_unread_rounded,
                          size: 48,
                          color: Color(0xFF7C6CF6),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Title
                      Text(
                        'Verify your email',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2D1A4D),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Subtitle
                      Text(
                        'We sent a verification link to\n$email\nPlease verify your email to continue.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF2D1A4D).withValues(alpha: 0.55),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Resend button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _loading ? null : _resendVerificationEmail,
                          icon: const Icon(Icons.send_rounded, size: 18),
                          label: Text(
                            'Resend verification email',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF7C6CF6),
                            side: const BorderSide(
                                color: Color(0xFF7C6CF6), width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // I have verified button
                      SizedBox(
                        width: double.infinity,
                        child: _loading
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFF7C6CF6)))
                            : DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF7C6CF6),
                                      Color(0xFF5A4FCF)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x447C6CF6),
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _iHaveVerified,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                  ),
                                  child: Text(
                                    'I have verified',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),

                      // Use another account
                      TextButton(
                        onPressed: _loading ? null : _authService.signOut,
                        child: Text(
                          'Use another account',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF7C6CF6).withValues(alpha: 0.7),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
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
      ),
    );
  }
}
