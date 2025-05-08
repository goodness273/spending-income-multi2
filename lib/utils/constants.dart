// Material imports are used in the file for EdgeInsets and other UI constants
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// App-wide constants for the spending-income application
class AppConstants {
  /// UI Constants and Theme Elements
  static const BorderRadius roundedCornerSmall = BorderRadius.all(Radius.circular(8.0));
  static const BorderRadius roundedCornerMedium = BorderRadius.all(Radius.circular(12.0));
  static const BorderRadius roundedCornerLarge = BorderRadius.all(Radius.circular(16.0));
  static const BorderRadius roundedCornerExtraLarge = BorderRadius.all(Radius.circular(20.0));
  
  static const EdgeInsets paddingAllSmall = EdgeInsets.all(8.0);
  static const EdgeInsets paddingAllMedium = EdgeInsets.all(12.0);
  static const EdgeInsets paddingAllLarge = EdgeInsets.all(16.0);
  static const EdgeInsets paddingModalHeader = EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 8.0);
  static const EdgeInsets paddingModalContent = EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 32.0);
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusExtraLarge = 20.0;
  
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 12.0;
  static const double paddingLarge = 16.0;
  static const double paddingExtraLarge = 20.0;
  static const double paddingSection = 24.0;
  static const double paddingPage = 32.0;
  
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  
  static const double spacingTiny = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingExtraLarge = 32.0;
  
  /// Modal Constants
  static const double modalHeightRatio = 0.75;
  static const double modalExtendedHeightRatio = 0.8;
  
  /// Formatters
  static final DateFormat standardDateFormat = DateFormat('dd MMM, yyyy');
  static final DateFormat shortDateFormat = DateFormat('MMM d, yyyy');
  static final DateFormat monthYearFormat = DateFormat('MMMM yyyy');
  
  static NumberFormat currencyFormat({String? customSymbol}) {
    return NumberFormat.currency(
      symbol: customSymbol ?? '₦', 
      decimalDigits: 2
    );
  }
  
  /// Mock Data for Testing
  static const String mockUserId = 'test-user-id';
  static final List<String> expenseCategories = [
    'Food & Dining',
    'Transport',
    'Utilities',
    'Shopping',
    'Health',
    'Entertainment',
    'Education',
    'Savings',
    'Lending',
    'Other',
  ];
  
  static final List<String> incomeCategories = [
    'Salary',
    'Freelance',
    'Investment',
    'Returns',
    'Repayments',
    'Gift',
    'Other',
  ];
}

/// Application string resources
class AppStrings {
  // General
  static const String appName = 'Spending & Income';
  
  // Buttons
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String saveAll = 'Save All';
  static const String delete = 'Delete';
  static const String confirm = 'Confirm';
  
  // Multi-transaction
  static const String reviewTransactions = 'Review Transactions';
  static const String aiDetectedTransactions = 'AI detected %d transactions. Tap any transaction to edit.';
  static const String transactionsSaved = '%d transactions saved';
  static const String allTransactionsRemoved = 'All transactions removed';
}
