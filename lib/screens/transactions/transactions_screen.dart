import 'package:flutter/material.dart';
import 'package:spending_income/utils/app_theme/index.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          Text('Transactions', style: AppThemeHelpers.getSubheadingStyle(isDark)),
          const SizedBox(height: 8),
          Text('Coming Soon', style: AppThemeHelpers.getBodyStyle(isDark)),
        ],
      ),
    );
  }
} 



