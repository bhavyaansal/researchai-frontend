import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../theme/app_theme.dart';
import 'gradient_button.dart';

class SentenceInspectorModal extends StatelessWidget {
  final FlaggedSpanModel span;
  final Function(String text)? onParaphrase;

  const SentenceInspectorModal({
    super.key,
    required this.span,
    this.onParaphrase,
  });

  static void show(
    BuildContext context, {
    required FlaggedSpanModel span,
    Function(String text)? onParaphrase,
  }) {
    showDialog(
      context: context,
      builder: (context) => SentenceInspectorModal(
        span: span,
        onParaphrase: onParaphrase,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final matchPercent = (span.similarityScore * 100).toInt();
    final isDirect = span.similarityScore >= 0.7;
    final accentColor = isDirect ? AppColors.accentRed(context) : AppColors.accentOrange(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Container(
        width: 540,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard(context),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: accentColor.withValues(alpha: 0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.15),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(color: accentColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isDirect ? Icons.warning_rounded : Icons.find_in_page_rounded,
                        size: 14,
                        color: accentColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isDirect ? 'Direct Match ($matchPercent%)' : 'Paraphrased ($matchPercent%)',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 20),
                  color: AppColors.textSecondary(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Segment Text Box
            const Text(
              'Flagged Sentence',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: Color(0xFF8888BB),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: accentColor.withValues(alpha: 0.25)),
              ),
              child: Text(
                '"${span.text}"',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 13,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Source details
            if (span.sourceTitle != null && span.sourceTitle!.isNotEmpty) ...[
              const Text(
                'Matching Source',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Color(0xFF8888BB),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated(context),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.borderSubtle(context)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link_rounded, size: 18, color: AppColors.darkAccentBlue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            span.sourceTitle!,
                            style: TextStyle(
                              color: AppColors.textPrimary(context),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (span.sourceUrl != null && span.sourceUrl!.isNotEmpty)
                            Text(
                              span.sourceUrl!,
                              style: const TextStyle(
                                color: AppColors.darkAccentBlue,
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
                const SizedBox(width: 12),
                GradientButton(
                  text: 'Rewrite with AI',
                  icon: Icons.auto_fix_high_rounded,
                  onPressed: () {
                    Navigator.pop(context);
                    if (onParaphrase != null) {
                      onParaphrase!(span.text);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
