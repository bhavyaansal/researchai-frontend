import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GradientButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final Color? textColor;
  final bool isLoading;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const GradientButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.gradient,
    this.textColor,
    this.isLoading = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
    this.borderRadius = AppRadius.md,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = widget.gradient ?? AppGradients.cyanGreen;
    final primaryColor = widget.textColor ?? const Color(0xFF060610);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onPressed != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.isLoading ? null : widget.onPressed,
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : (_isHovered ? 1.02 : 1.0),
          duration: const Duration(milliseconds: 150),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: widget.padding,
            decoration: BoxDecoration(
              gradient: effectiveGradient,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: effectiveGradient.colors.first.withValues(alpha: _isHovered ? 0.45 : 0.25),
                  blurRadius: _isHovered ? 14 : 8,
                  spreadRadius: _isHovered ? 1 : 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.isLoading) ...[
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                  const SizedBox(width: 10),
                ] else if (widget.icon != null) ...[
                  Icon(widget.icon, size: 18, color: primaryColor),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.text,
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
