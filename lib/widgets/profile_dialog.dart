import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileDialog extends StatelessWidget {
  final String userEmail;
  final VoidCallback onLogout;

  const ProfileDialog({
    super.key,
    required this.userEmail,
    required this.onLogout,
  });

  static void show(
    BuildContext context, {
    required String userEmail,
    required VoidCallback onLogout,
  }) {
    showDialog(
      context: context,
      builder: (context) => ProfileDialog(
        userEmail: userEmail,
        onLogout: onLogout,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initials = userEmail.isNotEmpty
        ? userEmail.substring(0, 1).toUpperCase()
        : 'U';
    final accentGreen = AppColors.accentGreen(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard(context),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderSubtle(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // User Avatar
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppGradients.purpleCyan,
                boxShadow: [
                  BoxShadow(
                    color: accentGreen.withValues(alpha: 0.3),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Color(0xFF060610),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Email & Plan Badge
            Text(
              userEmail.isEmpty ? 'researcher@university.edu' : userEmail,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: accentGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: accentGreen.withValues(alpha: 0.3)),
              ),
              child: Text(
                'Free Plan',
                style: TextStyle(
                  color: accentGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(color: Color(0xFF252545)),
            const SizedBox(height: 16),

            // Quick Stats inside profile
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context, 'Scans Used', '12 / 50'),
                _buildStatItem(context, 'Avg Score', '18%'),
                _buildStatItem(context, 'Mitigated', '94%'),
              ],
            ),
            const SizedBox(height: 24),

            // Sign Out Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onLogout();
                },
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentRed(context).withValues(alpha: 0.15),
                  foregroundColor: AppColors.accentRed(context),
                  side: BorderSide(color: AppColors.accentRed(context).withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 14,
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
