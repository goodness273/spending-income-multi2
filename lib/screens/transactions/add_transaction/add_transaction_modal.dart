import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_income/models/transaction.dart';
import 'package:spending_income/screens/transactions/add_transaction/ai_chat_interface.dart';
import 'package:spending_income/screens/transactions/add_transaction/manual_form_interface.dart';
import 'package:spending_income/screens/transactions/add_transaction/transaction_method_selector.dart';
import 'package:spending_income/screens/transactions/add_transaction/transaction_models.dart';
import 'package:uuid/uuid.dart';

class AddTransactionModal extends StatefulWidget {
  final Function(Transaction) onTransactionAdded;

  const AddTransactionModal({super.key, required this.onTransactionAdded});

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();

  // Static method to show the modal
  static Future<void> show(BuildContext context, Function(Transaction) onTransactionAdded) async {
    final result = await showModalBottomSheet<Transaction>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AddTransactionModal(onTransactionAdded: onTransactionAdded),
      ),
    );
    
    if (result != null) {
      onTransactionAdded(result);
    }
  }
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  // --- State Variables ---
  TransactionInputMethod _currentInputMethod = TransactionInputMethod.manual; // Default
  ModalView _currentModalView = ModalView.methodSelection;

  // AI Chat related state
  final List<Map<String, String>> _chatMessages = [];
  int _aiInteractionCount = 0;
  bool _isAiProcessing = false;
  Transaction? _parsedAiTransactionData;

  // Manual Form related state
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _vendorController = TextEditingController();
  TransactionType _selectedTransactionType = TransactionType.expense;
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadLastUsedMethod();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  Future<void> _loadLastUsedMethod() async {
    final prefs = await SharedPreferences.getInstance();
    final lastMethodString = prefs.getString(lastUsedMethodKey);
    if (!mounted) return;

    if (lastMethodString != null) {
      setState(() {
        _currentInputMethod = TransactionInputMethod.values
            .firstWhere((e) => e.name == lastMethodString, orElse: () => TransactionInputMethod.manual);
        _currentModalView = _currentInputMethod == TransactionInputMethod.aiChat
            ? ModalView.aiChat
            : ModalView.manualForm;
        if (_currentModalView == ModalView.aiChat && _chatMessages.isEmpty) {
          _chatMessages.add({'sender': 'ai', 'text': 'Tell me about your transaction...\n(e.g., "Spent 5000 naira on fuel yesterday")'});
        }
      });
    } else {
      // Default to manual if no preference saved
      setState(() {
        _currentInputMethod = TransactionInputMethod.manual;
        _currentModalView = ModalView.manualForm;
      });
    }
  }

  Future<void> _saveLastUsedMethod(TransactionInputMethod method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(lastUsedMethodKey, method.name);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 20, bottom: bottomPadding + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TransactionMethodSelector(
            currentInputMethod: _currentInputMethod,
            onMethodChanged: _handleMethodChange,
          ),
          const SizedBox(height: 20),
          Flexible(
            child: SingleChildScrollView(
              child: _buildCurrentView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentView() {
    // Ensure AI chat has initial message
    if (_currentModalView == ModalView.aiChat && _chatMessages.isEmpty && mounted) {
      setState(() {
        _chatMessages.add({'sender': 'ai', 'text': 'Tell me about your transaction...\n(e.g., "Spent 5000 naira on fuel yesterday")'});
      });
    }

    switch (_currentModalView) {
      case ModalView.aiChat:
        return AiChatInterface(
          chatMessages: _chatMessages,
          isAiProcessing: _isAiProcessing,
          onSendMessage: _handleAiChatSend,
        );
      case ModalView.aiReview:
        if (_parsedAiTransactionData == null) {
          return const Center(child: Text('Error: No data to review.'));
        }
        
        // Populate form fields for review
        _populateFormWithAiData();
        
        return ManualFormInterface(
          formKey: _formKey,
          amountController: _amountController,
          dateController: _dateController,
          descriptionController: _descriptionController,
          vendorController: _vendorController,
          selectedTransactionType: _selectedTransactionType,
          selectedCategory: _selectedCategory,
          selectedDate: _selectedDate,
          onTransactionTypeChanged: _handleTransactionTypeChange,
          onCategoryChanged: _handleCategoryChange,
          onDateChanged: _handleDateChange,
          isReviewingAi: true,
        );
      case ModalView.manualForm:
      default:
        return ManualFormInterface(
          formKey: _formKey,
          amountController: _amountController,
          dateController: _dateController,
          descriptionController: _descriptionController,
          vendorController: _vendorController,
          selectedTransactionType: _selectedTransactionType,
          selectedCategory: _selectedCategory,
          selectedDate: _selectedDate,
          onTransactionTypeChanged: _handleTransactionTypeChange,
          onCategoryChanged: _handleCategoryChange,
          onDateChanged: _handleDateChange,
        );
    }
  }

  void _handleMethodChange(TransactionInputMethod method) {
    setState(() {
      _currentInputMethod = method;
      _currentModalView = method == TransactionInputMethod.aiChat ? ModalView.aiChat : ModalView.manualForm;
      _aiInteractionCount = 0;
      _chatMessages.clear();
      
      if (_currentModalView == ModalView.aiChat) {
        _chatMessages.add({'sender': 'ai', 'text': 'Tell me about your transaction...\n(e.g., "Spent 5000 naira on fuel yesterday")'});
      }
      
      _clearFormFields();
    });
  }

  void _handleAiChatSend(String message) {
    setState(() {
      _chatMessages.add({'sender': 'user', 'text': message});
      _isAiProcessing = true;
      _aiInteractionCount++;
    });

    // Simulate AI processing
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      
      setState(() {
        _isAiProcessing = false;
        
        if (_aiInteractionCount == 1 && message.toLowerCase().contains('coffee')) {
          _chatMessages.add({'sender': 'ai', 'text': 'Okay, coffee! How much did it cost and when?'});
        } else if (_aiInteractionCount <= 2 && 
            (message.toLowerCase().contains('500') || message.toLowerCase().contains('five hundred'))) {
          _parsedAiTransactionData = Transaction(
            id: const Uuid().v4(),
            amount: 500.00,
            type: TransactionType.expense,
            category: 'Food',
            date: DateTime.now().subtract(const Duration(days: 1)),
            description: 'Coffee (from AI)',
            userId: 'temp-user-id',
          );
          _currentModalView = ModalView.aiReview;
        } else if (_aiInteractionCount >= 2) {
          _chatMessages.add({'sender': 'ai', 'text': "I'm having a bit of trouble. Could you try adding the details manually?"});
          _currentInputMethod = TransactionInputMethod.manual;
          _currentModalView = ModalView.manualForm;
          _clearFormFields(clearParsedAiData: true);
        } else {
          _chatMessages.add({'sender': 'ai', 'text': 'Received: "$message". Can you tell me more? (e.g., amount, date, purpose)'});
        }
      });
    });
  }

  void _handleTransactionTypeChange(TransactionType type) {
    setState(() {
      _selectedTransactionType = type;
      _selectedCategory = null; // Reset category when type changes
    });
  }

  void _handleCategoryChange(String? category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _handleDateChange(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _populateFormWithAiData() {
    if (_parsedAiTransactionData == null) return;
    
    _amountController.text = _parsedAiTransactionData!.amount.toStringAsFixed(2);
    _selectedTransactionType = _parsedAiTransactionData!.type;
    
    // Find appropriate category lists
    final categories = _selectedTransactionType == TransactionType.expense
        ? defaultSpendingCategories
        : defaultIncomeCategories;
        
    // Select category or default to first
    _selectedCategory = categories.contains(_parsedAiTransactionData!.category)
        ? _parsedAiTransactionData!.category
        : (categories.isNotEmpty ? categories[0] : null);
        
    _selectedDate = _parsedAiTransactionData!.date;
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
    _descriptionController.text = _parsedAiTransactionData!.description ?? '';
    _vendorController.text = ''; // Just clear this field since we don't have vendorOrSource in the model
  }

  void _clearFormFields({bool clearParsedAiData = false}) {
    _amountController.clear();
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _descriptionController.clear();
    _vendorController.clear();
    
    setState(() {
      _selectedTransactionType = TransactionType.expense;
      _selectedCategory = null;
      _selectedDate = DateTime.now();
      
      if (clearParsedAiData) {
        _parsedAiTransactionData = null;
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    _vendorController.dispose();
    super.dispose();
  }
} 