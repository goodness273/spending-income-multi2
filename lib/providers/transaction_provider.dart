import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/transaction_service.dart';
import '../models/transaction.dart';
import 'auth_provider.dart';

// Transaction service provider
final transactionServiceProvider = Provider<TransactionService>((ref) {
  return TransactionService();
});

// Transactions stream provider
final transactionsProvider = StreamProvider.autoDispose<List<Transaction>>((
  ref,
) {
  final transactionService = ref.watch(transactionServiceProvider);
  final user = ref.watch(authStateProvider).value;

  if (user == null) {
    return Stream.value([]);
  }

  return transactionService.getTransactions(user.uid);
});

// Transactions by date range provider
final transactionsByDateRangeProvider = StreamProvider.autoDispose
    .family<List<Transaction>, ({DateTime startDate, DateTime endDate})>((
      ref,
      dateRange,
    ) {
      final transactionService = ref.watch(transactionServiceProvider);
      final user = ref.watch(authStateProvider).value;

      if (user == null) {
        return Stream.value([]);
      }

      return transactionService.getTransactionsForDateRange(
        user.uid,
        dateRange.startDate,
        dateRange.endDate,
      );
    });

// Transactions by type provider
final transactionsByTypeProvider = StreamProvider.autoDispose
    .family<List<Transaction>, TransactionType>((ref, type) {
      final transactionService = ref.watch(transactionServiceProvider);
      final user = ref.watch(authStateProvider).value;

      if (user == null) {
        return Stream.value([]);
      }

      return transactionService.getTransactionsByType(user.uid, type);
    });

// Transactions by category provider
final transactionsByCategoryProvider = StreamProvider.autoDispose
    .family<List<Transaction>, String>((ref, category) {
      final transactionService = ref.watch(transactionServiceProvider);
      final user = ref.watch(authStateProvider).value;

      if (user == null) {
        return Stream.value([]);
      }

      return transactionService.getTransactionsByCategory(user.uid, category);
    });

// Transaction summary provider
final transactionSummaryProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, ({DateTime startDate, DateTime endDate})>((
      ref,
      dateRange,
    ) async {
      final transactionService = ref.watch(transactionServiceProvider);
      final user = ref.watch(authStateProvider).value;

      if (user == null) {
        return {
          'totalExpense': 0.0,
          'totalIncome': 0.0,
          'balance': 0.0,
          'categoryExpenses': <String, double>{},
        };
      }

      return transactionService.getTransactionSummary(
        user.uid,
        dateRange.startDate,
        dateRange.endDate,
      );
    });



