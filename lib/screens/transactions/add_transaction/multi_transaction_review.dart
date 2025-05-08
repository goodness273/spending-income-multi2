import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spending_income/models/transaction.dart';
import 'package:spending_income/utils/app_theme/colors.dart';
import 'package:spending_income/utils/app_theme/helpers.dart';
import 'package:spending_income/utils/app_theme/button_styles.dart';
import 'add_transaction_modal.dart';

/// Widget for reviewing and handling multiple transactions detected by AI
class MultiTransactionReview extends StatefulWidget {
  final List<Transaction> transactions;
  final Function(List<Transaction>) onTransactionsConfirmed;
  final Function() onCancelReview;
  final Function() onAllTransactionsRemoved;

  const MultiTransactionReview({
    super.key,
    required this.transactions,
    required this.onTransactionsConfirmed,
    required this.onCancelReview,
    required this.onAllTransactionsRemoved,
  });

  @override
  State<MultiTransactionReview> createState() => _MultiTransactionReviewState();
}

class _MultiTransactionReviewState extends State<MultiTransactionReview> {
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
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            'Review Transactions',
            style: AppThemeHelpers.getTitleStyle(isDarkMode),
            textAlign: TextAlign.center,
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            'AI detected ${_editableTransactions.length} transactions. Tap any transaction to edit.',
            style: AppThemeHelpers.getSubheadingStyle(isDarkMode),
          ),
        ),
        
        Expanded(
          child: ListView.builder(
            itemCount: _editableTransactions.length,
            itemBuilder: (context, index) {
              final transaction = _editableTransactions[index];
              final formattedDate = DateFormat('MMM d, yyyy').format(transaction.date);
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: AppThemeHelpers.getDividerColor(isDarkMode),
                    width: 1,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    // Open transaction edit modal with back button
                    _editTransaction(transaction, index);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category icon
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppThemeHelpers.getCategoryColor(isDarkMode, transaction.category).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getCategoryIcon(transaction.category, transaction.type),
                            color: AppThemeHelpers.getCategoryColor(isDarkMode, transaction.category),
                            size: 24,
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Transaction details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Amount & Type
                              Text(
                                '${transaction.type == TransactionType.expense ? "Spent" : "Received"} ₦${transaction.amount.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              
                              const SizedBox(height: 4),
                              
                              // Date
                              Text(
                                formattedDate,
                                style: AppThemeHelpers.getSmallStyle(isDarkMode),
                              ),
                              
                              const SizedBox(height: 8),
                              
                              // Category
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppThemeHelpers.getCategoryColor(isDarkMode, transaction.category).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      transaction.category,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppThemeHelpers.getCategoryColor(isDarkMode, transaction.category),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 4),
                              
                              // Description
                              Text(
                                transaction.description,
                                style: AppThemeHelpers.getBodyStyle(isDarkMode),
                              ),
                              
                              // Vendor/Source if available
                              if (transaction.vendorOrSource != null && transaction.vendorOrSource!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Vendor: ${transaction.vendorOrSource}',
                                    style: AppThemeHelpers.getSmallStyle(isDarkMode),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        
                        // Delete button
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            _confirmDeleteTransaction(context, index);
                          },
                          tooltip: 'Remove transaction',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        ElevatedButton.icon(
          icon: const Icon(Icons.check_circle_outlined),
          label: Text(_editableTransactions.length > 1 
              ? 'Save All Transactions' 
              : 'Save Transaction'),
          style: AppButtonStyles.getPrimaryButtonStyle(context),
          onPressed: _editableTransactions.isNotEmpty
              ? () {
                  widget.onTransactionsConfirmed(_editableTransactions);
                }
              : null,
        ),
        
        const SizedBox(height: 8),
        
        TextButton(
          onPressed: widget.onCancelReview,
          child: const Text('Cancel'),
        ),
        
        const SizedBox(height: 16),
      ],
    );
  }

  // Show delete confirmation dialog
  void _confirmDeleteTransaction(BuildContext context, int index) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Transaction'),
        content: const Text('Are you sure you want to remove this transaction from the list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppThemeHelpers.getSecondaryTextColor(isDarkMode),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _editableTransactions.removeAt(index);
              });
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
  
  // Handle editing a transaction in the list
  void _editTransaction(Transaction transaction, int index) {
    // Use a WillPopScope to prevent accidental loss of multi-transaction state
    final navigatorKey = GlobalKey<NavigatorState>();
    
    // Create a Navigator with WillPopScope to handle back button
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => WillPopScope(
          onWillPop: () async {
            // Return to the multi-transaction review without saving changes
            Navigator.of(context).pop();
            return false; // Prevent default back behavior
          },
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_outlined),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Back to transactions',
              ),
              title: const Text('Edit Transaction'),
              elevation: 0,
            ),
            body: Navigator(
              key: navigatorKey,
              onGenerateRoute: (_) => MaterialPageRoute(
                builder: (_) => Builder(
                  builder: (innerContext) {
                    // We need to wrap in a builder to get the correct context for showing the modal
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      // Show the transaction modal after the page is built
                      AddTransactionModal.show(
                        innerContext,
                        (updatedTransaction) {
                          // Update the transaction in our list
                          setState(() {
                            _editableTransactions[index] = updatedTransaction;
                          });
                          // Return to multi-transaction view
                          Navigator.of(context).pop();
                        },
                        initialTransaction: transaction,
                      );
                    });
                    return Container(); // Placeholder for the navigator route
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  // Get outlined icon for category (following user preference for outlined icons)
  IconData _getCategoryIcon(String category, TransactionType type) {
    if (type == TransactionType.income) {
      switch (category.toLowerCase()) {
        case 'salary':
          return Icons.account_balance_outlined;
        case 'freelance':
          return Icons.work_outline;
        case 'investment':
          return Icons.trending_up_outlined;
        case 'returns':
          return Icons.loop_outlined;
        case 'repayments':
          return Icons.swap_horiz_outlined;
        case 'gift':
          return Icons.card_giftcard_outlined;
        default:
          return Icons.attach_money_outlined;
      }
    }
    
    // Expense categories - all using outlined icons as per user preference
    switch (category.toLowerCase()) {
      case 'food':
      case 'food & dining':
        return Icons.restaurant_outlined;
      case 'transport':
      case 'transportation':
        return Icons.directions_car_outlined;
      case 'utilities':
        return Icons.power_outlined;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'health':
      case 'healthcare':
        return Icons.health_and_safety_outlined;
      case 'entertainment':
        return Icons.movie_outlined;
      case 'education':
        return Icons.school_outlined;
      case 'savings':
        return Icons.savings_outlined;
      case 'lending':
        return Icons.handshake_outlined;
      default:
        return Icons.category_outlined;
    }
  }
}
