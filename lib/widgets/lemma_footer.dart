import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LemmaFooter extends StatelessWidget {
  final bool isBackendOnline;

  const LemmaFooter({super.key, this.isBackendOnline = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.bgDeep(context),
        border: Border(top: BorderSide(color: AppColors.borderSubtle(context), width: 1)),
      ),
      child: Row(
        children: [
          _statusItem(
            context,
            label: 'ResearchAI Engine (v2.4)',
            isOnline: isBackendOnline,
          ),
          const SizedBox(width: 24),
          _statusItem(
            context,
            label: 'ChromaDB Vector Store',
            isOnline: isBackendOnline,
          ),
          const SizedBox(width: 24),
          _statusItem(
            context,
            label: 'FastAPI Service',
            isOnline: isBackendOnline,
          ),
          const Spacer(),
          Text(
            'Press Ctrl+K for command palette',
            style: TextStyle(
              color: AppColors.textTertiary(context),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusItem(
    BuildContext context, {
    required String label,
    required bool isOnline,
    String? statusText,
  }) {
    final status = statusText ?? (isOnline ? 'Active' : 'Offline');
    final color = isOnline ? AppColors.accentGreen(context) : AppColors.accentRed(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: isOnline
                ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6, spreadRadius: 1)]
                : null,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          '$label: ',
          style: TextStyle(color: AppColors.textSecondary(context), fontSize: 11, fontWeight: FontWeight.w500),
        ),
        Text(
          status,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
