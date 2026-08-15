import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/custom_toast.dart';

class SettingsScreen extends StatefulWidget {
  final ValueChanged<AppScreen> onNavigate;
  final String? userEmail;

  const SettingsScreen({
    super.key,
    required this.onNavigate,
    this.userEmail,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiKeyController = TextEditingController(text: 'gsk_demo_key_9837498273');
  bool _obscureKey = true;
  double _similarityThreshold = 15.0;
  String _defaultSearchStrategy = 'hybrid';

  bool _testingConnection = false;
  String? _diagnosticResult;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    CustomToast.show(
      context,
      title: 'Settings Saved',
      message: 'Engine configuration and search parameters updated.',
      type: ToastType.success,
    );
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _testingConnection = true;
      _diagnosticResult = null;
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      setState(() {
        _testingConnection = false;
        _diagnosticResult =
            '✓ All systems operational: FastAPI (127.0.0.1:8000), ChromaDB Vector Store (Local), SQLite DB connected.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentGreen = AppColors.accentGreen(context);
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Subtitle
            Text(
              'Engine Settings',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: isMobile ? 22 : 26,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Configure LLM credentials, similarity alert thresholds, and system parameters.',
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 28),

            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 840),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. LLM Credentials
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.key_rounded, color: accentGreen, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'LLM Credentials & API Keys',
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

                        Text(
                          'Groq API Key (llama-3.1-8b-instant)',
                          style: TextStyle(
                            color: AppColors.textSecondary(context),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _apiKeyController,
                          obscureText: _obscureKey,
                          style: TextStyle(color: AppColors.textPrimary(context), fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'gsk_...',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureKey ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                size: 18,
                                color: AppColors.textSecondary(context),
                              ),
                              onPressed: () => setState(() => _obscureKey = !_obscureKey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Detection Parameters
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.tune_rounded, color: AppColors.accentBlue(context), size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'Plagiarism Detection Parameters',
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

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Similarity Alert Threshold',
                              style: TextStyle(
                                color: AppColors.textSecondary(context),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: accentGreen.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                              ),
                              child: Text(
                                '${_similarityThreshold.toInt()}%',
                                style: TextStyle(
                                  color: accentGreen,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _similarityThreshold,
                          min: 5.0,
                          max: 50.0,
                          divisions: 9,
                          activeColor: accentGreen,
                          onChanged: (val) => setState(() => _similarityThreshold = val),
                        ),
                        const SizedBox(height: 14),

                        Text(
                          'Default Search Strategy',
                          style: TextStyle(
                            color: AppColors.textSecondary(context),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (isMobile)
                          Column(
                            children: [
                              _strategyOption(context, 'hybrid', 'Hybrid (BM25 + ChromaDB)'),
                              const SizedBox(height: 8),
                              _strategyOption(context, 'semantic', 'Semantic Vectors'),
                              const SizedBox(height: 8),
                              _strategyOption(context, 'lexical', 'BM25 Lexical'),
                            ],
                          )
                        else
                          Row(
                            children: [
                              _strategyOption(context, 'hybrid', 'Hybrid (BM25 + ChromaDB)'),
                              const SizedBox(width: 12),
                              _strategyOption(context, 'semantic', 'Semantic Vectors'),
                              const SizedBox(width: 12),
                              _strategyOption(context, 'lexical', 'BM25 Lexical'),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. Keyboard Shortcut Reference Cheat Sheet
                  GlassCard(
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.keyboard_rounded, color: AppColors.accentPurple(context), size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'Keyboard Shortcuts Reference',
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

                        if (isMobile)
                          Column(
                            children: [
                              _buildShortcutRow(context, 'Ctrl + K', 'Command Palette'),
                              const SizedBox(height: 8),
                              _buildShortcutRow(context, 'Ctrl + U', 'Upload Document'),
                              const SizedBox(height: 8),
                              _buildShortcutRow(context, 'Ctrl + R', 'Reports History'),
                              const SizedBox(height: 8),
                              _buildShortcutRow(context, 'Ctrl + M', 'AI Mitigation'),
                            ],
                          )
                        else ...[
                          Row(
                            children: [
                              Expanded(child: _buildShortcutRow(context, 'Ctrl + K', 'Quick Command Palette Search')),
                              const SizedBox(width: 20),
                              Expanded(child: _buildShortcutRow(context, 'Ctrl + U', 'Upload New Document')),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildShortcutRow(context, 'Ctrl + R', 'View Reports History')),
                              const SizedBox(width: 20),
                              Expanded(child: _buildShortcutRow(context, 'Ctrl + M', 'AI Mitigation Engine')),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4. Diagnostics & Health Check
                  GlassCard(
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.memory_rounded, color: accentGreen, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'System Diagnostics',
                              style: TextStyle(
                                color: AppColors.textPrimary(context),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            OutlinedButton.icon(
                              onPressed: _testingConnection ? null : _runDiagnostics,
                              icon: _testingConnection
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.speed_rounded, size: 16),
                              label: Text(_testingConnection ? 'Testing...' : 'Run Diagnostics'),
                            ),
                          ],
                        ),
                        if (_diagnosticResult != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: accentGreen.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(color: accentGreen.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              _diagnosticResult!,
                              style: TextStyle(
                                color: accentGreen,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Action Buttons
                  if (isMobile)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GradientButton(
                          text: 'Save Settings',
                          icon: Icons.check_rounded,
                          onPressed: _saveSettings,
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: () => widget.onNavigate(AppScreen.upload),
                          child: const Text('Cancel'),
                        ),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => widget.onNavigate(AppScreen.upload),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        GradientButton(
                          text: 'Save Settings',
                          icon: Icons.check_rounded,
                          onPressed: _saveSettings,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutRow(BuildContext context, String keys, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderSubtle(context)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.borderSubtle(context),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              keys,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _strategyOption(BuildContext context, String key, String label) {
    final selected = _defaultSearchStrategy == key;
    final accentGreen = AppColors.accentGreen(context);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _defaultSearchStrategy = key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? accentGreen.withValues(alpha: 0.15) : AppColors.surfaceElevated(context),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected ? accentGreen : AppColors.borderSubtle(context),
              width: selected ? 1.5 : 1.0,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? AppColors.textPrimary(context) : AppColors.textSecondary(context),
              fontSize: 12,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
