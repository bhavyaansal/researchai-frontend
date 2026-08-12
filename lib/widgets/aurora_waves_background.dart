import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AuroraWavesBackground extends StatefulWidget {
  final Widget child;

  const AuroraWavesBackground({
    super.key,
    required this.child,
  });

  @override
  State<AuroraWavesBackground> createState() => _AuroraWavesBackgroundState();
}

class _AuroraWavesBackgroundState extends State<AuroraWavesBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_StardustParticle> _particles = [];
  final Random _random = Random();
  Offset? _mousePosition;

  static const int _particleCount = 35;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(_onTick)..repeat();
  }

  void _onTick() {
    if (!mounted) return;
    final size = MediaQuery.of(context).size;
    if (size.width == 0 || size.height == 0) return;

    if (_particles.isEmpty) {
      for (int i = 0; i < _particleCount; i++) {
        _particles.add(_createParticle(size));
      }
    }

    for (final p in _particles) {
      p.x += p.vx * p.speedMultiplier;
      p.y += p.vy * p.speedMultiplier;

      if (_mousePosition != null) {
        final dx = p.x - _mousePosition!.dx;
        final dy = p.y - _mousePosition!.dy;
        final dist = sqrt(dx * dx + dy * dy);
        if (dist < 150) {
          final force = (1.0 - (dist / 150)) * 0.5;
          p.x += (dx / dist) * force * 2.0;
          p.y += (dy / dist) * force * 2.0;
        }
      }

      if (p.x < -20 || p.x > size.width + 20 || p.y < -20 || p.y > size.height + 20) {
        final newP = _createParticle(size);
        p.x = newP.x;
        p.y = newP.y;
        p.vx = newP.vx;
        p.vy = newP.vy;
        p.radius = newP.radius;
        p.opacity = newP.opacity;
        p.speedMultiplier = newP.speedMultiplier;
      }
    }

    setState(() {});
  }

  _StardustParticle _createParticle(Size size) {
    final initialSetup = _particles.isEmpty;
    final double x = initialSetup ? _random.nextDouble() * size.width : 0.0;
    final double y = initialSetup ? _random.nextDouble() * size.height : _random.nextDouble() * size.height;

    return _StardustParticle(
      x: x,
      y: y,
      vx: _random.nextDouble() * 0.4 + 0.1,
      vy: (_random.nextDouble() - 0.5) * 0.2,
      radius: _random.nextDouble() * 1.5 + 0.8,
      opacity: _random.nextDouble() * 0.4 + 0.1,
      speedMultiplier: _random.nextDouble() * 0.8 + 0.4,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) => setState(() => _mousePosition = event.position),
      onExit: (_) => setState(() => _mousePosition = null),
      child: Stack(
        children: [
          Container(color: AppColors.bgDeep(context)),
          Positioned.fill(
            child: CustomPaint(
              painter: _AuroraWavesPainter(
                progress: _controller.value,
                particles: _particles,
                context: context,
              ),
            ),
          ),
          Positioned.fill(
            child: const _GridOverlay(),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.bgDeep(context).withValues(alpha: 0.8),
                    ],
                    radius: 1.4,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(child: widget.child),
        ],
      ),
    );
  }
}

class _StardustParticle {
  double x;
  double y;
  double vx;
  double vy;
  double radius;
  double opacity;
  double speedMultiplier;

  _StardustParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.opacity,
    required this.speedMultiplier,
  });
}

class _AuroraWavesPainter extends CustomPainter {
  final double progress;
  final List<_StardustParticle> particles;
  final BuildContext context;

  _AuroraWavesPainter({
    required this.progress,
    required this.particles,
    required this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;

    final double t = progress * 2 * pi;

    final waveConfigs = [
      _WaveConfig(
        frequency: 0.003,
        amplitude: 65,
        speed: 0.8,
        phaseOffset: 0.0,
        verticalRatio: 0.65,
        colors: [
          AppColors.accentBlue(context).withValues(alpha: 0.16),
          AppColors.accentBlue(context).withValues(alpha: 0.05),
          Colors.transparent,
        ],
      ),
      _WaveConfig(
        frequency: 0.002,
        amplitude: 80,
        speed: -0.5,
        phaseOffset: pi / 3,
        verticalRatio: 0.55,
        colors: [
          AppColors.accentPurple(context).withValues(alpha: 0.14),
          AppColors.accentRed(context).withValues(alpha: 0.03),
          Colors.transparent,
        ],
      ),
      _WaveConfig(
        frequency: 0.004,
        amplitude: 45,
        speed: 1.1,
        phaseOffset: 2 * pi / 3,
        verticalRatio: 0.72,
        colors: [
          AppColors.accentGreen(context).withValues(alpha: 0.15),
          AppColors.accentBlue(context).withValues(alpha: 0.04),
          Colors.transparent,
        ],
      ),
    ];

    for (final wave in waveConfigs) {
      final path = Path();
      final double baseline = size.height * wave.verticalRatio;
      final double phase = t * wave.speed + wave.phaseOffset;

      path.moveTo(0, baseline + sin(phase) * wave.amplitude);
      for (double x = 0; x <= size.width; x += 15) {
        final double y = baseline + sin(x * wave.frequency + phase) * wave.amplitude;
        path.lineTo(x, y);
      }
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();

      final Rect shaderRect = Rect.fromLTRB(
        0,
        baseline - wave.amplitude,
        size.width,
        size.height,
      );

      final paint = Paint()
        ..shader = LinearGradient(
          colors: wave.colors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(shaderRect)
        ..style = PaintingStyle.fill;

      canvas.drawPath(path, paint);
    }

    final particlePaint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      particlePaint.color = Colors.white.withValues(alpha: p.opacity);
      canvas.drawCircle(Offset(p.x, p.y), p.radius, particlePaint);

      if (p.opacity > 0.3) {
        final glowPaint = Paint()
          ..color = AppColors.accentBlue(context).withValues(alpha: p.opacity * 0.3)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(Offset(p.x, p.y), p.radius * 2.5, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AuroraWavesPainter oldDelegate) {
    return true;
  }
}

class _WaveConfig {
  final double frequency;
  final double amplitude;
  final double speed;
  final double phaseOffset;
  final double verticalRatio;
  final List<Color> colors;

  _WaveConfig({
    required this.frequency,
    required this.amplitude,
    required this.speed,
    required this.phaseOffset,
    required this.verticalRatio,
    required this.colors,
  });
}

class _GridOverlay extends StatelessWidget {
  const _GridOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _GridPainter(context: context),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final BuildContext context;

  _GridPainter({required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.borderSubtle(context).withValues(alpha: 0.12)
      ..strokeWidth = 0.5;

    const spacing = 65.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => false;
}
