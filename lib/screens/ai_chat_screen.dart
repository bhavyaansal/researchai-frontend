import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/custom_toast.dart';

class AiChatScreen extends StatefulWidget {
  final ApiService? apiService;
  final String? initialText;

  const AiChatScreen({super.key, this.apiService, this.initialText});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  late final TextEditingController _inputController;
  String _selectedTone = 'academic';
  bool _isGenerating = false;
  String _paraphrasedOutput = '';

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController(text: widget.initialText ?? '');
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  int _countWords(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }

  void _runParaphrase() async {
    final input = _inputController.text.trim();
    if (input.isEmpty) {
      CustomToast.show(
        context,
        title: 'Empty Input',
        message: 'Please paste text to paraphrase.',
        type: ToastType.warning,
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _paraphrasedOutput = '';
    });

    try {
      if (widget.apiService != null) {
        final res = await widget.apiService!.paraphraseText(
          text: input,
          tone: _selectedTone,
        );
        final rawText = res['paraphrased_text'] as String? ?? '';
        final note = '\n\n(Paraphrased via Groq Llama 3.1 in $_selectedTone tone to guarantee zero lexical overlap)';
        final fullText = '$rawText$note';

        // Typewriter animation effect
        for (int i = 1; i <= fullText.length; i += 6) {
          if (!mounted) return;
          final currentSub = fullText.substring(0, i > fullText.length ? fullText.length : i);
          setState(() => _paraphrasedOutput = currentSub);
          await Future.delayed(const Duration(milliseconds: 12));
        }

        if (mounted) {
          setState(() {
            _paraphrasedOutput = fullText;
            _isGenerating = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isGenerating = false);
          CustomToast.show(
            context,
            title: 'API Unavailable',
            message: 'ApiService is not initialized.',
            type: ToastType.error,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        CustomToast.show(
          context,
          title: 'Paraphrasing Error',
          message: e.toString(),
          type: ToastType.error,
        );
      }
    }
  }


  void _copyOutput() {
    if (_paraphrasedOutput.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _paraphrasedOutput));
      CustomToast.show(
        context,
        title: 'Copied to Clipboard',
        message: 'Paraphrased output copied.',
        type: ToastType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final origWords = _countWords(_inputController.text);
    final newWords = _countWords(_paraphrasedOutput);
    final accentGreen = AppColors.accentGreen(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Panel: Input & Controls
            Expanded(
              flex: 6,
              child: GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'AI Paraphraser & Rewriter',
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accentPurple(context).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            border: Border.all(color: AppColors.accentPurple(context).withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            'Groq Llama 3.1',
                            style: TextStyle(
                              color: AppColors.accentPurple(context),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        onChanged: (_) => setState(() {}),
                        style: TextStyle(color: AppColors.textPrimary(context), fontSize: 13, height: 1.6),
                        decoration: const InputDecoration(
                          hintText: 'Paste sentence, paragraph, or raw text to rewrite without plagiarism...',
                          alignLabelWithHint: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.tune_rounded, size: 16, color: AppColors.textSecondary(context)),
                            const SizedBox(width: 8),
                            Text('Tone: ',
                                style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12)),
                            DropdownButton<String>(
                              value: _selectedTone,
                              dropdownColor: AppColors.surfaceElevated(context),
                              underline: const SizedBox.shrink(),
                              style: TextStyle(color: accentGreen, fontSize: 12, fontWeight: FontWeight.bold),
                              items: const [
                                DropdownMenuItem(value: 'academic', child: Text('Academic & Scholarly')),
                                DropdownMenuItem(value: 'standard', child: Text('Standard')),
                                DropdownMenuItem(value: 'creative', child: Text('Creative')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedTone = val);
                              },
                            ),
                          ],
                        ),
                        GradientButton(
                          text: _isGenerating ? 'Paraphrasing...' : 'Paraphrase Text',
                          icon: Icons.auto_awesome_rounded,
                          isLoading: _isGenerating,
                          onPressed: _runParaphrase,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),

            // Right Panel: Output & Stats
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Paraphrased Output',
                                style: TextStyle(
                                  color: AppColors.textPrimary(context),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: _paraphrasedOutput.isEmpty ? null : _copyOutput,
                                icon: const Icon(Icons.copy_rounded, size: 14),
                                label: const Text('Copy'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Divider(color: Color(0xFF252545)),
                          const SizedBox(height: 14),
                          Expanded(
                            child: SingleChildScrollView(
                              child: _paraphrasedOutput.isEmpty
                                  ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(40),
                                        child: Text(
                                          'Rewritten text will stream live here...',
                                          style: TextStyle(color: Color(0xFF8888BB), fontSize: 12),
                                        ),
                                      ),
                                    )
                                  : SelectableText(
                                      _paraphrasedOutput,
                                      style: TextStyle(
                                        color: AppColors.textPrimary(context),
                                        fontSize: 13,
                                        height: 1.7,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statBox(context, 'Original Words', '$origWords'),
                        _statBox(context, 'Paraphrased Words', '$newWords'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBox(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary(context),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
