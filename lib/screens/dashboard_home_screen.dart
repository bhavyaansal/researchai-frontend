import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';

class DashboardHomeScreen extends StatefulWidget {
  final ValueChanged<AppScreen> onNavigate;
  const DashboardHomeScreen({super.key, required this.onNavigate});

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen>
    with SingleTickerProviderStateMixin {
  final _promptController = TextEditingController();
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _pageHeading(context),
                  const SizedBox(height: 36),
                  _promptBar(context),
                  const SizedBox(height: 56),
                  _actionGrid(context),
                  const SizedBox(height: 48),
                  _engineStrip(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pageHeading(BuildContext context) {
    final accentGreen = AppColors.accentGreen(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: accentGreen,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accentGreen.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'ResearchAI Engine • Operational',
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'What academic document\nwould you like to scan today?',
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 36,
            fontWeight: FontWeight.bold,
            height: 1.15,
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Detect plagiarism, inspect flagged matches, and run iterative AI mitigation.',
          style: TextStyle(
            color: AppColors.textSecondary(context),
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _promptBar(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _promptController,
              style: TextStyle(color: AppColors.textPrimary(context), fontSize: 14),
              onSubmitted: (_) => widget.onNavigate(AppScreen.upload),
              decoration: const InputDecoration(
                hintText: 'Paste academic text or title to begin analysis…',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 16),
          GradientButton(
            text: 'Scan Now',
            icon: Icons.arrow_forward_rounded,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            onPressed: () => widget.onNavigate(AppScreen.upload),
          ),
        ],
      ),
    );
  }

  Widget _actionGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WORKSPACE QUICK ACTIONS',
          style: TextStyle(
            color: AppColors.textTertiary(context),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GlassCard(
                onTap: () => widget.onNavigate(AppScreen.upload),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.upload_file_rounded, size: 24, color: AppColors.accentGreen(context)),
                    const SizedBox(height: 16),
                    Text(
                      'Plagiarism Check',
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Upload PDF, DOCX or paste raw text to run lexical & semantic checking.',
                      style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GlassCard(
                onTap: () => widget.onNavigate(AppScreen.reports),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.history_rounded, size: 24, color: AppColors.accentBlue(context)),
                    const SizedBox(height: 16),
                    Text(
                      'Reports History',
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Browse past document analyses, similarity trends, and polished files.',
                      style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GlassCard(
                onTap: () => widget.onNavigate(AppScreen.aichat),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.psychology_rounded, size: 24, color: AppColors.accentPurple(context)),
                    const SizedBox(height: 16),
                    Text(
                      'AI Paraphraser',
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Refactor flagged sentences into original, high-quality publication prose.',
                      style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _engineStrip(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'POWERED BY INTEGRATED ENGINES',
          style: TextStyle(
            color: AppColors.textTertiary(context),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _engineChip(context, 'Groq Llama 3.1 8B', AppColors.accentGreen(context)),
            const SizedBox(width: 10),
            _engineChip(context, 'ChromaDB Vector Store', AppColors.accentBlue(context)),
            const SizedBox(width: 10),
            _engineChip(context, 'BM25 Lexical Parser', AppColors.accentOrange(context)),
            const SizedBox(width: 10),
            _engineChip(context, 'SentenceTransformers Embeddings', AppColors.accentPurple(context)),
          ],
        ),
      ],
    );
  }

  Widget _engineChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
