import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:spending_income/models/transaction.dart';
import '../../../utils/app_theme.dart';
import 'transaction_models.dart';

class ManualFormInterface extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController amountController;
  final TextEditingController dateController;
  final TextEditingController descriptionController;
  final TextEditingController vendorController;
  final TransactionType selectedTransactionType;
  final String? selectedCategory;
  final DateTime selectedDate;
  final Function(TransactionType) onTransactionTypeChanged;
  final Function(String?) onCategoryChanged;
  final Function(DateTime) onDateChanged;
  final bool isReviewingAi;

  const ManualFormInterface({
    super.key,
    required this.formKey,
    required this.amountController,
    required this.dateController,
    required this.descriptionController,
    required this.vendorController,
    required this.selectedTransactionType,
    required this.selectedCategory,
    required this.selectedDate,
    required this.onTransactionTypeChanged,
    required this.onCategoryChanged,
    required this.onDateChanged,
    this.isReviewingAi = false,
  });

  @override
  State<ManualFormInterface> createState() => _ManualFormInterfaceState();
}

class _ManualFormInterfaceState extends State<ManualFormInterface> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final List<String> categories = widget.selectedTransactionType == TransactionType.expense
        ? defaultSpendingCategories
        : defaultIncomeCategories;

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.isReviewingAi)
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text(
                'Review & Confirm Transaction', 
                style: AppTheme.getTitleStyle(isDarkMode), 
                textAlign: TextAlign.center
              ),
            ),
          
          TextFormField(
            controller: widget.amountController,
            decoration: InputDecoration(
              labelText: 'Amount (₦)',
              prefixText: '₦ ',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter an amount';
              if (double.tryParse(value) == null) return 'Please enter a valid number';
              if (double.parse(value) <= 0) return 'Amount must be positive';
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<TransactionType>(
            value: widget.selectedTransactionType,
            decoration: InputDecoration(
              labelText: 'Type',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: TransactionType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.name[0].toUpperCase() + type.name.substring(1)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                widget.onTransactionTypeChanged(value);
              }
            },
          ),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: widget.selectedCategory,
            decoration: InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            hint: const Text('Select a category'),
            items: categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                widget.onCategoryChanged(value);
              }
            },
            validator: (value) => value == null ? 'Please select a category' : null,
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: widget.dateController,
            decoration: InputDecoration(
              labelText: 'Date',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            readOnly: true,
            onTap: () async {
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: widget.selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null && pickedDate != widget.selectedDate) {
                widget.onDateChanged(pickedDate);
                widget.dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
              }
            },
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: widget.descriptionController,
            decoration: InputDecoration(
              labelText: 'Description${widget.isReviewingAi ? '' : ' (Optional)'}',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: widget.vendorController,
            decoration: InputDecoration(
              labelText: 'Vendor/Source${widget.isReviewingAi ? '' : ' (Optional)'}',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          
          if (!widget.isReviewingAi)
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save_alt_outlined),
                label: const Text('Save Transaction'),
                style: AppTheme.getPrimaryButtonStyle(context),
                onPressed: () {
                  if (widget.formKey.currentState!.validate()) {
                    // The parent will handle the save operation
                    Navigator.pop(context, _buildTransaction());
                  }
                },
              ),
            ),
            
          if (widget.isReviewingAi)
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save_alt_outlined),
                label: const Text('Confirm & Save'),
                style: AppTheme.getPrimaryButtonStyle(context),
                onPressed: () {
                  if (widget.formKey.currentState!.validate()) {
                    // The parent will handle the save operation
                    Navigator.pop(context, _buildTransaction());
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
  
  Transaction _buildTransaction() {
    final amount = double.tryParse(widget.amountController.text) ?? 0.0;
    final String category = widget.selectedCategory ?? 'Other';
    final String description = widget.descriptionController.text.trim().isNotEmpty 
        ? widget.descriptionController.text.trim() 
        : "No description";
    
    return Transaction(
      id: const Uuid().v4(),
      amount: amount,
      type: widget.selectedTransactionType,
      category: category,
      date: widget.selectedDate,
      description: description,
      userId: 'temp-user-id', // Placeholder to be replaced
    );
  }
} 