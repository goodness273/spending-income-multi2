import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spending_income/utils/app_theme/index.dart';
import '../../providers/auth_provider.dart';

/// Placeholder screen for the Profile section.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 64,
            color: AppThemeHelpers.getPrimaryColor(isDark).withAlpha(128),
          ),
          const SizedBox(height: 24),
          Text('Profile', style: AppThemeHelpers.getSubheadingStyle(isDark)),
          const SizedBox(height: 8),
          Text('Coming Soon', style: AppThemeHelpers.getBodyStyle(isDark)),
          const SizedBox(height: 40),
          SizedBox(
            width: 140,
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(authNotifierProvider.notifier).signOut();
              },
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDark
                        ? AppColors.darkCardBackground
                        : AppColors.lightBackground,
                foregroundColor: AppThemeHelpers.getPrimaryColor(isDark),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: AppThemeHelpers.getPrimaryColor(isDark).withAlpha(77),
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



