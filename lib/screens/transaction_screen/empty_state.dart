import 'package:flutter/material.dart';
import 'package:spending_income/utils/app_theme/index.dart';

class EmptyState extends StatelessWidget {
  final bool isDark;
  final bool hasFilters;

  const EmptyState({
    super.key,
    required this.isDark,
    this.hasFilters = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.swap_horiz_outlined,
            size: 64,
            color: AppThemeHelpers.getPrimaryColor(isDark).withAlpha(128),
          ),
          const SizedBox(height: 24),
          Text(
            'No Transactions Found',
            style: AppThemeHelpers.getSubheadingStyle(isDark),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters
                ? 'Try changing your filters'
                : 'Add transactions using the + button',
            style: AppThemeHelpers.getBodyStyle(isDark),
          ),
        ],
      ),
    );
  }
} 