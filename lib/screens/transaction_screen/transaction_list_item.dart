import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spending_income/models/transaction.dart' as model;
import 'package:spending_income/utils/app_theme/index.dart';

class TransactionListItem extends StatelessWidget {
  final model.Transaction transaction;
  final bool isDark;
  final DateFormat dateFormat;
  final NumberFormat currencyFormat;
  final VoidCallback onTap;
  
  // Category icons map with fixed mappings for core categories
  static final Map<String, IconData> categoryIcons = {
    'Food & Dining': Icons.restaurant,
    'Transportation': Icons.directions_car,
    'Transport': Icons.directions_car, // Add alias for Transportation
    'Housing': Icons.home,
    'Entertainment': Icons.movie,
    'Utilities': Icons.power_outlined, // Changed to better match image
    'Healthcare': Icons.medical_services,
    'Health': Icons.medical_services, // Add alias for Healthcare
    'Shopping': Icons.shopping_bag,
    'Travel': Icons.flight,
    'Education': Icons.school,
    'Salary': Icons.account_balance_wallet,
    'Business': Icons.business,
    'Investment': Icons.trending_up,
    'Gifts': Icons.card_giftcard,
    'Other': Icons.category,
  };

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.isDark,
    required this.dateFormat,
    required this.currencyFormat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isExpense = transaction.type == model.TransactionType.expense;
    final String category = transaction.category ?? 'Other'; // Default to Other
    
    // Get category icon or default to receipt icon if not found
    // Force refresh issue - standardize the category name to check
    final String normalizedCategory = _normalizeCategory(category);
    final IconData categoryIcon = categoryIcons[normalizedCategory] ?? Icons.receipt;
    
    // Get category color from theme system
    final Color iconColor = AppThemeHelpers.getCategoryColor(isDark, category);
    final Color iconBgColor = iconColor.withOpacity(0.2);
    
    // Use accent colors for expense/income indication
    final Color amountColor = transaction.type == model.TransactionType.expense
      ? AppThemeHelpers.getAccentRed(isDark) // Use red accent for expenses
      : AppThemeHelpers.getAccentGreen(isDark); // Use green accent for income
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                categoryIcon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
            // Transaction details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: AppThemeHelpers.getBodyStyle(isDark).copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppThemeHelpers.getPrimaryColor(isDark),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormat.format(transaction.date),
                    style: AppThemeHelpers.getSmallStyle(isDark).copyWith(
                      color: isDark
                          ? AppColors.darkSecondaryText
                          : AppColors.lightSecondaryText,
                    ),
                  ),
                ],
              ),
            ),
            
            // Add padding between description and amount
            const SizedBox(width: 16),
            
            // Amount and category
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(transaction.amount),
                  style: AppThemeHelpers.getBodyStyle(isDark).copyWith(
                    fontWeight: FontWeight.w600,
                    color: amountColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: AppThemeHelpers.getSmallStyle(isDark).copyWith(
                    color: isDark
                        ? AppColors.darkSecondaryText
                        : AppColors.lightSecondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper to normalize category names for icon lookup
  String _normalizeCategory(String category) {
    // Handle possible alternate forms/variations of category names
    switch (category.toLowerCase()) {
      case 'health':
        return 'Healthcare';
      case 'transport':
        return 'Transportation';
      default:
        return category;
    }
  }
} 