import 'dart:ui';

import 'package:flutter/material.dart';

class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.child,
    this.maxWidth = 480,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const _AuthBackground(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final effectiveWidth = constraints.maxWidth > maxWidth
                    ? maxWidth
                    : constraints.maxWidth;

                return Center(
                  child: SingleChildScrollView(
                    padding: padding,
                    child: SizedBox(
                      width: effectiveWidth,
                      child: child,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(28),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white.withValues(alpha: 0.75),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1F1147).withValues(alpha: 0.12),
                blurRadius: 40,
                spreadRadius: 0,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

PageRouteBuilder<void> buildAuthRoute(Widget page) {
  return PageRouteBuilder<void>(
    pageBuilder: (_, animation, __) => page,
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (_, animation, __, child) {
      final fade = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.06),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      );

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

class _AuthBackground extends StatelessWidget {
  const _AuthBackground();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF6EEFF),
                Color(0xFFD7BEFF),
                Color(0xFF6D3DCC),
              ],
              stops: [0.05, 0.52, 1],
            ),
          ),
        ),
        _GradientBlob(
          alignment: Alignment(-0.8, -0.85),
          size: 260,
          colors: [Color(0xFFB48DFF), Color(0x00B48DFF)],
          opacity: 0.35,
        ),
        _GradientBlob(
          alignment: Alignment(0.95, -0.45),
          size: 220,
          colors: [Color(0xFFE9D5FF), Color(0x00E9D5FF)],
          opacity: 0.28,
        ),
        _GradientBlob(
          alignment: Alignment(0.9, 0.92),
          size: 320,
          colors: [Color(0xFF5B31B5), Color(0x005B31B5)],
          opacity: 0.34,
        ),
      ],
    );
  }
}

class _GradientBlob extends StatelessWidget {
  const _GradientBlob({
    required this.alignment,
    required this.size,
    required this.colors,
    required this.opacity,
  });

  final Alignment alignment;
  final double size;
  final List<Color> colors;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: colors),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
