import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';

class PlaceholderWorkspaceScreen extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final ValueChanged<AppScreen> onNavigate;

  const PlaceholderWorkspaceScreen({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final accentGreen = AppColors.accentGreen(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: GlassCard(
          padding: const EdgeInsets.all(32),
          child: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: accentGreen.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: accentGreen.withValues(alpha: 0.3)),
                  ),
                  child: Icon(icon, color: accentGreen, size: 26),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                GradientButton(
                  text: 'Return to Dashboard',
                  icon: Icons.arrow_back_rounded,
                  onPressed: () => onNavigate(AppScreen.dashboard),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
