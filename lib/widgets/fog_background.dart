import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FogBackground extends StatefulWidget {
  final Widget child;
  const FogBackground({super.key, required this.child});

  @override
  State<FogBackground> createState() => _FogBackgroundState();
}

class _FogBackgroundState extends State<FogBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _FogPainter(progress: _controller.value),
          child: widget.child,
        );
      },
    );
  }
}

class _FogPainter extends CustomPainter {
  final double progress;
  _FogPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Subtle top-right cyan ambient
    final fog1Center = Offset(
      size.width * 0.85 + sin(progress * pi) * 60,
      size.height * 0.1 + cos(progress * pi) * 30,
    );
    final fog1Radius = size.width * 0.55;
    final fog1Paint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.darkAccentGreen.withValues(alpha: 0.06),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: fog1Center, radius: fog1Radius));
    canvas.drawCircle(fog1Center, fog1Radius, fog1Paint);

    // Very subtle bottom-left purple ambient
    final fog2Center = Offset(
      size.width * 0.15 - sin(progress * pi) * 40,
      size.height * 0.85 + cos(progress * pi) * 30,
    );
    final fog2Radius = size.width * 0.45;
    final fog2Paint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.darkAccentPurple.withValues(alpha: 0.10),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: fog2Center, radius: fog2Radius));
    canvas.drawCircle(fog2Center, fog2Radius, fog2Paint);
  }

  @override
  bool shouldRepaint(covariant _FogPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
