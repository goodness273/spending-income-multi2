import 'package:flutter/material.dart';
// import 'package:spending_income/common/widgets/app_modal.dart';
import 'package:spending_income/models/transaction.dart';
import 'package:spending_income/screens/transactions/add_transaction/modal_transaction_item.dart';
import 'package:spending_income/screens/transactions/add_transaction/add_transaction_modal.dart';
import 'package:spending_income/utils/app_theme/colors.dart';
import 'package:spending_income/utils/app_theme/helpers.dart';
import 'package:spending_income/utils/constants.dart';

/// Standalone multi-transaction review component that doesn't rely on AddTransactionModal
class MultiTransactionStandalone extends StatefulWidget {
  final List<Transaction> transactions;
  final Function(List<Transaction>) onTransactionsConfirmed;
  final Function() onCancelReview;
  final Function() onAllTransactionsRemoved;

  const MultiTransactionStandalone({
    super.key,
    required this.transactions,
    required this.onTransactionsConfirmed,
    required this.onCancelReview,
    required this.onAllTransactionsRemoved,
  });

  @override
  State<MultiTransactionStandalone> createState() => _MultiTransactionStandaloneState();
}

class _MultiTransactionStandaloneState extends State<MultiTransactionStandalone> {
  late List<Transaction> _editableTransactions;

  @override
  void initState() {
    super.initState();
    _editableTransactions = List.from(widget.transactions);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // If no transactions left, return to chat
    if (_editableTransactions.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onAllTransactionsRemoved();
      });
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        
        Text(
          AppStrings.aiDetectedTransactions.replaceFirst('%d', _editableTransactions.length.toString()),
          style: AppThemeHelpers.getSubheadingStyle(isDarkMode),
        ),
        SizedBox(height: AppConstants.spacingMedium),
        
        Expanded(
          child: ListView.builder(
            itemCount: _editableTransactions.length,
            itemBuilder: (context, index) {
              final transaction = _editableTransactions[index];
              
              return InkWell(
                onTap: () {
                  // Open standalone transaction edit modal
                  _editTransaction(transaction, index);
                },
                child: ModalTransactionItem(
                  transaction: transaction,
                  isDark: isDarkMode,
                  dateFormat: AppConstants.shortDateFormat,
                  currencyFormat: AppConstants.currencyFormat(),
                  onTap: () => _editTransaction(transaction, index),
                ),
              );
            },
          ),
        ),
        
        Padding(
          padding: EdgeInsets.only(top: AppConstants.paddingLarge),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancelReview,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppThemeHelpers.getPrimaryTextColor(isDarkMode),
                    side: BorderSide(
                      color: AppThemeHelpers.getDividerColor(isDarkMode),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    ),
                    padding: EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
                  ),
                  child: Text(AppStrings.cancel),
                ),
              ),
              SizedBox(width: AppConstants.spacingMedium),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => widget.onTransactionsConfirmed(_editableTransactions),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemeHelpers.getPrimaryColor(isDarkMode),
                    foregroundColor: isDarkMode ? AppColors.primaryBlack : AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    ),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
                  ),
                  child: Text(AppStrings.saveAll),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  


  void _editTransaction(Transaction transaction, int index) {
    AddTransactionModal.show(
      context,
      (Transaction updatedTransaction) {
        setState(() {
          // If the returned transaction is unchanged, treat it as a delete signal
          final isDelete =
              updatedTransaction.id == transaction.id &&
              updatedTransaction.amount == transaction.amount &&
              updatedTransaction.date == transaction.date &&
              updatedTransaction.description == transaction.description;

          if (isDelete) {
            _editableTransactions.removeAt(index);
          } else {
            _editableTransactions[index] = updatedTransaction;
          }
        });
      },
      initialTransaction: transaction,
    );
  }
  
  // Confirm before deleting a transaction
  void _confirmDeleteTransaction(BuildContext context, int index) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Remove Transaction',
          style: AppThemeHelpers.getBodyStyle(isDarkMode).copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        content: Text(
          'Are you sure you want to remove this transaction?',
          style: AppThemeHelpers.getBodyStyle(isDarkMode),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _editableTransactions.removeAt(index);
              });
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
  
  // Get category options based on transaction type
  List<String> _getCategoryOptions(TransactionType type) {
    List<String> categories;
    
    if (type == TransactionType.income) {
      // Create a new list to avoid modifying the original
      categories = List<String>.from(AppConstants.incomeCategories);
    } else {
      // Create a new list to avoid modifying the original
      categories = List<String>.from(AppConstants.expenseCategories);
    }
    
    // Ensure categories are unique by converting to a Set and back to List
    return categories.toSet().toList();
  }
}
