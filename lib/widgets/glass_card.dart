import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? glowColor;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.borderColor,
    this.glowColor,
    this.borderRadius = AppRadius.lg,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bgCard = AppColors.surfaceCard(context);
    final borderDefault = widget.borderColor ?? AppColors.borderSubtle(context);
    final borderActive = widget.glowColor ?? AppColors.accentGreen(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: widget.margin,
          padding: widget.padding,
          transform: _isHovered && widget.onTap != null
              ? Matrix4.translationValues(0.0, -2.0, 0.0)
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: bgCard,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: _isHovered ? borderActive.withValues(alpha: 0.6) : borderDefault,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered && widget.glowColor != null
                    ? widget.glowColor!.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.15),
                blurRadius: _isHovered ? 16 : 8,
                spreadRadius: _isHovered ? 1 : 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
