import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spending_income/models/transaction.dart';
import 'package:spending_income/screens/transaction_screen/transaction_list_item.dart';
import 'package:spending_income/utils/app_theme/colors.dart';
import 'package:spending_income/utils/app_theme/helpers.dart';

/// A wrapper for TransactionListItem that removes horizontal padding
/// for use within modals that already provide their own padding
class ModalTransactionItem extends StatelessWidget {
  final Transaction transaction;
  final bool isDark;
  final DateFormat dateFormat;
  final NumberFormat currencyFormat;
  final VoidCallback onTap;

  const ModalTransactionItem({
    super.key,
    required this.transaction,
    required this.isDark,
    required this.dateFormat,
    required this.currencyFormat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Use the standard TransactionListItem but remove its horizontal padding
    return InkWell(
      onTap: onTap,
      child: Padding(
        // Keep vertical padding but remove horizontal padding
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
        child: TransactionListItemContent(
          transaction: transaction,
          isDark: isDark,
          dateFormat: dateFormat,
          currencyFormat: currencyFormat,
        ),
      ),
    );
  }
}

/// The inner content of a TransactionListItem without the padding and InkWell
/// This allows reusing the exact same styling but without the padding
class TransactionListItemContent extends StatelessWidget {
  final Transaction transaction;
  final bool isDark;
  final DateFormat dateFormat;
  final NumberFormat currencyFormat;

  // Category icons map with fixed mappings for core categories
  static final Map<String, IconData> categoryIcons = TransactionListItem.categoryIcons;

  const TransactionListItemContent({
    super.key,
    required this.transaction,
    required this.isDark,
    required this.dateFormat,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final String category = transaction.category.isNotEmpty ? transaction.category : 'Other'; // Default to Other
    
    // Get category icon or default to receipt icon if not found
    final String normalizedCategory = _normalizeCategory(category);
    final IconData categoryIcon = categoryIcons[normalizedCategory] ?? Icons.receipt_outlined;
    
    // Get category color from theme system
    final Color iconColor = AppThemeHelpers.getCategoryColor(isDark, category);
    final Color iconBgColor = iconColor.withOpacity(0.2);
    
    // Use accent colors for expense/income indication
    final Color amountColor = transaction.type == TransactionType.expense
      ? AppThemeHelpers.getAccentRed(isDark) // Use red accent for expenses
      : AppThemeHelpers.getAccentGreen(isDark); // Use green accent for income
    
    return Row(
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
    );
  }
  
  // Helper to normalize category names for icon lookup (copied from TransactionListItem)
  String _normalizeCategory(String category) {
    // Handle possible alternate forms/variations of category names
    switch (category.toLowerCase()) {
      case 'health':
        return 'Health';
      case 'healthcare':
        return 'Health';
      case 'transport':
        return 'Transport';
      case 'transportation':
        return 'Transport';
      case 'food':
        return 'Food';
      case 'food & dining':
        return 'Food';
      case 'gift':
        return 'Gift';
      case 'gifts':
        return 'Gift';
      case 'freelance':
        return 'Freelance';
      case 'savings':
        return 'Savings';
      case 'saving':
        return 'Savings';
      case 'lending':
        return 'Lending';
      case 'lend':
        return 'Lending';
      case 'returns':
        return 'Returns';
      case 'return':
        return 'Returns';
      case 'repayments':
        return 'Repayments';
      case 'repayment':
        return 'Repayments';
      default:
        return category;
    }
  }
}
