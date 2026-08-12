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
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        _selectedFilePath = file.path;
        _selectedFileName = file.name;
        _selectedFileSize = file.size;
      });
    }
  }

  Future<void> _handleAnalyze() async {
    if (_activeTab == 0) {
      if (_selectedFilePath == null || _selectedFileName == null) {
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
          filePath: _selectedFilePath!,
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Greeting Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning, $userName 👋',
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 26,
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
                ),
                // Pill Tabs Bar
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated(context),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(color: AppColors.borderSubtle(context)),
                  ),
                  child: Row(
                    children: [
                      _buildPillTab(0, 'Upload Document', Icons.cloud_upload_outlined),
                      _buildPillTab(1, 'Direct Text Input', Icons.edit_note_rounded),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Main Two Column Layout
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Primary Input Card (Upload Zone or Text Area)
                Expanded(
                  flex: 3,
                  child: GlassCard(
                    padding: const EdgeInsets.all(28),
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
                                height: 260,
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
                                              padding: const EdgeInsets.all(18),
                                              decoration: BoxDecoration(
                                                color: accentGreen.withValues(alpha: 0.12),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.cloud_upload_rounded,
                                                size: 36,
                                                color: accentGreen,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Drag & drop document here, or click to browse',
                                              style: TextStyle(
                                                color: AppColors.textPrimary(context),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            const Text(
                                              'High accuracy multi-source vector checking',
                                              style: TextStyle(
                                                color: Color(0xFF8888BB),
                                                fontSize: 12,
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
                                            Text(
                                              _selectedFileName!,
                                              style: TextStyle(
                                                color: AppColors.textPrimary(context),
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
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
                            maxLines: 10,
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

                        const SizedBox(height: 28),

                        // Action Button
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
                  ),
                ),
                const SizedBox(width: 24),

                // Right Column: Quick Stats Panel
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
                        const SizedBox(height: 16),
                        const Divider(color: Color(0xFF252545)),
                        const SizedBox(height: 16),

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
                          const SizedBox(height: 16),
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
                          const SizedBox(height: 16),
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
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillTab(int index, String label, IconData icon) {
    final isActive = _activeTab == index;
    final accentGreen = AppColors.accentGreen(context);

    return InkWell(
      onTap: () => setState(() => _activeTab = index),
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? accentGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? const Color(0xFF060610) : AppColors.textSecondary(context),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFF060610) : AppColors.textSecondary(context),
                fontSize: 13,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderSubtle(context)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
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
                    color: AppColors.textSecondary(context),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF4A4A7A),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}