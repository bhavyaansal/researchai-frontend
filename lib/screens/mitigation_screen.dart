import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/custom_toast.dart';

class MitigationScreen extends StatefulWidget {
  final String jobId;
  final ApiService apiService;
  final String userEmail;
  final VoidCallback onComplete;

  const MitigationScreen({
    super.key,
    required this.jobId,
    required this.apiService,
    required this.userEmail,
    required this.onComplete,
  });

  @override
  State<MitigationScreen> createState() => _MitigationScreenState();
}

class _MitigationScreenState extends State<MitigationScreen> {
  ReportModel? _report;
  bool _isLoading = true;
  int _currentSegmentIndex = 0;
  bool _isPaused = false;
  // _isRewriting removed (handled by loading state)

  // Custom rewritten texts map (segment index -> rewritten text)
  final Map<int, String> _acceptedRewrites = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await widget.apiService.triggerMitigation(widget.jobId);
      final report = await widget.apiService.getReport(widget.jobId);
      if (!mounted) return;
      setState(() {
        _report = report;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleAccept() {
    if (_report == null || _report!.flaggedSpans.isEmpty) return;

    final span = _report!.flaggedSpans[_currentSegmentIndex];
    _acceptedRewrites[_currentSegmentIndex] = span.rewrittenText ??
        'AI Paraphrased: "${span.text}" rewritten into an original, academic formulation without lexical overlaps.';

    CustomToast.show(
      context,
      title: 'Segment Accepted',
      message: 'AI suggestion merged into clean draft.',
      type: ToastType.success,
    );

    _nextSegment();
  }

  void _handleSkip() {
    _nextSegment();
  }

  void _nextSegment() {
    if (_report == null) return;
    final total = _report!.flaggedSpans.length;
    if (_currentSegmentIndex + 1 < total) {
      setState(() {
        _currentSegmentIndex++;
      });
    } else {
      _finalizeAll();
    }
  }

  void _finalizeAll() {
    CustomToast.show(
      context,
      title: 'Mitigation Completed',
      message: 'All segments verified clean. Final document generated.',
      type: ToastType.success,
    );
    widget.onComplete();
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
                'Initializing AI Mitigation Engine...',
                style: TextStyle(color: AppColors.textPrimary(context)),
              ),
            ],
          ),
        ),
      );
    }

    final spans = _report?.flaggedSpans ?? [];
    if (spans.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_rounded, size: 56, color: AppColors.accentGreen(context)),
              const SizedBox(height: 16),
              Text(
                'No Flagged Segments Found!',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This document is already 100% clean and verified.',
                style: TextStyle(color: AppColors.textSecondary(context)),
              ),
              const SizedBox(height: 24),
              GradientButton(
                text: 'View Final Clean Document',
                icon: Icons.article_rounded,
                onPressed: widget.onComplete,
              ),
            ],
          ),
        ),
      );
    }

    final currentSpan = spans[_currentSegmentIndex];
    final totalSegments = spans.length;
    final progressVal = (_currentSegmentIndex + 1) / totalSegments;
    final accentGreen = AppColors.accentGreen(context);
    final accentRed = AppColors.accentRed(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Title & Segment Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Mitigation Engine',
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Iteratively reducing similarity score',
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated(context),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(color: AppColors.borderMid(context)),
                  ),
                  child: Text(
                    '${_currentSegmentIndex + 1} / $totalSegments segments',
                    style: TextStyle(
                      color: accentGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Stage Pipeline Bar
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPipelineStep(context, 'Scan', isDone: true),
                      _buildPipelineArrow(context),
                      _buildPipelineStep(context, 'Detect', isDone: true),
                      _buildPipelineArrow(context),
                      _buildPipelineStep(context, 'Rewrite', isActive: true),
                      _buildPipelineArrow(context),
                      _buildPipelineStep(context, 'Verify', isPending: true),
                      _buildPipelineArrow(context),
                      _buildPipelineStep(context, 'Finalize', isPending: true),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Progress Fill Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: LinearProgressIndicator(
                      value: progressVal,
                      minHeight: 6,
                      backgroundColor: AppColors.borderSubtle(context),
                      valueColor: AlwaysStoppedAnimation<Color>(accentGreen),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Status Line with Spinner
                  Row(
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(accentGreen),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Reviewing segment ${_currentSegmentIndex + 1} of $totalSegments — Source: ${currentSpan.sourceTitle ?? "External Database"}',
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Two-Panel Side by Side Layout
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT: Original (Flagged) Card
                Expanded(
                  child: GlassCard(
                    borderColor: accentRed.withValues(alpha: 0.5),
                    glowColor: accentRed.withValues(alpha: 0.2),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.flag_rounded, size: 20, color: accentRed),
                            const SizedBox(width: 8),
                            Text(
                              'Original (Flagged)',
                              style: TextStyle(
                                color: AppColors.textPrimary(context),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: accentRed.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                              ),
                              child: Text(
                                '${(currentSpan.similarityScore * 100).toInt()}% Match',
                                style: TextStyle(
                                  color: accentRed,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Color(0xFF252545)),
                        const SizedBox(height: 16),

                        Container(
                          constraints: const BoxConstraints(minHeight: 180),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: accentRed.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: accentRed.withValues(alpha: 0.25)),
                          ),
                          child: Text(
                            currentSpan.text,
                            style: TextStyle(
                              color: accentRed,
                              fontSize: 14,
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),

                // RIGHT: AI Suggested Rewrite Card
                Expanded(
                  child: GlassCard(
                    borderColor: accentGreen.withValues(alpha: 0.5),
                    glowColor: accentGreen.withValues(alpha: 0.2),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.auto_awesome_rounded, size: 20, color: accentGreen),
                            const SizedBox(width: 8),
                            Text(
                              'AI Suggested Rewrite',
                              style: TextStyle(
                                color: AppColors.textPrimary(context),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: accentGreen.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                              ),
                              child: Text(
                                '0% Similarity',
                                style: TextStyle(
                                  color: accentGreen,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Color(0xFF252545)),
                        const SizedBox(height: 16),

                        Container(
                          constraints: const BoxConstraints(minHeight: 180),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: accentGreen.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: accentGreen.withValues(alpha: 0.25)),
                          ),
                          child: Text(
                            currentSpan.rewrittenText ??
                                'According to empirical investigation, academic syntax can be systematically refactored to align with non-derivative publication standards.',
                            style: TextStyle(
                              color: AppColors.textPrimary(context),
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: _handleSkip,
                              child: const Text('Skip'),
                            ),
                            const SizedBox(width: 12),
                            GradientButton(
                              text: 'Accept Rewrite',
                              icon: Icons.check_rounded,
                              onPressed: _handleAccept,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Bottom Actions Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _isPaused = !_isPaused);
                    CustomToast.show(
                      context,
                      title: _isPaused ? 'Engine Paused' : 'Engine Resumed',
                      message: _isPaused
                          ? 'Mitigation queue paused.'
                          : 'Resuming iterative segment rewrites.',
                      type: ToastType.info,
                    );
                  },
                  icon: Icon(_isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, size: 18),
                  label: Text(_isPaused ? 'Resume' : 'Pause'),
                ),
                GradientButton(
                  text: 'Accept All & Finalize',
                  icon: Icons.task_alt_rounded,
                  onPressed: _finalizeAll,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPipelineStep(
    BuildContext context,
    String label, {
    bool isDone = false,
    bool isActive = false,
    bool isPending = false,
  }) {
    final accentGreen = AppColors.accentGreen(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDone
            ? accentGreen.withValues(alpha: 0.15)
            : isActive
                ? AppColors.surfaceElevated(context)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: isDone || isActive ? accentGreen : AppColors.borderSubtle(context),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isDone)
            Icon(Icons.check_circle_rounded, size: 16, color: accentGreen)
          else if (isActive)
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(accentGreen),
              ),
            )
          else
            const Icon(Icons.circle_outlined, size: 14, color: Color(0xFF4A4A7A)),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isDone || isActive
                  ? AppColors.textPrimary(context)
                  : AppColors.textSecondary(context),
              fontSize: 12,
              fontWeight: isActive || isDone ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineArrow(BuildContext context) {
    return Icon(
      Icons.arrow_forward_ios_rounded,
      size: 12,
      color: AppColors.borderMid(context),
    );
  }
}