import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spending_income/models/transaction.dart' as model;
import 'package:spending_income/providers/transaction_provider.dart';
import 'package:spending_income/utils/app_theme/index.dart';
import 'package:spending_income/screens/transactions/add_transaction/add_transaction_modal.dart';

import 'transaction_list.dart';
import 'transaction_content.dart';
import 'empty_state.dart';
import 'utils.dart';

// Filter mode enum
enum FilterMode { all, expenses, income }

class TransactionScreen extends ConsumerStatefulWidget {
  const TransactionScreen({super.key});

  @override
  ConsumerState<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends ConsumerState<TransactionScreen> {
  // Current filter mode
  FilterMode _currentFilterMode = FilterMode.all;
  
  // Filters and date range
  String? _selectedTimePeriod;
  DateTime? _startDate;
  DateTime? _endDate;
  String _currentTimeFilter = 'Monthly';
  
  // Formatters
  final DateFormat _dateFormat = DateFormat('dd MMM, yyyy');
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '₦', decimalDigits: 2);
  
  // Tooltip indicator control
  int? _selectedBarIndex;
  
  @override
  void initState() {
    super.initState();
    // Default to monthly view
    _updateDateRange();
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

  // Get the subtitle based on current filter mode
  String _getSubtitle() {
    switch (_currentFilterMode) {
      case FilterMode.all:
        return 'All Transactions';
      case FilterMode.expenses:
        return 'All Expenses';
      case FilterMode.income:
        return 'All Income';
    }
  }

  // Calculate the total amount based on filter mode
  double _calculateTotal(List<model.Transaction> transactions) {
    switch (_currentFilterMode) {
      case FilterMode.all:
        final totalIncome = transactions
            .where((t) => t.type == model.TransactionType.income)
            .fold(0.0, (sum, t) => sum + t.amount);
        final totalExpense = transactions
            .where((t) => t.type == model.TransactionType.expense)
            .fold(0.0, (sum, t) => sum + t.amount);
        return totalIncome - totalExpense;
      case FilterMode.expenses:
        return transactions
            .where((t) => t.type == model.TransactionType.expense)
            .fold(0.0, (sum, t) => sum + t.amount);
      case FilterMode.income:
        return transactions
            .where((t) => t.type == model.TransactionType.income)
            .fold(0.0, (sum, t) => sum + t.amount);
    }
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
        title: Row(
          children: [
            SvgPicture.asset(
              'assets/Icons/Transactions selected.svg',
              width: 28,
              height: 28,
              colorFilter: ColorFilter.mode(
                AppThemeHelpers.getPrimaryColor(isDark), 
                BlendMode.srcIn
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Transactions',
              style: AppThemeHelpers.getHeadingStyle(isDark),
            ),
          ],
        ),
        backgroundColor: AppThemeHelpers.getBackgroundColor(isDark),
        elevation: 0,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
            child: _buildFilterToggle(isDark),
          ),
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

          // Filter transactions based on current mode
          final filteredTransactions = _filterTransactions(transactionsList);

          // Get transactions grouped by month for chart
          final groupedByMonth = groupTransactionsByMonth(filteredTransactions);
          
          // Calculate total for header
          final totalAmount = _calculateTotal(filteredTransactions);
          
          return Column(
            children: [
              // Expanded area with single scrollable content
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // Expense chart section
                    _buildExpenseCard(groupedByMonth, totalAmount, isDark),
                    
                    // Add spacing between chart and transaction list
                    const SizedBox(height: 16),
                    
                    // Transaction list embedded
                    TransactionContent(
                      key: ValueKey(_currentFilterMode),
                      transactions: filteredTransactions,
                      isDark: isDark,
                      dateFormat: _dateFormat,
                      currencyFormat: _currencyFormat,
                      onTransactionTap: _handleTransactionTap,
                      onTransactionDelete: _handleTransactionDelete,
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

  Widget _buildFilterToggle(bool isDark) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : AppColors.lightGray,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // All
          Expanded(
            child: _buildToggleButton(
              title: 'All',
              isActive: _currentFilterMode == FilterMode.all,
              isDark: isDark,
              onTap: () => setState(() => _currentFilterMode = FilterMode.all),
            ),
          ),
          // Expenses
          Expanded(
            child: _buildToggleButton(
              title: 'Expenses',
              isActive: _currentFilterMode == FilterMode.expenses,
              isDark: isDark,
              onTap: () => setState(() => _currentFilterMode = FilterMode.expenses),
            ),
          ),
          // Income
          Expanded(
            child: _buildToggleButton(
              title: 'Income',
              isActive: _currentFilterMode == FilterMode.income,
              isDark: isDark,
              onTap: () => setState(() => _currentFilterMode = FilterMode.income),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String title,
    required bool isActive,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    // Determine text color based on active state and theme
    final Color textColor = isActive
        ? (isDark ? Colors.white : Colors.white) // Use white for active state in both themes
        : isDark 
            ? AppColors.darkSecondaryText 
            : AppColors.lightSecondaryText;
            
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isActive 
              ? AppThemeHelpers.getPrimaryColor(isDark) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: AppThemeHelpers.getBodyStyle(isDark).copyWith(
            color: textColor,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseCard(Map<String, double> groupedByMonth, double totalAmount, bool isDark) {
    String label;
    Color amountColor;
    
    switch (_currentFilterMode) {
      case FilterMode.all:
        label = 'Net Balance';
        amountColor = totalAmount >= 0 
            ? AppThemeHelpers.getAccentGreen(isDark)
            : AppThemeHelpers.getAccentRed(isDark);
        break;
      case FilterMode.expenses:
        label = 'Total Expenses';
        amountColor = AppThemeHelpers.getAccentRed(isDark);
        break;
      case FilterMode.income:
        label = 'Total Income';
        amountColor = AppThemeHelpers.getAccentGreen(isDark);
        break;
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadowColor : AppColors.lightShadowColor,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currencyFormat.format(totalAmount.abs()),
                    style: AppThemeHelpers.getHeadingStyle(isDark).copyWith(
                      color: amountColor,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    label,
                    style: AppThemeHelpers.getSmallStyle(isDark),
                  ),
                ],
              ),
              _buildTimePeriodDropdown(isDark),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: _buildBarChart(groupedByMonth, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePeriodDropdown(bool isDark) {
    final backgroundColor = isDark ? AppColors.darkCardBackground : AppColors.lightGray;
    final textColor = isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final menuBackgroundColor = isDark ? AppColors.darkBackground : AppColors.white;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkDividerColor : AppColors.lightDividerColor,
          width: 0.5,
        ),
      ),
      child: Theme(
        // Apply a localized theme to the dropdown that includes menu styling
        data: Theme.of(context).copyWith(
          // Style the popup menu to match app theme
          popupMenuTheme: PopupMenuThemeData(
            color: menuBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isDark ? AppColors.darkDividerColor : AppColors.lightDividerColor,
                width: 0.5,
              ),
            ),
            elevation: 4,
          ),
          // Style the dropdown menu items
          textTheme: Theme.of(context).textTheme.copyWith(
            bodyMedium: AppThemeHelpers.getBodyStyle(isDark).copyWith(fontSize: 14),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _currentTimeFilter,
            icon: Icon(Icons.keyboard_arrow_down_outlined, size: 16, color: textColor),
            isDense: true,
            // Apply dropdown-specific styling
            dropdownColor: menuBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            elevation: 4,
            items: ['Daily', 'Weekly', 'Monthly', 'Yearly'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: AppThemeHelpers.getBodyStyle(isDark).copyWith(
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                _handleTimeFilterChanged(newValue);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(Map<String, double> monthlyData, bool isDark) {
    final List<String> months = monthlyData.keys.toList();
    final double maxAmount = monthlyData.values.isEmpty 
        ? 100 
        : monthlyData.values.reduce((a, b) => a > b ? a : b);
    
    // Modern color palette
    final List<Color> barColors = [
      AppThemeHelpers.getPrimaryColor(isDark),
      AppThemeHelpers.getPrimaryColor(isDark),
      AppThemeHelpers.getPrimaryColor(isDark),
      AppThemeHelpers.getPrimaryColor(isDark),
      AppThemeHelpers.getPrimaryColor(isDark),
      AppThemeHelpers.getPrimaryColor(isDark),
    ];
    
    return GestureDetector(
      onTapUp: (details) {
        // Clear the selected bar when tapping elsewhere
        setState(() {
          _selectedBarIndex = null;
        });
      },
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxAmount * 1.2,
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < months.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        months[value.toInt()],
                        style: AppThemeHelpers.getSmallStyle(isDark),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          barGroups: List.generate(months.length, (index) {
            final String month = months[index];
            final double amount = monthlyData[month] ?? 0;
            
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: amount,
                  color: AppThemeHelpers.getPrimaryColor(isDark),
                  width: 28,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxAmount * 1.1,
                    color: (isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText).withOpacity(0.1),
                  ),
                ),
              ],
              showingTooltipIndicators: _selectedBarIndex == index ? [0] : [],
            );
          }),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (BarChartGroupData _) => AppThemeHelpers.getCardColor(isDark),
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final String month = months[group.x.toInt()];
                final double amount = rod.toY;
                return BarTooltipItem(
                  '$month\n',
                  AppThemeHelpers.getSmallStyle(isDark),
                  children: [
                    TextSpan(
                      text: _currencyFormat.format(amount),
                      style: AppThemeHelpers.getBodyStyle(isDark).copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppThemeHelpers.getPrimaryColor(isDark),
                      ),
                    ),
                  ],
                );
              },
            ),
            touchCallback: (FlTouchEvent event, barTouchResponse) {
              if (event is FlTapUpEvent && barTouchResponse != null && barTouchResponse.spot != null) {
                setState(() {
                  final tappedBarIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                  // Toggle off if tapping the same bar again
                  _selectedBarIndex = _selectedBarIndex == tappedBarIndex ? null : tappedBarIndex;
                });
              }
            },
          ),
        ),
      ),
    );
  }
  
  // Filter transactions based on current filter mode
  List<model.Transaction> _filterTransactions(List<model.Transaction> transactions) {
    // Apply filter mode (All, Expenses, Income)
    var filtered = transactions;
    switch (_currentFilterMode) {
      case FilterMode.all:
        // Keep all transactions
        break;
      case FilterMode.expenses:
        filtered = transactions.where((t) => t.type == model.TransactionType.expense).toList();
        break;
      case FilterMode.income:
        filtered = transactions.where((t) => t.type == model.TransactionType.income).toList();
        break;
    }
    
    return filtered;
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

  void _handleTransactionDelete(model.Transaction transaction) {
    // Implement the logic to delete the transaction
    ref.read(transactionServiceProvider).deleteTransaction(transaction.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaction deleted'),
        duration: Duration(seconds: 2),
      ),
    );
  }
} 