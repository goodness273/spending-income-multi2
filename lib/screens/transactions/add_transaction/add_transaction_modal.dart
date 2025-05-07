import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_income/models/transaction.dart';
import 'package:spending_income/screens/transactions/add_transaction/ai_chat_interface.dart';
import 'package:spending_income/screens/transactions/add_transaction/manual_form_interface.dart';
import 'package:spending_income/screens/transactions/add_transaction/transaction_method_selector.dart';
import 'package:spending_income/screens/transactions/add_transaction/transaction_models.dart';
import 'package:spending_income/services/gemini_service.dart';
import 'package:spending_income/utils/app_theme/helpers.dart';
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      // Use FractionallySizedBox for consistent height
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: AddTransactionModal(onTransactionAdded: onTransactionAdded),
        ),
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
  
  // Gemini Service
  final GeminiService _geminiService = GeminiService();
  bool _isGeminiAvailable = false;

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
    _initializeGemini();
    
    // Initialize AI chat messages
    if (_chatMessages.isEmpty) {
      _chatMessages.add({
        'sender': 'ai', 
        'text': 'Tell me about your transaction...\n(e.g., "Spent 5000 naira on fuel yesterday")'
      });
    }
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

  Future<void> _initializeGemini() async {
    try {
      // Initialize the Gemini service with your actual API key
      // If this API key doesn't work, it will try fallback models automatically
      await _geminiService.initialize(apiKey: 'AIzaSyBG38eMKcTdUyf5faxJGlslI32VayEI9Q0'); 
      setState(() {
        _isGeminiAvailable = true;
      });
    } catch (e) {
      debugPrint('Failed to initialize Gemini: $e');
      setState(() {
        _isGeminiAvailable = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // final bottomPadding = MediaQuery.of(context).viewInsets.bottom; // No longer needed here
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16), 
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dismiss Handle
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppThemeHelpers.getDividerColor(isDarkMode),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Text(
                'New Transaction',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Method selector
            TransactionMethodSelector(
              currentInputMethod: _currentInputMethod,
              onMethodChanged: _handleMethodChange,
            ),
            const SizedBox(height: 16),
            // Content area - this is where the form or chat interface will go
            Expanded(
              child: _buildCurrentView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    Widget content;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    switch (_currentModalView) {
      case ModalView.aiChat:
        content = AiChatInterface(
          chatMessages: _chatMessages,
          isAiProcessing: _isAiProcessing,
          onSendMessage: _handleAiChatSend,
          isGeminiEnabled: _isGeminiAvailable,
        );
        break;
      case ModalView.aiReview:
        if (_parsedAiTransactionData == null) {
          content = const Center(child: Text('Error: No data to review.'));
        } else {
          // Populate form fields for review
          _populateFormWithAiData();
          
          content = ManualFormInterface(
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
        }
        break;
      case ModalView.manualForm:
      default:
        content = ManualFormInterface(
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
        break;
    }

    // Wrap in a Card with clear bounds and no extra scrolling
    return Container(
      decoration: BoxDecoration(
        color: AppThemeHelpers.getCardColor(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppThemeHelpers.getDividerColor(isDarkMode), width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: content,
      ),
    );
  }

  void _handleMethodChange(TransactionInputMethod method) {
    setState(() {
      _currentInputMethod = method;
      
      // Preserve the review form if we have parsed transaction data
      if (_parsedAiTransactionData != null && method == TransactionInputMethod.aiChat) {
        _currentModalView = ModalView.aiReview;
      } else {
        _currentModalView = method == TransactionInputMethod.aiChat ? ModalView.aiChat : ModalView.manualForm;
        _aiInteractionCount = 0;
        
        // Don't clear chat messages if already present
        if (_currentModalView == ModalView.aiChat && _chatMessages.isEmpty) {
          _chatMessages.add({'sender': 'ai', 'text': 'Tell me about your transaction...\n(e.g., "Spent 5000 naira on fuel yesterday")'});
        }
        
        _clearFormFields();
      }
    });
    
    // Save the method preference
    _saveLastUsedMethod(method);
  }

  void _handleAiChatSend(String message) {
    setState(() {
      _chatMessages.add({'sender': 'user', 'text': message});
      _isAiProcessing = true;
      _aiInteractionCount++;
    });

    if (_isGeminiAvailable) {
      // Use Gemini for real AI processing
      _processWithGemini(message);
    } else {
      // Fallback to mock AI processing
      _mockAiProcessing(message);
    }
  }
  
  Future<void> _processWithGemini(String message) async {
    try {
      // Get a response from Gemini
      String response;
      try {
        response = await _geminiService.sendMessage(message);
      } catch (apiError) {
        debugPrint('Error calling Gemini API: $apiError');
        // Fall back to mock response if API call fails
        _mockAiProcessing(message);
        return;
      }
      
      if (!mounted) return;
      
      // Add the AI response to chat
      setState(() {
        _chatMessages.add({'sender': 'ai', 'text': response});
        _isAiProcessing = false;
      });
      
      // Try to extract transaction data after the first user message
      // This makes it more likely to capture transaction data
      if (_aiInteractionCount >= 1) {
        debugPrint('Attempting to parse transaction from conversation...');
        
        setState(() {
          _isAiProcessing = true;
        });
        
        Transaction? transaction;
        
        try {
          transaction = await _geminiService.parseTransactionFromConversation();
        } catch (parseError) {
          debugPrint('Error during transaction parsing: $parseError');
          // Continue with null transaction, will handle below
        } finally {
          setState(() {
            _isAiProcessing = false;
          });
        }
        
        if (!mounted) return;
        
        if (transaction != null) {
          debugPrint('Transaction parsed successfully: ${transaction.description}, ${transaction.amount}');
          
          // Add a final message before showing the form
          setState(() {
            _chatMessages.add({
              'sender': 'ai', 
              'text': 'I\'ve prepared your transaction details for review. Please check and confirm!'
            });
            _parsedAiTransactionData = transaction;
            _currentModalView = ModalView.aiReview;
          });
        } else {
          debugPrint('Failed to parse transaction data');
          // If we've had multiple attempts and still can't parse, prompt the user
          if (_aiInteractionCount >= 3) {
            setState(() {
              _chatMessages.add({
                'sender': 'ai', 
                'text': 'I think I have enough information. Let me prepare your transaction details for review.'
              });
              
              // Fall back to creating a basic transaction from the conversation
              _parsedAiTransactionData = Transaction(
                id: const Uuid().v4(),
                amount: 500.00, // Default amount if parsing failed
                type: TransactionType.expense,
                category: 'Other',
                date: DateTime.now(),
                description: 'Transaction from chat',
                userId: 'temp-user-id',
              );
              _currentModalView = ModalView.aiReview;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error in processWithGemini: $e');
      if (!mounted) return;
      
      setState(() {
        _isAiProcessing = false;
        _chatMessages.add({
          'sender': 'ai', 
          'text': 'Sorry, I encountered an error. Please try adding your transaction manually.'
        });
        _currentInputMethod = TransactionInputMethod.manual;
        _currentModalView = ModalView.manualForm;
      });
    }
  }
  
  // Keep the existing mock method for fallback
  void _mockAiProcessing(String message) {
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
      _dateController.text = DateFormat('yyyy-MM-dd').format(date);
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
    
    // Format the date in a user-friendly way
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    
    // Check if the date is today, yesterday, or within the last week
    if (_selectedDate.year == now.year && _selectedDate.month == now.month && _selectedDate.day == now.day) {
      // Add a label to make it clear this is today
      _dateController.text = "${DateFormat('yyyy-MM-dd').format(_selectedDate)} (Today)";
    } else if (_selectedDate.year == yesterday.year && _selectedDate.month == yesterday.month && _selectedDate.day == yesterday.day) {
      // Add a label to make it clear this is yesterday
      _dateController.text = "${DateFormat('yyyy-MM-dd').format(_selectedDate)} (Yesterday)";
    } else {
      // Regular date format
      _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
    }
    
    // Populate description field
    _descriptionController.text = _parsedAiTransactionData!.description;
    
    // Populate vendor field if available
    _vendorController.text = _parsedAiTransactionData!.vendorOrSource ?? '';
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



