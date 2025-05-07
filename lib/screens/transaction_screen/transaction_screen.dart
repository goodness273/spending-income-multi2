import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:spending_income/models/transaction.dart' as model;
import 'package:spending_income/providers/transaction_provider.dart';
import 'package:spending_income/utils/app_theme/index.dart';
import 'package:spending_income/screens/transactions/add_transaction/add_transaction_modal.dart';

import 'expense_chart.dart';
import 'transaction_list.dart';
import 'empty_state.dart';
import 'utils.dart';

class TransactionScreen extends ConsumerStatefulWidget {
  const TransactionScreen({super.key});

  @override
  ConsumerState<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends ConsumerState<TransactionScreen> with SingleTickerProviderStateMixin {
  // Tab controller
  late TabController _tabController;
  
  // Filters and date range
  String? _selectedTimePeriod;
  DateTime? _startDate;
  DateTime? _endDate;
  String _currentTimeFilter = 'Monthly';
  
  // Formatters
  final DateFormat _dateFormat = DateFormat('dd MMM, yyyy');
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '₦', decimalDigits: 2);
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Default to monthly view
    _updateDateRange();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _updateDateRange() {
    updateDateRange(
      _selectedTimePeriod, 
      () => DateTime.now(),
      (start, end) {
        setState(() {
          _startDate = start;
          _endDate = end;
        });
      }
    );
  }
  
  void _handleTimeFilterChanged(String newValue) {
    setState(() {
      _currentTimeFilter = newValue;
      _selectedTimePeriod = mapTimeFilterToPeriod(newValue);
      _updateDateRange();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Base transactions stream
    final transactions = _selectedTimePeriod != null && _startDate != null && _endDate != null
        ? ref.watch(transactionsByDateRangeProvider((startDate: _startDate!, endDate: _endDate!)))
        : ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'History',
          style: AppThemeHelpers.getHeadingStyle(isDark),
        ),
        backgroundColor: AppThemeHelpers.getBackgroundColor(isDark),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            // Navigate back if needed or handle back action
          },
        ),
      ),
      body: transactions.when(
        data: (transactionsList) {
          if (transactionsList.isEmpty) {
            return EmptyState(
              isDark: isDark, 
              hasFilters: _selectedTimePeriod != null,
            );
          }

          // Get transactions grouped by month for chart
          final groupedByMonth = groupTransactionsByMonth(transactionsList);
          
          return Column(
            children: [
              // Expense chart section
              ExpenseChart(
                monthlyData: groupedByMonth,
                isDark: isDark,
                currencyFormat: _currencyFormat,
                currentTimeFilter: _currentTimeFilter,
                onTimeFilterChanged: _handleTimeFilterChanged,
              ),
              
              const SizedBox(height: 10),
              
              // Transactions header with "View all" button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transactions',
                      style: AppThemeHelpers.getSubheadingStyle(isDark),
                    ),
                    TextButton(
                      onPressed: () {
                        // Show all transactions - clear filters
                        setState(() {
                          _selectedTimePeriod = null;
                          _startDate = null;
                          _endDate = null;
                          _currentTimeFilter = 'Monthly';
                        });
                      },
                      child: Text(
                        'View all',
                        style: AppThemeHelpers.getBodyStyle(isDark).copyWith(
                          color: isDark 
                              ? AppColors.darkSecondaryText 
                              : AppColors.lightSecondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Tab bar for transaction types
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Spends'),
                  Tab(text: 'Others'),
                ],
                indicatorColor: AppThemeHelpers.getPrimaryColor(isDark),
                labelColor: AppThemeHelpers.getPrimaryColor(isDark),
                unselectedLabelColor: isDark 
                    ? AppColors.darkSecondaryText 
                    : AppColors.lightSecondaryText,
              ),
              
              // Transaction lists in tabs
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Spends tab - show expense transactions
                    TransactionList(
                      transactions: transactionsList
                          .where((t) => t.type == model.TransactionType.expense)
                          .toList(),
                      isDark: isDark,
                      dateFormat: _dateFormat,
                      currencyFormat: _currencyFormat,
                      onTransactionTap: _handleTransactionTap,
                    ),
                    
                    // Others tab - show income transactions
                    TransactionList(
                      transactions: transactionsList
                          .where((t) => t.type == model.TransactionType.income)
                          .toList(),
                      isDark: isDark,
                      dateFormat: _dateFormat,
                      currencyFormat: _currencyFormat,
                      onTransactionTap: _handleTransactionTap,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(
            'Error loading transactions: $error',
            style: AppThemeHelpers.getBodyStyle(isDark),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
  
  void _handleTransactionTap(model.Transaction transaction) {
    // Edit transaction
    AddTransactionModal.show(
      context,
      (model.Transaction updatedTransaction) {
        // Check if this is a delete request (returned transaction is unchanged)
        if (updatedTransaction.id == transaction.id && 
            updatedTransaction.amount == transaction.amount &&
            updatedTransaction.date == transaction.date &&
            updatedTransaction.description == transaction.description) {
          // This is a delete request
          ref.read(transactionServiceProvider).deleteTransaction(transaction.id);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction deleted'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          // This is an update request
          final updated = updatedTransaction.copyWith(
            id: transaction.id,
            userId: transaction.userId,
          );
          ref.read(transactionServiceProvider).updateTransaction(updated);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction updated'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      initialTransaction: transaction,
    );
  }
} 