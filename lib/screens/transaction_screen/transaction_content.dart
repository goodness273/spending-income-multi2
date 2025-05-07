import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spending_income/models/transaction.dart' as model;
import 'package:spending_income/screens/transaction_screen/transaction_list_item.dart';
import 'package:spending_income/utils/app_theme/index.dart';

/// A non-scrollable version of the transaction list that can be embedded in a ListView
class TransactionContent extends StatelessWidget {
  final List<model.Transaction> transactions;
  final bool isDark;
  final DateFormat dateFormat;
  final NumberFormat currencyFormat;
  final Function(model.Transaction) onTransactionTap;
  final Function(model.Transaction)? onTransactionDelete;

  const TransactionContent({
    super.key,
    required this.transactions,
    required this.isDark,
    required this.dateFormat,
    required this.currencyFormat,
    required this.onTransactionTap,
    this.onTransactionDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('No transactions found'),
        ),
      );
    }
    
    // Sort transactions by date, newest first
    final sortedTransactions = List<model.Transaction>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    
    // Group transactions by date
    final Map<String, List<model.Transaction>> groupedTransactions = {};
    for (final transaction in sortedTransactions) {
      final dateString = DateFormat('MMMM dd, yyyy').format(transaction.date);
      groupedTransactions.putIfAbsent(dateString, () => []);
      groupedTransactions[dateString]!.add(transaction);
    }
    
    // Create the transaction list content
    final List<Widget> content = [];
    
    int index = 0;
    for (final dateString in groupedTransactions.keys) {
      final transactionsForDate = groupedTransactions[dateString]!;
      
      // Add date header
      content.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Text(
            dateString,
            style: AppThemeHelpers.getSubheadingStyle(isDark).copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
            ),
          ),
        ),
      );
      
      // Add transaction items for this date
      for (final transaction in transactionsForDate) {
        content.add(
          Dismissible(
            key: Key(transaction.id),
            direction: DismissDirection.endToStart,
            background: Container(
              color: AppThemeHelpers.getAccentRed(isDark),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: Icon(
                Icons.delete,
                color: AppColors.white,
              ),
            ),
            onDismissed: (direction) {
              if (onTransactionDelete != null) {
                onTransactionDelete!(transaction);
              }
            },
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Confirm"),
                    content: const Text("Are you sure you want to delete this transaction?"),
                    actions: [
                      TextButton(
                        child: const Text("Cancel"),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      TextButton(
                        child: const Text("Delete"),
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ],
                  );
                },
              );
            },
            child: TransactionListItem(
              transaction: transaction,
              isDark: isDark,
              dateFormat: dateFormat,
              currencyFormat: currencyFormat,
              onTap: () => onTransactionTap(transaction),
            ),
          ),
        );
      }
      
      // Add divider after each date group except the last one
      if (index < groupedTransactions.length - 1) {
        content.add(Divider(
          height: 24, 
          thickness: 1, 
          color: AppThemeHelpers.getDividerColor(isDark),
        ));
      }
      
      index++;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: content,
    );
  }
} 