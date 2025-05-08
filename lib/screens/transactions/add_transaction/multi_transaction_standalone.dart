import 'package:flutter/material.dart';
import 'package:spending_income/common/widgets/app_modal.dart';
import 'package:spending_income/models/transaction.dart';
import 'package:spending_income/screens/transactions/add_transaction/modal_transaction_item.dart';
import 'package:spending_income/utils/app_theme/colors.dart';
import 'package:spending_income/utils/app_theme/helpers.dart';
import 'package:spending_income/utils/constants.dart';

/// Standalone multi-transaction review component that doesn't rely on AddTransactionModal
class MultiTransactionStandalone extends StatefulWidget {
  final List<Transaction> transactions;
  final Function(List<Transaction>) onTransactionsConfirmed;
  final Function() onCancelReview;
  final Function() onAllTransactionsRemoved;

  const MultiTransactionStandalone({
    super.key,
    required this.transactions,
    required this.onTransactionsConfirmed,
    required this.onCancelReview,
    required this.onAllTransactionsRemoved,
  });

  @override
  State<MultiTransactionStandalone> createState() => _MultiTransactionStandaloneState();
}

class _MultiTransactionStandaloneState extends State<MultiTransactionStandalone> {
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
        
        Text(
          AppStrings.aiDetectedTransactions.replaceFirst('%d', _editableTransactions.length.toString()),
          style: AppThemeHelpers.getSubheadingStyle(isDarkMode),
        ),
        SizedBox(height: AppConstants.spacingMedium),
        
        Expanded(
          child: ListView.builder(
            itemCount: _editableTransactions.length,
            itemBuilder: (context, index) {
              final transaction = _editableTransactions[index];
              
              return InkWell(
                onTap: () {
                  // Open standalone transaction edit modal
                  _editTransaction(transaction, index);
                },
                child: ModalTransactionItem(
                  transaction: transaction,
                  isDark: isDarkMode,
                  dateFormat: AppConstants.shortDateFormat,
                  currencyFormat: AppConstants.currencyFormat(),
                  onTap: () => _editTransaction(transaction, index),
                ),
              );
            },
          ),
        ),
        
        Padding(
          padding: EdgeInsets.only(top: AppConstants.paddingLarge),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancelReview,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppThemeHelpers.getPrimaryTextColor(isDarkMode),
                    side: BorderSide(
                      color: AppThemeHelpers.getDividerColor(isDarkMode),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    ),
                    padding: EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
                  ),
                  child: Text(AppStrings.cancel),
                ),
              ),
              SizedBox(width: AppConstants.spacingMedium),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => widget.onTransactionsConfirmed(_editableTransactions),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemeHelpers.getPrimaryColor(isDarkMode),
                    foregroundColor: isDarkMode ? AppColors.primaryBlack : AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    ),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
                  ),
                  child: Text(AppStrings.saveAll),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  


  // Edit transaction using AppModal with a form
  void _editTransaction(Transaction transaction, int index) {
    final formKey = GlobalKey<FormState>();
    
    // Initialize controllers with existing data
    final amountController = TextEditingController(text: transaction.amount.toString());
    final descriptionController = TextEditingController(text: transaction.description);
    final vendorController = TextEditingController(text: transaction.vendorOrSource ?? '');
    final dateController = TextEditingController(text: AppConstants.standardDateFormat.format(transaction.date));
    
    // Initialize other form state
    var selectedType = transaction.type;
    var selectedCategory = transaction.category;
    var selectedDate = transaction.date;
    
    AppModal.show<void>(
      context: context,
      title: 'Edit Transaction',
      height: AppConstants.modalExtendedHeightRatio,
      // Use heightFactor to prevent overflow issues when keyboard appears
      isDismissible: true,
      enableDrag: true,
      onClose: () {
        // Clean up controllers
        amountController.dispose();
        descriptionController.dispose();
        vendorController.dispose();
        dateController.dispose();
      },
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  
                  // Transaction type selector
                  Text(
                    'Transaction Type',
                    style: AppThemeHelpers.getBodyStyle(isDarkMode).copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: AppConstants.spacingSmall),
                  
                  // Type selector buttons (Expense/Income)
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setModalState(() {
                              selectedType = TransactionType.expense;
                              // Ensure the selected category is valid for the new type
                              if (!_getCategoryOptions(TransactionType.expense).contains(selectedCategory)) {
                                selectedCategory = AppConstants.expenseCategories[0];
                              }
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
                            decoration: BoxDecoration(
                              color: selectedType == TransactionType.expense
                                  ? AppColors.accentRed.withOpacity(0.1)
                                  : Colors.transparent,
                              border: Border.all(
                                color: selectedType == TransactionType.expense
                                    ? AppColors.accentRed
                                    : AppThemeHelpers.getDividerColor(isDarkMode),
                              ),
                              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                            ),
                            child: Center(
                              child: Text(
                                'Expense',
                                style: TextStyle(
                                  color: selectedType == TransactionType.expense
                                      ? AppColors.accentRed
                                      : null,
                                  fontWeight: selectedType == TransactionType.expense
                                      ? FontWeight.bold
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppConstants.spacingSmall),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setModalState(() {
                              selectedType = TransactionType.income;
                              // Ensure the selected category is valid for the new type
                              if (!_getCategoryOptions(TransactionType.income).contains(selectedCategory)) {
                                selectedCategory = AppConstants.incomeCategories[0];
                              }
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
                            decoration: BoxDecoration(
                              color: selectedType == TransactionType.income
                                  ? AppColors.accentGreen.withOpacity(0.1)
                                  : Colors.transparent,
                              border: Border.all(
                                color: selectedType == TransactionType.income
                                    ? AppColors.accentGreen
                                    : AppThemeHelpers.getDividerColor(isDarkMode),
                              ),
                              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                            ),
                            child: Center(
                              child: Text(
                                'Income',
                                style: TextStyle(
                                  color: selectedType == TransactionType.income
                                      ? AppColors.accentGreen
                                      : null,
                                  fontWeight: selectedType == TransactionType.income
                                      ? FontWeight.bold
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: AppConstants.spacingMedium),
                  
                  // Amount field
                  TextFormField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      prefixText: '₦ ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  
                  SizedBox(height: AppConstants.spacingMedium),
                  
                  // Date field
                  GestureDetector(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate.isAfter(DateTime.now()) ? DateTime.now() : selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(), // Prevent future dates
                        builder: (context, childWidget) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: AppThemeHelpers.getPrimaryColor(isDarkMode),
                              ),
                            ),
                            child: childWidget!,
                          );
                        },
                      );
                      
                      if (pickedDate != null) {
                        setModalState(() {
                          selectedDate = pickedDate;
                          dateController.text = AppConstants.standardDateFormat.format(pickedDate);
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: dateController,
                        decoration: InputDecoration(
                          labelText: 'Date',
                          suffixIcon: const Icon(Icons.calendar_today_outlined), // Using outlined variant as per user preference
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a date';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  
                  SizedBox(height: AppConstants.spacingMedium),
                  
                  // Description field
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  
                  SizedBox(height: AppConstants.spacingMedium),
                  
                  // Category dropdown - completely rebuilt to avoid duplicate values
                  Builder(builder: (context) {
                    // Get the current categories without duplicates
                    final categories = _getCategoryOptions(selectedType);
                    
                    // Make sure selectedCategory exists in the list
                    // If not, default to the first category
                    if (!categories.contains(selectedCategory)) {
                      selectedCategory = categories.isNotEmpty ? categories.first : '';
                    }
                    
                    return DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                      dropdownColor: isDarkMode ? AppColors.darkCardBackground : AppColors.white,
                      icon: Icon(
                        Icons.arrow_drop_down_outlined, // Using outlined variant per user preference
                        color: isDarkMode ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                      ),
                      style: TextStyle(
                        color: isDarkMode ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                        fontSize: 16,
                      ),
                      itemHeight: 48,
                      borderRadius: BorderRadius.circular(12),
                      hint: const Text('Select a category'),
                      items: categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setModalState(() {
                            selectedCategory = newValue;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    );
                  }),
                  
                  SizedBox(height: AppConstants.spacingMedium),
                  
                  // Vendor/Source field
                  TextFormField(
                    controller: vendorController,
                    decoration: InputDecoration(
                      labelText: selectedType == TransactionType.expense ? 'Vendor' : 'Source',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                  ),
                  
                  SizedBox(height: AppConstants.spacingLarge),
                  
                  // Update Transaction button
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        // Update transaction with form data
                        final updatedTransaction = Transaction(
                          id: transaction.id,
                          amount: double.parse(amountController.text),
                          type: selectedType,
                          category: selectedCategory,
                          date: selectedDate,
                          description: descriptionController.text,
                          userId: transaction.userId,
                          vendorOrSource: vendorController.text.isNotEmpty ? vendorController.text : null,
                        );
                        
                        // Update the transaction in our list
                        setState(() {
                          _editableTransactions[index] = updatedTransaction;
                        });
                        
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemeHelpers.getPrimaryColor(isDarkMode),
                      foregroundColor: isDarkMode ? AppColors.primaryBlack : AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
                    ),
                    child: const Text('Update Transaction'),
                  ),
                  
                  SizedBox(height: AppConstants.spacingMedium),
                  
                  // Delete Transaction button
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _confirmDeleteTransaction(context, index);
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text('Delete Transaction'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                      ),
                      padding: EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
                    ),
                  ),
                ],
              ),
            ),
            );
          },
        );
      },
    );
  }
  
  // Confirm before deleting a transaction
  void _confirmDeleteTransaction(BuildContext context, int index) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Remove Transaction',
          style: AppThemeHelpers.getBodyStyle(isDarkMode).copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        content: Text(
          'Are you sure you want to remove this transaction?',
          style: AppThemeHelpers.getBodyStyle(isDarkMode),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _editableTransactions.removeAt(index);
              });
              Navigator.of(context).pop();
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
  
  // Get category options based on transaction type
  List<String> _getCategoryOptions(TransactionType type) {
    List<String> categories;
    
    if (type == TransactionType.income) {
      // Create a new list to avoid modifying the original
      categories = List<String>.from(AppConstants.incomeCategories);
    } else {
      // Create a new list to avoid modifying the original
      categories = List<String>.from(AppConstants.expenseCategories);
    }
    
    // Ensure categories are unique by converting to a Set and back to List
    return categories.toSet().toList();
  }
}
