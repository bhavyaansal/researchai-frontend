import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomToast {
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 4),
  }) {
    Color borderLeftColor;
    IconData typeIcon;

    switch (type) {
      case ToastType.success:
        borderLeftColor = AppColors.darkAccentGreen;
        typeIcon = Icons.check_circle_rounded;
        break;
      case ToastType.error:
        borderLeftColor = AppColors.darkAccentRed;
        typeIcon = Icons.error_rounded;
        break;
      case ToastType.warning:
        borderLeftColor = AppColors.darkAccentOrange;
        typeIcon = Icons.warning_rounded;
        break;
      case ToastType.info:
        borderLeftColor = AppColors.darkAccentBlue;
        typeIcon = Icons.info_rounded;
        break;
    }

    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      margin: const EdgeInsets.only(bottom: 24, right: 24, left: 24),
      duration: duration,
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF13132A),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: const Color(0xFF252545)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: borderLeftColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 14),
              Icon(typeIcon, color: borderLeftColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFFF0F0FF),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    Text(
                      message,
                      style: const TextStyle(
                        color: Color(0xFF8888BB),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

enum ToastType { success, error, warning, info }
