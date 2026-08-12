import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Shimmering progressive content skeleton loader.
class SkeletonLoader extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry margin;

  const SkeletonLoader({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.margin = EdgeInsets.zero,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = AppColors.surfaceCard(context);
    final highlightColor = AppColors.surfaceElevated(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + (_controller.value * 3.0), -0.3),
              end: Alignment(1.0 + (_controller.value * 3.0), 0.3),
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton placeholder list view for report history / cards
class SkeletonListPlaceholder extends StatelessWidget {
  final int count;
  const SkeletonListPlaceholder({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: count,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard(context),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderSubtle(context)),
          ),
          child: const Row(
            children: [
              SkeletonLoader(width: 40, height: 40, borderRadius: 8),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(width: 180, height: 14),
                    SizedBox(height: 8),
                    SkeletonLoader(width: 110, height: 10),
                  ],
                ),
              ),
              SizedBox(width: 16),
              SkeletonLoader(width: 60, height: 24, borderRadius: 6),
            ],
          ),
        );
      },
    );
  }
}
