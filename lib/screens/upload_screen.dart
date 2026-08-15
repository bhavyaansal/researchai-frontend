import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/custom_toast.dart';

class UploadScreen extends StatefulWidget {
  final ValueChanged<JobModel> onUploadSuccess;
  final ApiService apiService;
  final String userEmail;

  const UploadScreen({
    super.key,
    required this.onUploadSuccess,
    required this.apiService,
    required this.userEmail,
  });

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> with SingleTickerProviderStateMixin {
  int _activeTab = 0; // 0 = File Upload, 1 = Direct Text Input

  // File Upload State
  String? _selectedFilePath;
  Uint8List? _selectedFileBytes;
  String? _selectedFileName;
  int? _selectedFileSize;
  bool _isHoveringDropZone = false;


  // Text Input State
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _titleController = TextEditingController(text: 'Untitled Research Paper');
  int _wordCount = 0;
  int _charCount = 0;

  // Quick Stats Real State
  bool _isLoadingStats = true;
  int _totalScans = 0;
  double _avgSimilarity = 0.0;
  int _docsThisWeek = 0;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    _loadQuickStats();
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _textController.text;
    final words = text.trim().isEmpty
        ? 0
        : text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    setState(() {
      _wordCount = words;
      _charCount = text.length;
    });
  }

  Future<void> _loadQuickStats() async {
    try {
      final jobs = await widget.apiService.listJobs();
      if (!mounted) return;

      int count = jobs.length;
      double sumScore = 0.0;
      int scoredCount = 0;
      int thisWeek = 0;

      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

      for (final job in jobs) {
        if (job.globalSimilarityScore != null) {
          sumScore += job.globalSimilarityScore!;
          scoredCount++;
        }
        if (job.createdAt.isAfter(weekAgo)) {
          thisWeek++;
        }
      }

      setState(() {
        _totalScans = count;
        _avgSimilarity = scoredCount > 0 ? (sumScore / scoredCount) * 100 : 0.0;
        _docsThisWeek = thisWeek;
        _isLoadingStats = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'txt'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        _selectedFilePath = file.path;
        _selectedFileBytes = file.bytes;
        _selectedFileName = file.name;
        _selectedFileSize = file.size;
      });
    }
  }

  Future<void> _handleAnalyze() async {
    if (_activeTab == 0) {
      if ((_selectedFilePath == null && _selectedFileBytes == null) || _selectedFileName == null) {
        CustomToast.show(
          context,
          title: 'No file selected',
          message: 'Please select a document (.pdf, .docx, .txt) to upload.',
          type: ToastType.warning,
        );
        return;
      }

      setState(() => _isSubmitting = true);
      try {
        final job = await widget.apiService.uploadDocument(
          filePath: _selectedFilePath,
          bytes: _selectedFileBytes,
          filename: _selectedFileName!,
        );
        widget.onUploadSuccess(job);
      } catch (e) {
        if (mounted) {
          CustomToast.show(
            context,
            title: 'Upload Failed',
            message: e.toString(),
            type: ToastType.error,
          );
        }
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    } else {
      if (_textController.text.trim().isEmpty) {
        CustomToast.show(
          context,
          title: 'Empty Content',
          message: 'Please enter or paste document text to analyze.',
          type: ToastType.warning,
        );
        return;
      }

      setState(() => _isSubmitting = true);
      try {
        final job = await widget.apiService.uploadText(
          text: _textController.text,
          title: _titleController.text.isEmpty ? 'Direct Text Scan' : _titleController.text,
        );
        widget.onUploadSuccess(job);
      } catch (e) {
        if (mounted) {
          CustomToast.show(
            context,
            title: 'Scan Failed',
            message: e.toString(),
            type: ToastType.error,
          );
        }
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = widget.userEmail.isNotEmpty
        ? widget.userEmail.split('@').first
        : 'Researcher';
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    final dateStr = '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
    final accentGreen = AppColors.accentGreen(context);

    final isMobile = Responsive.isMobile(context);

    final greetingColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good morning, $userName 👋',
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: isMobile ? 20 : 26,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          dateStr,
          style: TextStyle(
            color: AppColors.textSecondary(context),
            fontSize: 13,
          ),
        ),
      ],
    );

    final pillTabsBar = Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.borderSubtle(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPillTab(0, 'Upload Document', Icons.cloud_upload_outlined, isMobile),
          _buildPillTab(1, 'Direct Text Input', Icons.edit_note_rounded, isMobile),
        ],
      ),
    );

    final leftPrimaryCard = GlassCard(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_activeTab == 0) ...[
            // Upload Zone
            Text(
              'Select Document File',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Supported formats: .pdf, .docx, .txt (up to 25MB)',
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),

            MouseRegion(
              onEnter: (_) => setState(() => _isHoveringDropZone = true),
              onExit: (_) => setState(() => _isHoveringDropZone = false),
              child: GestureDetector(
                onTap: _pickFile,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: isMobile ? 200 : 260,
                  decoration: BoxDecoration(
                    color: _isHoveringDropZone
                        ? accentGreen.withValues(alpha: 0.06)
                        : AppColors.surfaceElevated(context).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: _isHoveringDropZone || _selectedFileName != null
                          ? accentGreen
                          : AppColors.borderMid(context),
                      width: _isHoveringDropZone ? 2.0 : 1.5,
                      style: BorderStyle.solid,
                    ),
                    boxShadow: _isHoveringDropZone
                        ? [
                            BoxShadow(
                              color: accentGreen.withValues(alpha: 0.2),
                              blurRadius: 16,
                            )
                          ]
                        : [],
                  ),
                  child: Center(
                    child: _selectedFileName == null
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: EdgeInsets.all(isMobile ? 12 : 18),
                                decoration: BoxDecoration(
                                  color: accentGreen.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.cloud_upload_rounded,
                                  size: isMobile ? 28 : 36,
                                  color: accentGreen,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'Drag & drop document here, or click to browse',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.textPrimary(context),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'High accuracy multi-source vector checking',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF8888BB),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.insert_drive_file_rounded,
                                size: 48,
                                color: accentGreen,
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  _selectedFileName!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.textPrimary(context),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (_selectedFileSize != null)
                                Text(
                                  '${(_selectedFileSize! / 1024).toStringAsFixed(1)} KB',
                                  style: TextStyle(
                                    color: AppColors.textSecondary(context),
                                    fontSize: 12,
                                  ),
                                ),
                              const SizedBox(height: 14),
                              OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _selectedFilePath = null;
                                    _selectedFileName = null;
                                  });
                                },
                                icon: const Icon(Icons.refresh_rounded, size: 16),
                                label: const Text('Change File'),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ] else ...[
            // Direct Text Area Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Document Title',
                      hintText: 'Enter title for this scan...',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              maxLines: 8,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 13,
                height: 1.5,
              ),
              decoration: const InputDecoration(
                hintText: 'Paste academic text, draft or paper content here to scan for plagiarism...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$_wordCount words • $_charCount characters',
                  style: TextStyle(
                    color: AppColors.accentBlue(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_wordCount > 0)
                  TextButton(
                    onPressed: () => _textController.clear(),
                    child: const Text('Clear Text'),
                  ),
              ],
            ),
          ],

          const SizedBox(height: 24),

          // Action Button
          if (isMobile)
            Row(
              children: [
                Expanded(
                  child: GradientButton(
                    text: 'Analyze Document',
                    icon: Icons.arrow_forward_rounded,
                    isLoading: _isSubmitting,
                    onPressed: _handleAnalyze,
                  ),
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GradientButton(
                  text: 'Analyze Document',
                  icon: Icons.arrow_forward_rounded,
                  isLoading: _isSubmitting,
                  onPressed: _handleAnalyze,
                ),
              ],
            ),
        ],
      ),
    );

    final rightQuickStatsCard = GlassCard(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_rounded,
                color: accentGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Quick Stats',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF252545)),
          const SizedBox(height: 12),

          if (_isLoadingStats) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            ),
          ] else ...[
            _buildStatCard(
              context,
              title: 'Total Scans',
              value: '$_totalScans',
              subtitle: 'Lifetime processed documents',
              icon: Icons.article_rounded,
              iconColor: AppColors.accentBlue(context),
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              context,
              title: 'Avg Similarity',
              value: '${_avgSimilarity.toStringAsFixed(1)}%',
              subtitle: 'Across all past reports',
              icon: Icons.speed_rounded,
              iconColor: _avgSimilarity <= 15
                  ? accentGreen
                  : AppColors.accentOrange(context),
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              context,
              title: 'Scanned This Week',
              value: '$_docsThisWeek',
              subtitle: 'Recent activity count',
              icon: Icons.date_range_rounded,
              iconColor: AppColors.accentPurple(context),
            ),
          ],
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Greeting Header
            if (isMobile)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  greetingColumn,
                  const SizedBox(height: 14),
                  pillTabsBar,
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  greetingColumn,
                  pillTabsBar,
                ],
              ),
            const SizedBox(height: 24),

            // Layout
            if (isMobile)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  leftPrimaryCard,
                  const SizedBox(height: 20),
                  rightQuickStatsCard,
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: leftPrimaryCard),
                  const SizedBox(width: 24),
                  Expanded(flex: 2, child: rightQuickStatsCard),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillTab(int index, String label, IconData icon, [bool compact = false]) {
    final isActive = _activeTab == index;
    final accentGreen = AppColors.accentGreen(context);

    return InkWell(
      onTap: () => setState(() => _activeTab = index),
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? accentGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isActive ? const Color(0xFF060610) : AppColors.textSecondary(context),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFF060610) : AppColors.textSecondary(context),
                fontSize: compact ? 11.5 : 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
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
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF8888BB),
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}