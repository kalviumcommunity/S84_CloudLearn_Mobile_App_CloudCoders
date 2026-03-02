import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.height = 52,
    this.borderRadius = 24,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;
  final double borderRadius;


class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  double _scale = 1;

  void _onTapDown(TapDownDetails _) {
    if (widget.onPressed == null || widget.isLoading) return;
    setState(() => _scale = 0.97);
  }

  void _onTapEnd([Object? _]) {
    if (!mounted) return;
    setState(() => _scale = 1);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: (_) => _onTapEnd(),
      onTapCancel: _onTapEnd,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        scale: _scale,
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF8B5CF6),
                Color(0xFF6D28D9),
              ],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3322164A),
                blurRadius: 22,
                offset: Offset(0, 10),
  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: SizedBox(
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7C5CFF), Color(0xFF5E7BFF)],
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C5CFF).withValues(alpha: 0.28),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              onTap: widget.isLoading ? null : widget.onPressed,
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        widget.text,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              borderRadius: BorderRadius.circular(26),
              onTap: widget.isLoading ? null : widget.onPressed,
              onTapDown: widget.isLoading
                  ? null
                  : (_) => setState(() => _scale = 0.98),
              onTapCancel: widget.isLoading
                  ? null
                  : () => setState(() => _scale = 1),
              onTapUp: widget.isLoading
                  ? null
                  : (_) => setState(() => _scale = 1),
              child: SizedBox(
                height: 58,
                child: Center(
                  child: widget.isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          widget.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
