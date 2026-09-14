import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../services/api_service.dart';
import '../services/download_helper.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/custom_toast.dart';

class FinalReportScreen extends StatelessWidget {
  final ReportModel report;
  final ApiService apiService;
  final VoidCallback onViewSimilarityReport;

  const FinalReportScreen({
    super.key,
    required this.report,
    required this.apiService,
    required this.onViewSimilarityReport,
  });

  @override
  Widget build(BuildContext context) {
    final score = report.globalSimilarityScore * 100;
    final isClean = score <= 10.0;
    final bannerColor = isClean ? AppColors.accentGreen(context) : AppColors.accentOrange(context);
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Verification Banner
            GlassCard(
              borderColor: bannerColor.withValues(alpha: 0.6),
              glowColor: bannerColor.withValues(alpha: 0.25),
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: bannerColor.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isClean ? Icons.verified_rounded : Icons.gpp_maybe_rounded,
                                color: bannerColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isClean
                                    ? 'Verified Clean — ${score.toInt()}% Final Similarity'
                                    : 'Mitigation Notice — ${score.toInt()}% Similarity Remaining',
                                style: TextStyle(
                                  color: AppColors.textPrimary(context),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          isClean
                              ? 'This document has successfully passed AI mitigation standards and is verified safe for submission.'
                              : 'Additional manual review recommended for remaining flagged phrases.',
                          style: TextStyle(
                            color: AppColors.textSecondary(context),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: onViewSimilarityReport,
                            icon: const Icon(Icons.analytics_rounded, size: 16),
                            label: const Text('View Similarity Report →'),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: bannerColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isClean ? Icons.verified_rounded : Icons.gpp_maybe_rounded,
                            color: bannerColor,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isClean
                                    ? 'Verified Clean — ${score.toInt()}% Final Similarity'
                                    : 'Mitigation Notice — ${score.toInt()}% Similarity Remaining',
                                style: TextStyle(
                                  color: AppColors.textPrimary(context),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isClean
                                    ? 'This document has successfully passed AI mitigation standards and is verified safe for submission.'
                                    : 'Additional manual review recommended for remaining flagged phrases.',
                                style: TextStyle(
                                  color: AppColors.textSecondary(context),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed: onViewSimilarityReport,
                          icon: const Icon(Icons.analytics_rounded, size: 16),
                          label: const Text('View Similarity Report →'),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 28),

            // Document Preview Card
            GlassCard(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.article_rounded, color: AppColors.accentGreen(context), size: 22),
                      const SizedBox(width: 10),
                      Text(
                        report.filename,
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen(context).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(color: AppColors.accentGreen(context).withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_rounded,
                                size: 14, color: AppColors.accentGreen(context)),
                            const SizedBox(width: 4),
                            Text(
                              '✓ Clean',
                              style: TextStyle(
                                color: AppColors.accentGreen(context),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFF252545)),
                  const SizedBox(height: 16),

                  Container(
                    constraints: const BoxConstraints(minHeight: 280),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated(context).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.borderSubtle(context)),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        report.rewrittenFullText ??
                            report.fullText ??
                            'Verified clean document text ready for export and academic submission.',
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontSize: 14,
                          height: 1.7,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Download Hub Bottom Bar
            GlassCard(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.downloading_rounded, color: Color(0xFF8888BB), size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Download Hub',
                                    style: TextStyle(
                                      color: AppColors.textPrimary(context),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Save verified clean text or diagnostic report',
                                    style: TextStyle(
                                      color: AppColors.textSecondary(context),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        GradientButton(
                          text: 'Download Polished Document',
                          icon: Icons.file_download_rounded,
                          onPressed: () async {
                            try {
                              final bytes = await apiService.downloadRewrittenFile(report.jobId);
                              await DownloadHelper.downloadBytes(
                                '${report.filename}_polished.pdf',
                                bytes,
                                );
                              if (context.mounted) {
                                CustomToast.show(
                                  context,
                                  title: 'Downloaded',
                                  message: 'Polished document saved successfully.',
                                  type: ToastType.success,
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                CustomToast.show(
                                  context,
                                  title: 'Error',
                                  message: e.toString(),
                                  type: ToastType.error,
                                );
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () async {
                            try {
                              final content = await apiService.downloadReportFile(report.jobId);
                              await DownloadHelper.downloadFile(
                                '${report.filename}_report.txt',
                                content,
                              );
                              if (context.mounted) {
                                CustomToast.show(
                                  context,
                                  title: 'Exported',
                                  message: 'Report file saved.',
                                  type: ToastType.info,
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                CustomToast.show(
                                  context,
                                  title: 'Error',
                                  message: e.toString(),
                                  type: ToastType.error,
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.assessment_rounded, size: 16),
                          label: const Text('Export Report'),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        const Icon(Icons.downloading_rounded, color: Color(0xFF8888BB), size: 24),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Download Hub',
                              style: TextStyle(
                                color: AppColors.textPrimary(context),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Save verified clean text or full diagnostic report',
                              style: TextStyle(
                                color: AppColors.textSecondary(context),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        OutlinedButton.icon(
                          onPressed: () async {
                            try {
                              final content = await apiService.downloadReportFile(report.jobId);
                              await DownloadHelper.downloadFile(
                                '${report.filename}_report.txt',
                                content,
                              );
                              if (context.mounted) {
                                CustomToast.show(
                                  context,
                                  title: 'Exported',
                                  message: 'Report file saved.',
                                  type: ToastType.info,
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                CustomToast.show(
                                  context,
                                  title: 'Error',
                                  message: e.toString(),
                                  type: ToastType.error,
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.assessment_rounded, size: 16),
                          label: const Text('Export Report'),
                        ),
                        const SizedBox(width: 16),
                        GradientButton(
                          text: 'Download Polished Document',
                          icon: Icons.file_download_rounded,
                          onPressed: () async {
                            try {
                              final bytes = await apiService.downloadRewrittenFile(report.jobId);
                              await DownloadHelper.downloadBytes(
                                '${report.filename}_polished.pdf',
                                bytes,
                              );
                              if (context.mounted) {
                                CustomToast.show(
                                  context,
                                  title: 'Downloaded',
                                  message: 'Polished document saved successfully.',
                                  type: ToastType.success,
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                CustomToast.show(
                                  context,
                                  title: 'Error',
                                  message: e.toString(),
                                  type: ToastType.error,
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}