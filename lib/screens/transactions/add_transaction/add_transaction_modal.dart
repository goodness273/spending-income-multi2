import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_income/models/transaction.dart';
import 'package:spending_income/screens/transactions/add_transaction/ai_chat_interface.dart';
import 'package:spending_income/screens/transactions/add_transaction/manual_form_interface.dart';
import 'package:spending_income/screens/transactions/add_transaction/multi_transaction_standalone.dart';
import 'package:spending_income/screens/transactions/add_transaction/transaction_method_selector.dart';
import 'package:spending_income/screens/transactions/add_transaction/transaction_models.dart';
import 'package:spending_income/services/gemini_service.dart';
import 'package:spending_income/utils/app_theme/helpers.dart';
import 'package:spending_income/utils/constants.dart';
import 'package:uuid/uuid.dart';

/// The different views within the add transaction modal
enum ModalView {
  aiChat,              // Chat with AI to extract transaction
  aiReview,            // Review AI-extracted transaction before saving
  multiTransactions,   // Review multiple transactions extracted by AI
  manualForm,          // Manual transaction form
  methodSelection,     // Method selection view
}

class AddTransactionModal extends StatefulWidget {
  final Function(Transaction) onTransactionAdded;
  final Transaction? initialTransaction;

  const AddTransactionModal({
    super.key, 
    required this.onTransactionAdded,
    this.initialTransaction,
  });

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();

  // Static method to show the modal
  static Future<void> show(
    BuildContext context, 
    Function(Transaction) onTransactionAdded, 
    {Transaction? initialTransaction}
  ) async {
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
          child: AddTransactionModal(
            onTransactionAdded: onTransactionAdded,
            initialTransaction: initialTransaction,
          ),
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
  
  // The transaction that was parsed from the AI conversation
  Transaction? _parsedAiTransactionData;
  
  // List of transactions when AI detects multiple transactions
  List<Transaction> _parsedMultiTransactions = [];
  
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
    
    // If editing a transaction, populate form fields
    if (widget.initialTransaction != null) {
      _populateFormWithExistingTransaction();
    } else {
      _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
    }
    
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
                widget.initialTransaction != null ? 'Edit Transaction' : 'New Transaction',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Method selector - Only show when adding new transaction
            if (widget.initialTransaction == null) ...[
              TransactionMethodSelector(
                currentInputMethod: _currentInputMethod,
                onMethodChanged: _handleMethodChange,
              ),
              const SizedBox(height: 16),
            ],
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
    
    // When editing, always use manual form regardless of the current input method
    if (widget.initialTransaction != null) {
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
        isEditing: true,
        onDelete: () {
          // Close the modal
          Navigator.pop(context);
          // Return the transaction to be deleted
          widget.onTransactionAdded(widget.initialTransaction!);
        },
      );
    } else {
      // Normal flow for new transactions
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
        case ModalView.multiTransactions:
          content = _buildMultiTransactionInterface();
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
    }

    // Wrap in a Container with clear bounds and no extra scrolling
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

  // Build the multi-transaction interface
  Widget _buildMultiTransactionInterface() {
    return MultiTransactionStandalone(
      transactions: _parsedMultiTransactions,
      // When user confirms transactions, add them all
      onTransactionsConfirmed: (transactions) {
        for (final transaction in transactions) {
          widget.onTransactionAdded(transaction);
        }
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.transactionsSaved.replaceFirst('%d', transactions.length.toString())),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      // When the user cancels, clear all data and reset to fresh AI chat
      onCancelReview: () {
        setState(() {
          // Clear all parsed transaction data
          _parsedMultiTransactions = [];
          _parsedAiTransactionData = null;
          _aiInteractionCount = 0;
          _chatMessages.clear();
          _chatMessages.add({'sender': 'ai', 'text': 'Tell me about your transaction...\n(e.g., "Spent 5000 naira on fuel yesterday")'});
          
          // Reset to chat view
          _currentModalView = ModalView.aiChat;
        });
      },
      // When all transactions are removed
      onAllTransactionsRemoved: () {
        setState(() {
          // Clear all parsed transaction data
          _parsedMultiTransactions = [];
          _parsedAiTransactionData = null;
          _aiInteractionCount = 0;
          _chatMessages.clear();
          _chatMessages.add({'sender': 'ai', 'text': 'Tell me about your transaction...\n(e.g., "Spent 5000 naira on fuel yesterday")'});
          
          // Reset to chat view
          _currentModalView = ModalView.aiChat;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.allTransactionsRemoved),
            duration: Duration(seconds: 2),
          ),
        );
      },
    );
  }

  void _handleMethodChange(TransactionInputMethod method) {
    setState(() {
      _currentInputMethod = method;
      
      if (method == TransactionInputMethod.aiChat) {
        // Check if we have multiple transactions first and prioritize that
        if (_parsedMultiTransactions.isNotEmpty) {
          // If we have multiple transactions, always show the multi-transaction view
          _currentModalView = ModalView.multiTransactions;
        } else if (_parsedAiTransactionData != null) {
          // Coming from single-transaction view - preserve the single review form
          _currentModalView = ModalView.aiReview;
        } else {
          // Fresh AI chat session
          _currentModalView = ModalView.aiChat;
          _aiInteractionCount = 0;
          
          // Don't clear chat messages if already present
          if (_chatMessages.isEmpty) {
            _chatMessages.add({'sender': 'ai', 'text': 'Tell me about your transaction...\n(e.g., "Spent 5000 naira on fuel yesterday")'});
          }
        }
      } else {
        // Going to manual form
        _currentModalView = ModalView.manualForm;
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
          _parsedAiTransactionData = transaction;
          
          // Before showing the single transaction view, check if we have multiple transactions
          // This will store the single transaction in _parsedAiTransactionData for later use if needed
          await _attemptToParseMultipleTransactions();
          
          // Only show the single transaction view if we haven't switched to multi-transaction view
          if (_currentModalView != ModalView.multiTransactions && mounted) {
            setState(() {
              _chatMessages.add({
                'sender': 'ai', 
                'text': 'I\'ve prepared your transaction details for review. Please check and confirm!'
              });
              _currentModalView = ModalView.aiReview;
            });
          }
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
            });
            
            // Try to parse multiple transactions outside the setState
            await _attemptToParseMultipleTransactions();
            
            // Only show single transaction view if we didn't find multiple transactions
            if (_currentModalView != ModalView.multiTransactions && mounted) {
              setState(() {
                _currentModalView = ModalView.aiReview;
              });
            }
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
  
  // Attempt to parse multiple transactions from the AI conversation
  Future<void> _attemptToParseMultipleTransactions() async {
    if (!mounted) return;
    
    setState(() {
      _isAiProcessing = true;
    });
    
    try {
      // Use the new method to parse multiple transactions
      final transactions = await _geminiService.parseMultipleTransactionsFromConversation();
      
      if (!mounted) return;
      
      if (transactions.isNotEmpty) {
        debugPrint('Successfully parsed ${transactions.length} transactions');
        
        // Check if we have multiple transactions
        if (transactions.length > 1) {
          // Show the multi-transaction interface if we have multiple transactions
          setState(() {
            _parsedMultiTransactions = transactions;
            _chatMessages.add({
              'sender': 'ai',
              'text': 'I found multiple transactions! Let me show them all for your review.'
            });
            _currentModalView = ModalView.multiTransactions;
          });
          return; // Exit early - we're showing the multi-transaction view
        }
      }
    } catch (e) {
      debugPrint('Error parsing multiple transactions: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isAiProcessing = false;
        });
      }
    }
  }

  void _mockAiProcessing(String message) {
    // Simulate AI processing time
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      
      // Generate a mock response
      final response = 'I understand you spent money on something. Can you please provide more details?';
      
      setState(() {
        _chatMessages.add({'sender': 'ai', 'text': response});
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
            description: 'Coffee',
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

  // Clear form fields when switching between inputs
  void _clearFormFields({bool clearParsedAiData = false}) {
    _amountController.clear();
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _selectedDate = DateTime.now();
    _descriptionController.clear();
    _vendorController.clear();
    _selectedTransactionType = TransactionType.expense;
    _selectedCategory = null;
    
    if (clearParsedAiData) {
      _parsedAiTransactionData = null;
    }
  }

  // Populate form fields for editing an existing transaction
  void _populateFormWithExistingTransaction() {
    final transaction = widget.initialTransaction!;
    _amountController.text = transaction.amount.toString();
    _dateController.text = DateFormat('yyyy-MM-dd').format(transaction.date);
    _selectedDate = transaction.date;
    _descriptionController.text = transaction.description;
    _vendorController.text = transaction.vendorOrSource ?? '';
    _selectedTransactionType = transaction.type;
    _selectedCategory = transaction.category;
  }

  // Populate form fields with AI-extracted data for review
  void _populateFormWithAiData() {
    final transaction = _parsedAiTransactionData!;
    _amountController.text = transaction.amount.toString();
    _dateController.text = DateFormat('yyyy-MM-dd').format(transaction.date);
    _selectedDate = transaction.date;
    _descriptionController.text = transaction.description;
    _vendorController.text = transaction.vendorOrSource ?? '';
    _selectedTransactionType = transaction.type;
    _selectedCategory = transaction.category;
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
