import 'package:flutter/material.dart';
import 'package:spending_income/common/widgets/app_modal.dart';
import 'package:spending_income/models/transaction.dart';
import 'package:spending_income/screens/transactions/add_transaction/multi_transaction_standalone.dart';
import 'package:uuid/uuid.dart';

/// A simple test screen to demonstrate the multi-transaction review functionality
class MultiTransactionTest extends StatefulWidget {
  const MultiTransactionTest({super.key});

  @override
  State<MultiTransactionTest> createState() => _MultiTransactionTestState();
}

class _MultiTransactionTestState extends State<MultiTransactionTest> {
  // Mock transactions for testing
  List<Transaction> _mockTransactions = [];

  @override
  void initState() {
    super.initState();
    _generateMockTransactions();
  }

  // Generate mock transactions for testing
  void _generateMockTransactions() {
    _mockTransactions = [
      Transaction(
        id: const Uuid().v4(),
        amount: 2500.00,
        type: TransactionType.expense,
        category: 'Transport',
        date: DateTime.now().subtract(const Duration(hours: 5)),
        description: 'Taxi fare to work',
        userId: 'temp-user-id',
        vendorOrSource: 'Uber',
      ),
      Transaction(
        id: const Uuid().v4(),
        amount: 1200.00,
        type: TransactionType.expense,
        category: 'Food',
        date: DateTime.now().subtract(const Duration(days: 1)),
        description: 'Lunch at restaurant',
        userId: 'temp-user-id',
        vendorOrSource: 'Food Court',
      ),
      Transaction(
        id: const Uuid().v4(),
        amount: 15000.00,
        type: TransactionType.income,
        category: 'Freelance',
        date: DateTime.now().subtract(const Duration(days: 2)),
        description: 'Website development payment',
        userId: 'temp-user-id',
        vendorOrSource: 'Client XYZ',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi-Transaction Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'This screen allows testing of the multi-transaction review component',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showMultiTransactionReview(),
              child: const Text('Show Multi-Transaction Review'),
            ),
          ],
        ),
      ),
    );
  }

  // Show the multi-transaction review as a modal using our reusable AppModal
  void _showMultiTransactionReview() {
    AppModal.show(
      context: context,
      title: 'Review Transactions',
      height: 0.8, // Slightly taller than default for more space
      builder: (context) => MultiTransactionStandalone(
        transactions: _mockTransactions,
        onTransactionsConfirmed: (transactions) {
          // Just display a confirmation for testing
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${transactions.length} transactions saved'),
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        },
        onCancelReview: () {
          Navigator.pop(context);
        },
        onAllTransactionsRemoved: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All transactions removed'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
}

// Helper method to run the test from anywhere in the app
void showMultiTransactionTest(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => const MultiTransactionTest(),
    ),
  );
}
