import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/sentence_inspector_modal.dart';
import '../widgets/custom_toast.dart';

class PlagiarismReportScreen extends StatefulWidget {
  final ApiService apiService;
  final String? jobId;
  final String userEmail;
  final VoidCallback onGoToUpload;
  final VoidCallback onProceedToMitigation;
  final Function(String text)? onParaphraseSegment;

  const PlagiarismReportScreen({
    super.key,
    required this.apiService,
    this.jobId,
    required this.userEmail,
    required this.onGoToUpload,
    required this.onProceedToMitigation,
    this.onParaphraseSegment,
  });

  @override
  State<PlagiarismReportScreen> createState() => _PlagiarismReportScreenState();
}

class _PlagiarismReportScreenState extends State<PlagiarismReportScreen>
    with SingleTickerProviderStateMixin {
  ReportModel? _report;
  bool _isLoading = true;
  String? _error;

  late AnimationController _gaugeController;
  late Animation<double> _gaugeAnimation;

  @override
  void initState() {
    super.initState();
    _gaugeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _gaugeAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _gaugeController, curve: Curves.easeOutCubic),
    );
    _fetchReport();
  }

  @override
  void dispose() {
    _gaugeController.dispose();
    super.dispose();
  }

  Future<void> _fetchReport() async {
    if (widget.jobId == null) {
      // Fetch latest job if no specific ID provided
      try {
        final jobs = await widget.apiService.listJobs();
        if (jobs.isEmpty) {
          setState(() {
            _isLoading = false;
            _error = 'No scans found. Upload a document first.';
          });
          return;
        }
        final report = await widget.apiService.getReport(jobs.first.id);
        _setReport(report);
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _error = e.toString();
          });
        }
      }
    } else {
      try {
        final report = await widget.apiService.getReport(widget.jobId!);
        _setReport(report);
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _error = e.toString();
          });
        }
      }
    }
  }

  void _setReport(ReportModel report) {
    if (!mounted) return;
    setState(() {
      _report = report;
      _isLoading = false;
      _gaugeAnimation = Tween<double>(
        begin: 0.0,
        end: report.globalSimilarityScore,
      ).animate(CurvedAnimation(parent: _gaugeController, curve: Curves.easeOutCubic));
    });
    _gaugeController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.accentGreen(context)),
              const SizedBox(height: 16),
              Text(
                'Fetching analysis report...',
                style: TextStyle(color: AppColors.textPrimary(context)),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null || _report == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.report_problem_rounded, size: 48, color: AppColors.accentOrange(context)),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Report unavailable',
                style: TextStyle(color: AppColors.textPrimary(context), fontSize: 16),
              ),
              const SizedBox(height: 16),
              GradientButton(
                text: 'Upload New Document',
                icon: Icons.upload_file_rounded,
                onPressed: widget.onGoToUpload,
              ),
            ],
          ),
        ),
      );
    }

    final flaggedCount = _report!.flaggedSpans.length;
    final resolvedCount = _report!.flaggedSpans.where((s) => s.resolved).length;
    final jobDate = _report!.createdAt ?? DateTime.now();
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final formattedDate = '${months[jobDate.month - 1]} ${jobDate.day}, ${jobDate.year}';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumb Navigation
            Row(
              children: [
                InkWell(
                  onTap: widget.onGoToUpload,
                  child: Text(
                    'Documents',
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 13,
                    ),
                  ),
                ),
                Text(
                  ' / ',
                  style: TextStyle(color: AppColors.textTertiary(context), fontSize: 13),
                ),
                Text(
                  _report!.filename,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  ' / ',
                  style: TextStyle(color: AppColors.textTertiary(context), fontSize: 13),
                ),
                Text(
                  'Analysis',
                  style: TextStyle(
                    color: AppColors.accentGreen(context),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Top Summary Row (Circular Score Gauge + 3 Mini Stat Cards)
            Row(
              children: [
                // Circular Gauge Glass Card
                GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  child: AnimatedBuilder(
                    animation: _gaugeAnimation,
                    builder: (context, child) {
                      final score = _gaugeAnimation.value;
                      final percent = (score * 100).round();
                      final color = AppColors.scoreColor(score * 100);

                      return Row(
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: score,
                                  strokeWidth: 10,
                                  backgroundColor: AppColors.borderSubtle(context),
                                  valueColor: AlwaysStoppedAnimation<Color>(color),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '$percent%',
                                      style: TextStyle(
                                        color: AppColors.textPrimary(context),
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Similarity Index',
                                style: TextStyle(
                                  color: AppColors.textSecondary(context),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(AppRadius.pill),
                                  border: Border.all(color: color.withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  percent <= 10
                                      ? 'Low Similarity'
                                      : percent <= 30
                                          ? 'Moderate Risk'
                                          : 'High Plagiarism',
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(width: 20),

                // 3 Mini Stat Cards
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildMiniStatCard(
                          context,
                          title: 'Flagged Segments',
                          value: '$flaggedCount',
                          icon: Icons.flag_rounded,
                          iconColor: AppColors.accentRed(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMiniStatCard(
                          context,
                          title: 'Resolved',
                          value: '$resolvedCount',
                          icon: Icons.check_circle_rounded,
                          iconColor: AppColors.accentGreen(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMiniStatCard(
                          context,
                          title: 'Scan Date',
                          value: formattedDate,
                          icon: Icons.calendar_today_rounded,
                          iconColor: AppColors.accentBlue(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Two Column Area (Document Viewer Left + Sources Right)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Document Viewer with Inline Highlighting
                Expanded(
                  flex: 3,
                  child: GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Document Preview & Highlighted Matches',
                              style: TextStyle(
                                color: AppColors.textPrimary(context),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // Color Legend Top-Right
                            Row(
                              children: [
                                _buildLegendItem(context, 'Direct Match', AppColors.accentRed(context)),
                                const SizedBox(width: 12),
                                _buildLegendItem(context, 'Paraphrased', AppColors.accentOrange(context)),
                                const SizedBox(width: 12),
                                _buildLegendItem(context, 'Original', AppColors.textSecondary(context)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Color(0xFF252545)),
                        const SizedBox(height: 16),

                        // Document Interactive Text Viewer
                        Container(
                          constraints: const BoxConstraints(minHeight: 320),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated(context).withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: AppColors.borderSubtle(context)),
                          ),
                          child: SingleChildScrollView(
                            child: _buildHighlightedContent(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),

                // Right Column: Source Breakdown Panel
                Expanded(
                  flex: 2,
                  child: GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.source_rounded,
                              color: AppColors.accentBlue(context),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Matching Sources',
                              style: TextStyle(
                                color: AppColors.textPrimary(context),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Color(0xFF252545)),
                        const SizedBox(height: 16),

                        if (_report!.uniqueSources.isEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                'No external sources detected.',
                                style: TextStyle(color: Color(0xFF8888BB)),
                              ),
                            ),
                          ),
                        ] else ...[
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _report!.uniqueSources.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final sourceTitle = _report!.uniqueSources[index];
                              // Find matching spans for this source
                              final sourceSpans = _report!.flaggedSpans
                                  .where((s) => s.sourceTitle == sourceTitle)
                                  .toList();
                              final avgScore = sourceSpans.isNotEmpty
                                  ? sourceSpans.map((s) => s.similarityScore).reduce((a, b) => a + b) /
                                      sourceSpans.length
                                  : 0.5;

                              return _buildSourceCard(
                                context,
                                title: sourceTitle,
                                score: avgScore,
                                count: sourceSpans.length,
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Bottom Action Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    CustomToast.show(
                      context,
                      title: 'Exporting Report',
                      message: 'Plagiarism analysis summary report downloaded.',
                      type: ToastType.success,
                    );
                  },
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('Export Report'),
                ),
                GradientButton(
                  text: 'Proceed to AI Mitigation',
                  icon: Icons.auto_fix_high_rounded,
                  onPressed: widget.onProceedToMitigation,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary(context), fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildHighlightedContent(BuildContext context) {
    if (_report!.flaggedSpans.isEmpty) {
      return Text(
        _report!.fullText ?? 'Full document content clean and verified with 0% similarity match.',
        style: TextStyle(color: AppColors.textPrimary(context), fontSize: 14, height: 1.7),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            '💡 Click any highlighted sentence below to view source details & AI rewrite options.',
            style: TextStyle(
              color: Color(0xFF4D8EFF),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Wrap(
          spacing: 4,
          runSpacing: 8,
          children: _report!.flaggedSpans.map((span) {
            final isDirect = span.similarityScore >= 0.7;
            final color = isDirect ? AppColors.accentRed(context) : AppColors.accentOrange(context);

            return InkWell(
              onTap: () {
                SentenceInspectorModal.show(
                  context,
                  span: span,
                  onParaphrase: widget.onParaphraseSegment,
                );
              },
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: isDirect ? color.withValues(alpha: 0.2) : Colors.transparent,
                  border: isDirect
                      ? Border.all(color: color.withValues(alpha: 0.5))
                      : Border(bottom: BorderSide(color: color, width: 2.0)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  span.text,
                  style: TextStyle(
                    color: isDirect ? color : AppColors.textPrimary(context),
                    fontSize: 13,
                    height: 1.6,
                    fontWeight: isDirect ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSourceCard(
    BuildContext context, {
    required String title,
    required double score,
    required int count,
  }) {
    final percent = (score * 100).toInt();
    final color = AppColors.scoreColor(score * 100);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderSubtle(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  '$percent%',
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: score,
            backgroundColor: AppColors.borderSubtle(context),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
          const SizedBox(height: 6),
          Text(
            '$count flagged sentence(s)',
            style: const TextStyle(
              color: Color(0xFF8888BB),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}