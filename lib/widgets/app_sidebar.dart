import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'airy_logo.dart';
import 'profile_dialog.dart';

enum AppScreen {
  dashboard,
  upload,
  plagiarism,
  report,
  mitigation,
  reports,
  finalReport,
  aichat,
  settings,
}

class AppSidebar extends StatelessWidget {
  final AppScreen current;
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;
  final ValueChanged<AppScreen> onNavigate;
  final String userEmail;
  final VoidCallback onLogout;
  final VoidCallback? onOpenCommandPalette;

  const AppSidebar({
    super.key,
    required this.current,
    required this.isCollapsed,
    required this.onToggleCollapse,
    required this.onNavigate,
    required this.userEmail,
    required this.onLogout,
    this.onOpenCommandPalette,
  });

  @override
  Widget build(BuildContext context) {
    final bgDeep = AppColors.bgDeep(context);
    final borderSubtle = AppColors.borderSubtle(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isCollapsed ? 68 : 220,
      decoration: BoxDecoration(
        color: bgDeep,
        border: Border(right: BorderSide(color: borderSubtle, width: 1.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Logo Area
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: isCollapsed
                ? Center(child: AiryLogo(showText: false, size: 28))
                : Row(
                    children: [
                      AiryLogo(showText: true, size: 28),
                      const Spacer(),
                      IconButton(
                        onPressed: onToggleCollapse,
                        icon: const Icon(Icons.chevron_left_rounded, size: 20),
                        color: AppColors.textSecondary(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
          ),
          const Divider(height: 1, color: Color(0xFF252545)),
          const SizedBox(height: 12),

          // Search / Command Palette Hint Box
          if (!isCollapsed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: InkWell(
                onTap: onOpenCommandPalette,
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated(context),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.borderSubtle(context)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, size: 16, color: AppColors.textSecondary(context)),
                      const SizedBox(width: 8),
                      Text(
                        'Quick Search',
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
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
          const SizedBox(height: 12),

          // Scrollable Navigation List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                _buildCategoryHeader('WORKSPACE'),
                _buildNavItem(
                  screen: AppScreen.dashboard,
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  shortcutHint: 'Ctrl+D',
                ),
                _buildNavItem(
                  screen: AppScreen.upload,
                  icon: Icons.upload_file_outlined,
                  activeIcon: Icons.upload_file_rounded,
                  label: 'Upload Document',
                  shortcutHint: 'Ctrl+U',
                ),
                _buildNavItem(
                  screen: AppScreen.report,
                  icon: Icons.analytics_outlined,
                  activeIcon: Icons.analytics_rounded,
                  label: 'Plagiarism Report',
                ),
                _buildNavItem(
                  screen: AppScreen.mitigation,
                  icon: Icons.auto_fix_high_outlined,
                  activeIcon: Icons.auto_fix_high_rounded,
                  label: 'AI Mitigation',
                  shortcutHint: 'Ctrl+M',
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1, color: Color(0xFF1A1A35)),
                ),

                _buildCategoryHeader('TOOLS'),
                _buildNavItem(
                  screen: AppScreen.reports,
                  icon: Icons.history_rounded,
                  activeIcon: Icons.history_toggle_off_rounded,
                  label: 'Reports History',
                  shortcutHint: 'Ctrl+R',
                ),
                _buildNavItem(
                  screen: AppScreen.aichat,
                  icon: Icons.psychology_outlined,
                  activeIcon: Icons.psychology_rounded,
                  label: 'AI Rewriter',
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1, color: Color(0xFF1A1A35)),
                ),

                _buildCategoryHeader('SYSTEM'),
                _buildNavItem(
                  screen: AppScreen.settings,
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings_rounded,
                  label: 'Settings',
                ),
              ],
            ),
          ),

          // User Profile Footer
          const Divider(height: 1, color: Color(0xFF252545)),
          InkWell(
            onTap: () => ProfileDialog.show(context, userEmail: userEmail, onLogout: onLogout),
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.transparent,
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppGradients.purpleCyan,
                    ),
                    child: Center(
                      child: Text(
                        userEmail.isNotEmpty ? userEmail.substring(0, 1).toUpperCase() : 'BH',
                        style: const TextStyle(
                          color: Color(0xFF060610),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  if (!isCollapsed) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userEmail.isEmpty ? 'Researcher' : userEmail.split('@').first,
                            style: TextStyle(
                              color: AppColors.textPrimary(context),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF00E5A0),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Free Plan',
                                style: TextStyle(
                                  color: Color(0xFF8888BB),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.more_vert_rounded,
                      size: 16,
                      color: AppColors.textSecondary(context),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(String title) {
    if (isCollapsed) return const SizedBox(height: 6);
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 12, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF4A4A7A),
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required AppScreen screen,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    String? shortcutHint,
  }) {
    final isActive = current == screen;

    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: InkWell(
            onTap: () => onNavigate(screen),
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF00E5A0).withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  // Active left indicator bar
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 3,
                    height: 18,
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFF00E5A0) : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: isActive
                          ? [
                              const BoxShadow(
                                color: Color(0xFF00E5A0),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ]
                          : [],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isActive ? activeIcon : icon,
                    size: 18,
                    color: isActive ? const Color(0xFF00E5A0) : AppColors.textSecondary(context),
                  ),
                  if (!isCollapsed) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isActive ? AppColors.textPrimary(context) : AppColors.textSecondary(context),
                          fontSize: 13,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (shortcutHint != null)
                      Text(
                        shortcutHint,
                        style: const TextStyle(
                          color: Color(0xFF4A4A7A),
                          fontSize: 10,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}