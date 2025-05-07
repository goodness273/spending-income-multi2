import 'package:spending_income/models/transaction.dart';

// Enum to define the input method
enum TransactionInputMethod { aiChat, manual }

// Enum to define the current view within the modal
enum ModalView { methodSelection, aiChat, aiReview, manualForm }

// Constants for SharedPreferences
const String lastUsedMethodKey = 'last_transaction_input_method';

// Default categories
const List<String> defaultSpendingCategories = [
  'Food', 'Transport', 'Utilities', 'Shopping', 'Health', 'Entertainment', 'Education', 'Other'
];

const List<String> defaultIncomeCategories = [
  'Salary', 'Freelance', 'Investment', 'Gift', 'Other'
]; 



