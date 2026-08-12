import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AiryLogo extends StatefulWidget {
  final bool showText;
  final double size;

  const AiryLogo({
    super.key,
    this.showText = true,
    this.size = 32,
  });

  @override
  State<AiryLogo> createState() => _AiryLogoState();
}

class _AiryLogoState extends State<AiryLogo> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentGreen = AppColors.accentGreen(context);
    final accentPurple = AppColors.accentPurple(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: SweepGradient(
                  transform: GradientRotation(_controller.value * 6.28),
                  colors: [
                    accentGreen,
                    accentPurple,
                    const Color(0xFF00E5B0),
                    accentGreen,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentGreen.withValues(alpha: 0.35),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgDeep(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: accentGreen,
                      size: widget.size * 0.55,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.showText) ...[
          const SizedBox(width: 10),
          RichText(
            text: TextSpan(
              style: GoogleFonts.spaceGrotesk(
                fontSize: widget.size * 0.65,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
              children: [
                TextSpan(
                  text: 'Research',
                  style: TextStyle(color: AppColors.textPrimary(context)),
                ),
                TextSpan(
                  text: 'AI',
                  style: TextStyle(
                    color: accentGreen,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
