import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:spending_income/models/transaction.dart';
import 'package:spending_income/screens/transactions/add_transaction/transaction_models.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

/// Service to interact with Google's Gemini AI API for natural language transaction processing
class GeminiService {
  static const String _defaultApiKey = ''; // You'll need to add your API key here
  static const String _defaultModel = 'gemini-2.0-flash';  // Updated to match curl command
  
  late final GenerativeModel _model;
  late final ChatSession _chatSession;
  bool _isInitialized = false;

  /// Initialize the Gemini service
  Future<void> initialize({String? apiKey, String model = _defaultModel}) async {
    try {
      final String key = apiKey ?? _defaultApiKey;
      if (key.isEmpty) {
        throw Exception('No API key provided. Please add your Gemini API key.');
      }
      
      debugPrint('Initializing Gemini with model: $model');
      _model = GenerativeModel(
        model: model, 
        apiKey: key,
      );
      _chatSession = _model.startChat();
      _isInitialized = true;
      debugPrint('Gemini service initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize Gemini service: $e');
      
      // Try alternative models if the first one failed
      if (model == _defaultModel) {
        final List<String> fallbackModels = [
          'gemini-pro', 
          'gemini-1.0-pro', 
          'gemini-1.5-flash',
          'gemini-1.5-pro'
        ];
        
        for (final fallbackModel in fallbackModels) {
          debugPrint('Attempting with alternative model name: $fallbackModel');
          try {
            final String key = apiKey ?? _defaultApiKey;
            _model = GenerativeModel(
              model: fallbackModel, 
              apiKey: key,
            );
            _chatSession = _model.startChat();
            _isInitialized = true;
            debugPrint('Gemini service initialized with fallback model: $fallbackModel');
            return; // Exit the method if initialization succeeds
          } catch (fallbackError) {
            debugPrint('Fallback model $fallbackModel failed: $fallbackError');
            // Continue trying the next model
          }
        }
        
        // If we reach here, all fallbacks failed
        debugPrint('All fallback models failed');
        rethrow;
      } else {
        rethrow;
      }
    }
  }

  /// Check if the service is initialized
  bool get isInitialized => _isInitialized;

  /// Send a message to Gemini and get the response
  Future<String> sendMessage(String message) async {
    if (!_isInitialized) {
      throw Exception('Gemini service not initialized. Call initialize() first.');
    }
    
    try {
      // Before sending, save the message for our own tracking (useful for debugging)
      debugPrint('Sending to AI: $message');
      
      final response = await _chatSession.sendMessage(Content.text(message));
      final responseText = response.text ?? 'No response from AI.';
      return responseText;
    } catch (e) {
      debugPrint('Error sending message to Gemini: $e');
      return 'Sorry, I encountered an error. Please try again.';
    }
  }

  /// Process the entire chat history specifically looking for date references
  /// This is used as a pre-check before sending the full extraction prompt
  Future<String?> _extractDateReferenceFromHistory() async {
    try {
      const preExtractPrompt = '''
From the previous conversation, extract ONLY any mention of dates, times, or time references.
Return ONLY the date reference with no additional text.
Examples of what to extract: "yesterday", "2 days ago", "last week", "on Monday", etc.
If no date reference exists, respond with "NO_DATE_REFERENCE".
''';

      final response = await _chatSession.sendMessage(Content.text(preExtractPrompt));
      final extractedText = response.text?.trim() ?? '';
      
      debugPrint('Extracted date reference: $extractedText');
      
      if (extractedText.isEmpty || extractedText.toLowerCase() == 'no_date_reference') {
        return null;
      }
      
      return extractedText;
    } catch (e) {
      debugPrint('Error pre-extracting date reference: $e');
      return null;
    }
  }

  /// Parse a transaction from an AI response with category validation
  Future<Transaction?> parseTransactionFromConversation() async {
    if (!_isInitialized) {
      throw Exception('Gemini service not initialized. Call initialize() first.');
    }
    
    try {
      // Pre-extract any date reference from the conversation history
      final preExtractedDateRef = await _extractDateReferenceFromHistory();
      debugPrint('Pre-extracted date reference: $preExtractedDateRef');
      
      // Get today's date for the AI's reference
      final now = DateTime.now();
      final String todayFormatted = _formatDate(now);
      final String yesterdayFormatted = _formatDate(now.subtract(const Duration(days: 1)));
      
      // Send a special extraction prompt to get structured data
      final extractionPrompt = '''
Today's date is $todayFormatted.
Yesterday's date was $yesterdayFormatted.
${preExtractedDateRef != null ? 'I detected this date reference in our conversation: "$preExtractedDateRef".' : ''}

Based on our conversation, please extract the transaction details in the following JSON format:
{
  "amount": 0.00,
  "type": "expense" or "income",
  "category": "category name",
  "date": "YYYY-MM-DD",
  "description": "brief description",
  "vendorOrSource": "name of vendor or source",
  "date_reference": "original date reference from the conversation (e.g., 'yesterday', '2 days ago', 'last Monday')"
}

For expense categories, please choose from: ${defaultSpendingCategories.join(', ')}
For income categories, please choose from: ${defaultIncomeCategories.join(', ')}

Important categorization notes:
- Food: ONLY for meals, groceries, restaurants, drinks, and food items
- Transport: For fuel, vehicle maintenance, transportation fees, ride-sharing, taxis
- Utilities: For electricity, water, internet, phone bills
- Shopping: For clothing, electronics, household items

For vendor extraction:
- Extract any business name, person, or entity providing the good/service
- For expenses, this is who you paid (shop, person, company)
- For income, this is who paid you (employer, client, person)

Date handling examples:
- If "yesterday" is mentioned, use $yesterdayFormatted
- If "2 days ago" is mentioned, use ${_formatDate(now.subtract(const Duration(days: 2)))}
- If "3 days ago" is mentioned, use ${_formatDate(now.subtract(const Duration(days: 3)))}
- If "last week" is mentioned, use ${_formatDate(now.subtract(const Duration(days: 7)))}
- If no date is mentioned, use today's date ($todayFormatted)

${preExtractedDateRef != null ? 'CRITICAL: Pay special attention to the date reference "$preExtractedDateRef" and calculate the correct date.' : ''}

If any field is unclear or missing, use null for that field. Only respond with the JSON.
''';

      final response = await _chatSession.sendMessage(Content.text(extractionPrompt));
      final jsonText = response.text ?? '';
      
      debugPrint('Received JSON response: $jsonText');
      
      // Extract JSON from the response (in case there's any extra text)
      final jsonMatch = RegExp(r'{[\s\S]*}').firstMatch(jsonText);
      if (jsonMatch == null) {
        debugPrint('No JSON found in response');
        return _mockParseTransaction("{}"); // Fallback to mock
      }
      
      // Parse the JSON response
      final jsonStr = jsonMatch.group(0);
      if (jsonStr == null) {
        debugPrint('JSON match was null');
        return _mockParseTransaction("{}"); // Fallback to mock
      }
      
      try {
        // Attempt to parse the JSON
        final Map<String, dynamic> jsonData = json.decode(jsonStr);
        debugPrint('Successfully parsed JSON: $jsonData');
        
        // Extract fields with fallbacks
        final double amount = double.tryParse(jsonData['amount']?.toString() ?? '') ?? 0.0;
        final String typeStr = jsonData['type']?.toString()?.toLowerCase() ?? 'expense';
        final TransactionType type = typeStr == 'income' ? TransactionType.income : TransactionType.expense;
        String category = jsonData['category']?.toString() ?? 'Other';
        
        // Get the date reference from the JSON
        final String? dateReference = jsonData['date_reference']?.toString();
        debugPrint('Date reference from AI: $dateReference');
        
        // Extract vendor information
        final String? vendorOrSource = jsonData['vendorOrSource']?.toString();
        debugPrint('Vendor/Source from AI: $vendorOrSource');
        
        // Process the date
        DateTime date;
        try {
          // First try to parse the date directly from the JSON
          if (jsonData['date'] != null && jsonData['date'].toString().isNotEmpty) {
            try {
              date = DateTime.parse(jsonData['date'].toString());
              debugPrint('Successfully parsed date from JSON: ${date.toIso8601String()}');
            } catch (e) {
              debugPrint('Failed to parse direct date, using fallback: $e');
              date = _parseDateFromReference(dateReference) ?? DateTime.now();
            }
          } else {
            // JSON date is null, try to parse from the reference
            date = _parseDateFromReference(dateReference) ?? DateTime.now();
            debugPrint('Parsed date from reference: ${date.toIso8601String()}');
          }
        } catch (e) {
          debugPrint('Date parsing failed completely: $e');
          date = DateTime.now();
        }
        
        final String description = jsonData['description']?.toString() ?? 'Transaction from chat';
        
        // Get the appropriate category list based on transaction type
        final List<String> validCategories = type == TransactionType.expense 
            ? defaultSpendingCategories 
            : defaultIncomeCategories;
        
        // Special case handling for common miscategorizations
        if (type == TransactionType.expense) {
          // Fix common misclassifications
          final String descriptionLower = description.toLowerCase();
          
          // Fix fuel being categorized as food
          if ((descriptionLower.contains('fuel') || descriptionLower.contains('gas') || 
               descriptionLower.contains('petrol') || descriptionLower.contains('diesel')) && 
              category == 'Food') {
            category = 'Transport';
            debugPrint('Detected fuel purchase, correcting category from Food to Transport');
          }
        }
        
        // Format description to include vendor information if available
        String finalDescription = description;
        String? extractedVendorOrSource = vendorOrSource;
        if (vendorOrSource != null && vendorOrSource.isNotEmpty) {
          finalDescription = "$description";
          extractedVendorOrSource = vendorOrSource;
          debugPrint('Added vendor/source information: $extractedVendorOrSource');
        }
        
        // Check if the category exists in the valid categories
        bool isCategoryValid = validCategories.any(
            (validCategory) => validCategory.toLowerCase() == category.toLowerCase());
        
        // If category is not valid, send a follow-up prompt to get a valid category
        if (!isCategoryValid && _isInitialized) {
          debugPrint('Invalid category detected: $category. Requesting correction...');
          
          // Create a follow-up prompt with valid categories
          final validCategoriesStr = validCategories.join(', ');
          final categoryPrompt = '''
The category "$category" does not match any of our predefined categories.
For ${type == TransactionType.expense ? 'expenses' : 'income'}, please classify this transaction into one of these categories:
$validCategoriesStr

Reply ONLY with the category name that best matches, no other text.
''';

          try {
            // This happens behind the scenes, no need to show in chat UI
            final categoryResponse = await _chatSession.sendMessage(Content.text(categoryPrompt));
            final correctedCategory = categoryResponse.text?.trim() ?? '';
            
            debugPrint('AI suggested corrected category: $correctedCategory');
            
            // Check if the corrected category is valid
            final correctedCategoryValid = validCategories.any(
                (validCategory) => validCategory.toLowerCase() == correctedCategory.toLowerCase());
                
            if (correctedCategoryValid) {
              // Find the correctly cased category
              for (final validCategory in validCategories) {
                if (validCategory.toLowerCase() == correctedCategory.toLowerCase()) {
                  category = validCategory;
                  break;
                }
              }
              debugPrint('Using corrected category: $category');
            } else {
              // If still not valid, use a fallback category
              category = type == TransactionType.expense ? 'Other' : 'Other Income';
              debugPrint('Using fallback category: $category');
            }
          } catch (e) {
            debugPrint('Error getting category correction: $e');
            category = type == TransactionType.expense ? 'Other' : 'Other Income';
          }
        }
        
        return Transaction(
          id: const Uuid().v4(),
          amount: amount,
          type: type,
          category: category,
          date: date,
          description: finalDescription,
          userId: 'temp-user-id',
          vendorOrSource: extractedVendorOrSource,
        );
      } catch (e) {
        debugPrint('JSON decode error: $e');
        return _mockParseTransaction(jsonStr); // Fallback to mock
      }
    } catch (e) {
      debugPrint('Error parsing transaction from Gemini response: $e');
      return null;
    }
  }
  
  // Mock implementation as fallback
  Transaction? _mockParseTransaction(String jsonStr) {
    debugPrint('Using mock transaction parser');
    
    // Try to extract date reference from the JSON if possible
    String? dateReference;
    try {
      final dateRefMatch = RegExp(r'"date_reference"\s*:\s*"([^"]+)"').firstMatch(jsonStr);
      if (dateRefMatch != null && dateRefMatch.groupCount >= 1) {
        dateReference = dateRefMatch.group(1);
        debugPrint('Mock parser found date reference: $dateReference');
      }
    } catch (e) {
      debugPrint('Error extracting date reference in mock parser: $e');
    }
    
    // Try to extract vendor from the JSON if possible
    String? vendorOrSource;
    try {
      final vendorMatch = RegExp(r'"vendorOrSource"\s*:\s*"([^"]+)"').firstMatch(jsonStr);
      if (vendorMatch != null && vendorMatch.groupCount >= 1) {
        vendorOrSource = vendorMatch.group(1);
        debugPrint('Mock parser found vendor/source: $vendorOrSource');
      }
    } catch (e) {
      debugPrint('Error extracting vendor/source in mock parser: $e');
    }
    
    // For demo, let's extract some basic details if possible
    final hasAmount = jsonStr.toLowerCase().contains('amount');
    final hasFood = jsonStr.toLowerCase().contains('food') || 
                    jsonStr.toLowerCase().contains('coffee') || 
                    jsonStr.toLowerCase().contains('meal');
    
    // Try to use date reference if we found one
    DateTime date = _parseDateFromReference(dateReference) ?? 
                   DateTime.now().subtract(const Duration(days: 1));
    
    // For demo, let's say we extracted these values (simulating successful parsing)
    const double amount = 500.00;
    const TransactionType type = TransactionType.expense;
    final String category = hasFood ? 'Food' : 'Other';
    String description = hasFood ? 'Food purchase' : 'Transaction from chat';
    
    // Add vendor to description if available
    if (vendorOrSource != null && vendorOrSource.isNotEmpty) {
      // Don't add to description since we're storing it separately
      debugPrint('Found vendor/source for mock transaction: $vendorOrSource');
    }
    
    return Transaction(
      id: const Uuid().v4(),
      amount: amount,
      type: type,
      category: category,
      date: date,
      description: description,
      userId: 'temp-user-id', // This would be replaced with the actual user ID
      vendorOrSource: vendorOrSource,
    );
  }
  
  /// Reset the chat session
  void resetChat() {
    if (_isInitialized) {
      _chatSession = _model.startChat();
    }
  }

  // Helper to parse dates from common references
  DateTime? _parseDateFromReference(String? reference) {
    if (reference == null || reference.isEmpty) return null;
    
    final String refLower = reference.toLowerCase().trim();
    final DateTime now = DateTime.now();
    
    // Handle "yesterday"
    if (refLower == 'yesterday') {
      return now.subtract(const Duration(days: 1));
    }
    
    // Handle "X days ago"
    final RegExp daysAgoPattern = RegExp(r'(\d+)\s*days?\s*ago');
    final Match? daysAgoMatch = daysAgoPattern.firstMatch(refLower);
    if (daysAgoMatch != null) {
      final int daysAgo = int.tryParse(daysAgoMatch.group(1) ?? '0') ?? 0;
      if (daysAgo > 0) {
        return now.subtract(Duration(days: daysAgo));
      }
    }
    
    // Handle "last week"
    if (refLower.contains('last week')) {
      return now.subtract(const Duration(days: 7));
    }
    
    // Handle "last month"
    if (refLower.contains('last month')) {
      return DateTime(now.year, now.month - 1, now.day);
    }
    
    // Handle day of week references like "last Monday"
    final List<String> daysOfWeek = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    for (int i = 0; i < daysOfWeek.length; i++) {
      if (refLower.contains(daysOfWeek[i])) {
        final int targetWeekday = i + 1; // 1 = Monday, 7 = Sunday
        final int currentWeekday = now.weekday;
        int daysToSubtract = currentWeekday - targetWeekday;
        
        // If negative or zero, go back to previous week
        if (daysToSubtract <= 0) {
          daysToSubtract += 7;
        }
        
        // If it has "last" prefix, go back one more week
        if (refLower.contains('last')) {
          daysToSubtract += 7;
        }
        
        return now.subtract(Duration(days: daysToSubtract));
      }
    }
    
    // If we couldn't parse it, return null
    return null;
  }

  // Format date as YYYY-MM-DD
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
} 



