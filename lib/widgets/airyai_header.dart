import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'profile_dialog.dart';

class LemmaHeader extends StatelessWidget {
  final bool isSidebarCollapsed;
  final VoidCallback onToggleSidebar;
  final VoidCallback onNewWorkspace;
  final String? userEmail;
  final VoidCallback onLogout;
  final VoidCallback? onOpenCommandPalette;
  final VoidCallback? onToggleTheme;
  final bool isDarkMode;

  const LemmaHeader({
    super.key,
    required this.isSidebarCollapsed,
    required this.onToggleSidebar,
    required this.onNewWorkspace,
    required this.onLogout,
    this.userEmail,
    this.onOpenCommandPalette,
    this.onToggleTheme,
    this.isDarkMode = true,
  });

  @override
  Widget build(BuildContext context) {
    final accentGreen = AppColors.accentGreen(context);

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.bgDeep(context),
        border: Border(
          bottom: BorderSide(color: AppColors.borderSubtle(context)),
        ),
      ),
      child: Row(
        children: [
          // Sidebar Toggle Button
          IconButton(
            onPressed: onToggleSidebar,
            icon: Icon(Icons.menu_rounded, color: AppColors.textSecondary(context), size: 18),
            tooltip: 'Toggle Sidebar',
          ),
          const SizedBox(width: 8),

          // Search pill — opens command palette
          Expanded(
            child: GestureDetector(
              onTap: onOpenCommandPalette,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  height: 36,
                  constraints: const BoxConstraints(maxWidth: 440),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated(context),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.borderSubtle(context)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, color: AppColors.textSecondary(context), size: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Search reports or run command…',
                          style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12.5),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.borderSubtle(context),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Ctrl+K',
                          style: TextStyle(
                            color: Color(0xFF8888BB),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Dark/Light Theme toggle
          IconButton(
            onPressed: onToggleTheme,
            icon: Icon(
              isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round,
              color: AppColors.textSecondary(context),
              size: 18,
            ),
            tooltip: isDarkMode ? 'Switch to Warm Light' : 'Switch to Dark Pro',
          ),

          const SizedBox(width: 8),

          // New Scan button
          InkWell(
            onTap: onNewWorkspace,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppGradients.cyanGreen,
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: [
                  BoxShadow(
                    color: accentGreen.withValues(alpha: 0.25),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, size: 16, color: Color(0xFF060610)),
                  SizedBox(width: 6),
                  Text(
                    'New Scan',
                    style: TextStyle(
                      color: Color(0xFF060610),
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 14),

          // User Avatar -> Opens Profile Dialog
          InkWell(
            onTap: () => ProfileDialog.show(
              context,
              userEmail: userEmail ?? 'user@domain.com',
              onLogout: onLogout,
            ),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppGradients.purpleCyan,
              ),
              child: Center(
                child: Text(
                  (userEmail != null && userEmail!.isNotEmpty)
                      ? userEmail!.substring(0, 1).toUpperCase()
                      : 'BH',
                  style: const TextStyle(
                    color: Color(0xFF060610),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
