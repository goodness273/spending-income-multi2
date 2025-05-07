import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spending_income/models/transaction.dart' as model;
import 'package:spending_income/screens/transaction_screen/transaction_list_item.dart';

class TransactionList extends StatelessWidget {
  final List<model.Transaction> transactions;
  final bool isDark;
  final DateFormat dateFormat;
  final NumberFormat currencyFormat;
  final Function(model.Transaction) onTransactionTap;

  const TransactionList({
    super.key,
    required this.transactions,
    required this.isDark,
    required this.dateFormat,
    required this.currencyFormat,
    required this.onTransactionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(
        child: Text('No transactions found'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return TransactionListItem(
          transaction: transaction,
          isDark: isDark,
          dateFormat: dateFormat,
          currencyFormat: currencyFormat,
          onTap: () => onTransactionTap(transaction),
        );
      },
    );
  }
} 