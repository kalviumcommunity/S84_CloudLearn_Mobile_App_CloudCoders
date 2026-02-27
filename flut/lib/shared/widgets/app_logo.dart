import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.width = 220,
    this.height,
    this.fit = BoxFit.contain,
  });

  final double width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/Gemini_Generated_Image_9v54319v54319v54.png',
      width: width,
      height: height,
      fit: fit,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, _, __) {
        return const Icon(
          Icons.cloud_queue_rounded,
          size: 56,
          color: Color(0xFF5F38CC),
        );
      },
    );
  }
}
