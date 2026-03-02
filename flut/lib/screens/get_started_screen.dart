import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/primary_button.dart';
import 'login_screen.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Route<void> _fadeRoute(Widget page) {
    return PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF4EEFF),
              Color(0xFF7A5CB2),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x2A1E0F40),
                            blurRadius: 40,
                            offset: Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 106,
                            width: 106,
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFF2EDFF),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x266C5CE7),
                                    blurRadius: 18,
                                    spreadRadius: 1,
                                    offset: Offset(0, 0),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                clipBehavior: Clip.antiAlias,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Center(
                                    child: SizedBox(
                                      height: 78,
                                      width: 78,
                                      child: ColorFiltered(
                                        colorFilter: const ColorFilter.mode(
                                          Color(0xFF6C5CE7),
                                          BlendMode.srcIn,
                                        ),
                                        child: Image.asset(
                                          'assets/images/logo.png',
                                          fit: BoxFit.contain,
                                          alignment: Alignment.center,
                                          filterQuality: FilterQuality.high,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Center(
                                              child: Text(
                                                'CL',
                                                style: GoogleFonts.poppins(
                                                  color: const Color(0xFF6C5CE7),
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Welcome to CloudLearn',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 27,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2B1B4D),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Start learning cloud concepts with Firebase.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: const Color(0xFF2B1B4D).withValues(alpha: 0.58),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 28),
                          PrimaryButton(
                            text: 'Get Started',
                            onPressed: () {
                              Navigator.of(context).push(_fadeRoute(const LoginScreen()));
                            },
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF2B1B4D).withValues(alpha: 0.72),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(_fadeRoute(const LoginScreen()));
                                },
                                child: Text(
                                  'Log In',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF6D28D9),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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