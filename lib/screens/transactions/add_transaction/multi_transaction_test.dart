import 'package:flutter/material.dart';
import 'package:spending_income/models/transaction.dart';
import 'multi_transaction_standalone.dart';

/// Shows a test modal for the multi-transaction feature
void showMultiTransactionTest(BuildContext context) {
  // Sample transactions for testing
  final List<Transaction> testTransactions = [
    Transaction(
      id: '1',
      amount: 25.99,
      type: TransactionType.expense,
      category: 'Food',
      date: DateTime.now(),
      description: 'Lunch at restaurant',
      userId: 'test-user',
      vendorOrSource: 'Local Restaurant',
    ),
    Transaction(
      id: '2',
      amount: 9.99,
      type: TransactionType.expense,
      category: 'Entertainment',
      date: DateTime.now().subtract(const Duration(days: 1)),
      description: 'Movie subscription',
      userId: 'test-user',
      vendorOrSource: 'Streaming Service',
    ),
    Transaction(
      id: '3',
      amount: 500.00,
      type: TransactionType.income,
      category: 'Salary',
      date: DateTime.now().subtract(const Duration(days: 2)),
      description: 'Monthly salary',
      userId: 'test-user',
      vendorOrSource: 'Employer',
    ),
  ];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.6,
        builder: (_, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Title
                Text(
                  'Multi-Transaction Test',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                // Multi-transaction component
                Expanded(
                  child: MultiTransactionStandalone(
                    transactions: testTransactions,
                    onTransactionsConfirmed: (transactions) {
                      Navigator.pop(context);
                      // Show a snackbar with the number of transactions
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${transactions.length} transactions confirmed'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    onCancelReview: () {
                      Navigator.pop(context);
                    },
                    onAllTransactionsRemoved: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All transactions removed'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
