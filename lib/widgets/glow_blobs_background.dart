import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlowBlobsBackground extends StatefulWidget {
  final Widget child;
  const GlowBlobsBackground({super.key, required this.child});

  @override
  State<GlowBlobsBackground> createState() => _GlowBlobsBackgroundState();
}

class _GlowBlobsBackgroundState extends State<GlowBlobsBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 20))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgDeep(context),
      child: Stack(children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value * 2 * math.pi;
              return CustomPaint(
                painter: _BlobPainter(t: t, context: context),
              );
            },
          ),
        ),
        widget.child,
      ]),
    );
  }
}

class _BlobPainter extends CustomPainter {
  final double t;
  final BuildContext context;

  _BlobPainter({required this.t, required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    _blob(
      canvas,
      center: Offset(
        size.width * 0.15 + math.sin(t) * 40,
        size.height * 0.2 + math.cos(t * 0.8) * 30,
      ),
      radius: size.width * 0.28,
      color: AppColors.accentGreen(context).withValues(alpha: 0.05),
    );
    _blob(
      canvas,
      center: Offset(
        size.width * 0.85 + math.cos(t * 0.6) * 50,
        size.height * 0.75 + math.sin(t * 0.7) * 40,
      ),
      radius: size.width * 0.22,
      color: AppColors.accentBlue(context).withValues(alpha: 0.04),
    );
    _blob(
      canvas,
      center: Offset(
        size.width * 0.6 + math.sin(t * 1.1) * 30,
        size.height * 0.1 + math.cos(t * 0.5) * 20,
      ),
      radius: size.width * 0.16,
      color: AppColors.accentPurple(context).withValues(alpha: 0.03),
    );
  }

  void _blob(Canvas canvas, {required Offset center, required double radius, required Color color}) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _BlobPainter oldDelegate) => oldDelegate.t != t;
}