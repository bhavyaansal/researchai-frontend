import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../services/api_service.dart';
import '../services/download_helper.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/custom_toast.dart';
import '../widgets/skeleton_loader.dart';

class ReportsHistoryScreen extends StatefulWidget {
  final ApiService apiService;
  final String userEmail;
  final ValueChanged<String> onViewReport;

  const ReportsHistoryScreen({
    super.key,
    required this.apiService,
    required this.userEmail,
    required this.onViewReport,
  });

  @override
  State<ReportsHistoryScreen> createState() => _ReportsHistoryScreenState();
}

class _ReportsHistoryScreenState extends State<ReportsHistoryScreen> {
  List<JobModel> _jobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  Future<void> _fetchJobs() async {
    try {
      final jobs = await widget.apiService.listJobs();
      if (!mounted) return;
      setState(() {
        _jobs = jobs;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showDownloadModal(JobModel job) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 440,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard(context),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.borderSubtle(context)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.download_rounded,
                      color: AppColors.accentGreen(context),
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Download Document Files',
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Select file format to download for "${job.filename}":',
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 20),

                // Choice 1: Plagiarism Report
                _buildDownloadChoiceCard(
                  context,
                  title: 'Plagiarism Report (.txt)',
                  description: 'Detailed analysis log with match scores and source URLs.',
                  icon: Icons.analytics_rounded,
                  iconColor: AppColors.accentBlue(context),
                  onTap: () async {
                    Navigator.pop(context);
                    try {
                      final content = await widget.apiService.downloadReportFile(job.id);
                      await DownloadHelper.downloadFile(
                        '${job.filename}_plagiarism_report.txt',
                        content,
                      );
                      if (context.mounted) {
                        CustomToast.show(
                          context,
                          title: 'Report Downloaded',
                          message: 'Plagiarism report saved successfully.',
                          type: ToastType.success,
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        CustomToast.show(
                          context,
                          title: 'Download Failed',
                          message: e.toString(),
                          type: ToastType.error,
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 12),

                // Choice 2: Polished Document
                _buildDownloadChoiceCard(
                  context,
                  title: 'Polished Document (.pdf)', // Updated extension label
                  description: 'Clean rewritten version verified with 0% similarity.',
                  icon: Icons.task_alt_rounded,
                  iconColor: AppColors.accentGreen(context),
                  onTap: () async {
                    Navigator.pop(context);
                    try {
                      final bytes = await widget.apiService.downloadRewrittenFile(job.id);
                      await DownloadHelper.downloadBytes(
                        '${job.filename}_rewritten.pdf',
                        bytes,
                        );
                      if (context.mounted) {
                        CustomToast.show(
                          context,
                          title: 'Document Downloaded',
                          message: 'Polished document saved successfully.',
                          type: ToastType.success,
                          );
                          }
                    } catch (e) {
                      if (context.mounted) {
                        CustomToast.show(
                          context,
                          title: 'Download Failed',
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
        );
      },
    );
  }

  Widget _buildDownloadChoiceCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated(context),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.borderSubtle(context)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.download_sharp, size: 18, color: AppColors.textSecondary(context)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen Title + Subtitle
            Text(
              'Reports History',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'View and manage all previous document scans',
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),

            // Similarity Trend Mini Sparkline Chart
            if (_jobs.isNotEmpty) ...[
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.show_chart_rounded,
                          size: 18,
                          color: AppColors.accentGreen(context),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Similarity Trend Sparkline',
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 80,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _jobs.asMap().entries.map((e) {
                                final score = (e.value.globalSimilarityScore ?? 0.2) * 100;
                                return FlSpot(e.key.toDouble(), score);
                              }).toList(),
                              isCurved: true,
                              color: AppColors.accentGreen(context),
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppColors.accentGreen(context).withValues(alpha: 0.12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Content Area: Loading / Empty / Job List
            if (_isLoading) ...[
              const Column(
                children: [
                  SkeletonLoader(height: 80, margin: EdgeInsets.only(bottom: 12)),
                  SkeletonLoader(height: 80, margin: EdgeInsets.only(bottom: 12)),
                  SkeletonLoader(height: 80, margin: EdgeInsets.only(bottom: 12)),
                ],
              ),
            ] else if (_jobs.isEmpty) ...[
              GlassCard(
                padding: const EdgeInsets.all(48),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated(context),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.borderSubtle(context)),
                        ),
                        child: const Icon(
                          Icons.folder_open_rounded,
                          size: 44,
                          color: Color(0xFF4A4A7A),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No reports yet',
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Upload your first document to generate plagiarism reports.',
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _jobs.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final job = _jobs[index];
                  final score = (job.globalSimilarityScore ?? 0.0) * 100;
                  final leftBarColor = AppColors.scoreColor(score);
                  final dt = job.createdAt;
                  final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
                  final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
                  final ampm = dt.hour >= 12 ? 'PM' : 'AM';
                  final dateStr = '${months[dt.month - 1]} ${dt.day}, ${dt.year} • $hour:${dt.minute.toString().padLeft(2, '0')} $ampm';

                  return GlassCard(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: isMobile ? 14 : 16),
                    child: isMobile
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: leftBarColor,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceElevated(context),
                                      borderRadius: BorderRadius.circular(AppRadius.md),
                                    ),
                                    child: Icon(
                                      Icons.description_rounded,
                                      color: AppColors.accentBlue(context),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          job.filename,
                                          style: TextStyle(
                                            color: AppColors.textPrimary(context),
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          dateStr,
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
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: leftBarColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(AppRadius.pill),
                                      border: Border.all(color: leftBarColor.withValues(alpha: 0.4)),
                                    ),
                                    child: Text(
                                      '${score.toInt()}% Similarity',
                                      style: TextStyle(
                                        color: leftBarColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (score > 10) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentGreen(context).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(AppRadius.pill),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.arrow_downward_rounded,
                                              size: 11, color: AppColors.accentGreen(context)),
                                          const SizedBox(width: 2),
                                          Text(
                                            '↓ from 45%',
                                            style: TextStyle(
                                              color: AppColors.accentGreen(context),
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => widget.onViewReport(job.id),
                                      child: const Text('View'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: GradientButton(
                                      text: 'Download',
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      onPressed: () => _showDownloadModal(job),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              // Left Colored Indicator Bar
                              Container(
                                width: 4,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: leftBarColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // File Icon
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceElevated(context),
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                                child: Icon(
                                  Icons.description_rounded,
                                  color: AppColors.accentBlue(context),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Filename & Date
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      job.filename,
                                      style: TextStyle(
                                        color: AppColors.textPrimary(context),
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      dateStr,
                                      style: TextStyle(
                                        color: AppColors.textSecondary(context),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Similarity Score Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: leftBarColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(AppRadius.pill),
                                  border: Border.all(color: leftBarColor.withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  '${score.toInt()}% Similarity',
                                  style: TextStyle(
                                    color: leftBarColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Score History Badge
                              if (score > 10)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentGreen(context).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(AppRadius.pill),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.arrow_downward_rounded,
                                          size: 12, color: AppColors.accentGreen(context)),
                                      const SizedBox(width: 2),
                                      Text(
                                        '↓ from 45%',
                                        style: TextStyle(
                                          color: AppColors.accentGreen(context),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(width: 16),

                              // Actions
                              OutlinedButton(
                                onPressed: () => widget.onViewReport(job.id),
                                child: const Text('View'),
                              ),
                              const SizedBox(width: 8),
                              GradientButton(
                                text: 'Download ▼',
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                onPressed: () => _showDownloadModal(job),
                              ),
                            ],
                          ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
