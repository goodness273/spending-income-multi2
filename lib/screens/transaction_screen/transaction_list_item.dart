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
  
  // Category icons map
  static final Map<String, IconData> categoryIcons = {
    'Food & Dining': Icons.restaurant,
    'Transportation': Icons.directions_car,
    'Housing': Icons.home,
    'Entertainment': Icons.movie,
    'Utilities': Icons.power,
    'Healthcare': Icons.medical_services,
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
    final String paymentMethod = transaction.vendorOrSource ?? 'Cash'; // Default to Cash
    
    // Get category icon
    IconData categoryIcon = categoryIcons[transaction.category] ?? Icons.receipt;
    
    // Determine icon background color based on category
    Color iconBgColor;
    if (transaction.category == 'Food & Dining') {
      iconBgColor = Colors.orange.withOpacity(0.2);
    } else if (transaction.category == 'Transportation') {
      iconBgColor = Colors.purple.withOpacity(0.2);
    } else if (transaction.category == 'Shopping') {
      iconBgColor = Colors.pink.withOpacity(0.2);
    } else {
      iconBgColor = Colors.blue.withOpacity(0.2);
    }
    
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
                color: iconBgColor.withOpacity(1),
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
                    ),
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
            
            // Amount and payment method
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(transaction.amount),
                  style: AppThemeHelpers.getBodyStyle(isDark).copyWith(
                    fontWeight: FontWeight.w600,
                    color: isExpense 
                        ? const Color(0xFFE57373) // Light red for expenses
                        : const Color(0xFF81C784), // Light green for income
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  paymentMethod,
                  style: AppThemeHelpers.getSmallStyle(isDark).copyWith(
                    color: isDark
                        ? AppColors.darkSecondaryText
                        : AppColors.lightSecondaryText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 