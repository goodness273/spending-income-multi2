import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction.dart' as model;

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference
  CollectionReference get _transactionsCollection =>
      _firestore.collection('transactions');

  // Add a new transaction
  Future<model.Transaction> addTransaction(
    model.Transaction transaction,
  ) async {
    try {
      await _transactionsCollection
          .doc(transaction.id)
          .set(transaction.toMap());
      return transaction;
    } catch (e) {
      rethrow;
    }
  }

  // Get all transactions for a user
  Stream<List<model.Transaction>> getTransactions(String userId) {
    return _transactionsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => model.Transaction.fromFirestore(doc))
                  .toList(),
        );
  }

  // Get transactions for a specific date range
  Stream<List<model.Transaction>> getTransactionsForDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _transactionsCollection
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => model.Transaction.fromFirestore(doc))
                  .toList(),
        );
  }

  // Get transactions by type (expense/income)
  Stream<List<model.Transaction>> getTransactionsByType(
    String userId,
    model.TransactionType type,
  ) {
    String typeStr = type.toString().split('.').last;
    return _transactionsCollection
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: typeStr)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => model.Transaction.fromFirestore(doc))
                  .toList(),
        );
  }

  // Get transactions by category
  Stream<List<model.Transaction>> getTransactionsByCategory(
    String userId,
    String category,
  ) {
    return _transactionsCollection
        .where('userId', isEqualTo: userId)
        .where('category', isEqualTo: category)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => model.Transaction.fromFirestore(doc))
                  .toList(),
        );
  }

  // Update an existing transaction
  Future<void> updateTransaction(model.Transaction transaction) async {
    try {
      await _transactionsCollection
          .doc(transaction.id)
          .update(transaction.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Delete a transaction
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _transactionsCollection.doc(transactionId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Get transaction summary for a specific date range
  Future<Map<String, dynamic>> getTransactionSummary(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      QuerySnapshot expenseSnapshot =
          await _transactionsCollection
              .where('userId', isEqualTo: userId)
              .where('type', isEqualTo: 'expense')
              .where(
                'date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
              )
              .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
              .get();

      QuerySnapshot incomeSnapshot =
          await _transactionsCollection
              .where('userId', isEqualTo: userId)
              .where('type', isEqualTo: 'income')
              .where(
                'date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
              )
              .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
              .get();

      double totalExpense = 0.0;
      double totalIncome = 0.0;
      Map<String, double> categoryExpenses = {};

      // Calculate total expenses and category breakdown
      for (var doc in expenseSnapshot.docs) {
        model.Transaction transaction = model.Transaction.fromFirestore(doc);
        totalExpense += transaction.amount;

        // Add to category summary
        if (categoryExpenses.containsKey(transaction.category)) {
          categoryExpenses[transaction.category] =
              (categoryExpenses[transaction.category] ?? 0) +
              transaction.amount;
        } else {
          categoryExpenses[transaction.category] = transaction.amount;
        }
      }

      // Calculate total income
      for (var doc in incomeSnapshot.docs) {
        model.Transaction transaction = model.Transaction.fromFirestore(doc);
        totalIncome += transaction.amount;
      }

      return {
        'totalExpense': totalExpense,
        'totalIncome': totalIncome,
        'balance': totalIncome - totalExpense,
        'categoryExpenses': categoryExpenses,
      };
    } catch (e) {
      rethrow;
    }
  }
}
