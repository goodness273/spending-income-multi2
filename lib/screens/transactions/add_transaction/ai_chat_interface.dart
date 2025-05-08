import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:spending_income/models/transaction.dart';
import 'package:uuid/uuid.dart';
import '../../../utils/app_theme/colors.dart';
import '../../../utils/app_theme/helpers.dart';

class AiChatInterface extends StatefulWidget {
  final List<Map<String, String>> chatMessages;
  final bool isAiProcessing;
  final Function(String) onSendMessage;
  final bool isGeminiEnabled;

  const AiChatInterface({
    super.key,
    required this.chatMessages,
    required this.isAiProcessing,
    required this.onSendMessage,
    this.isGeminiEnabled = false,
  });

  @override
  State<AiChatInterface> createState() => _AiChatInterfaceState();
}

class _AiChatInterfaceState extends State<AiChatInterface> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Character limit for input
  static const int maxInputLength = 500;

  @override
  void initState() {
    super.initState();
    // Add listener to update UI when text changes (for character counter)
    _chatController.addListener(() {
      setState(() {
        // Just to rebuild the UI when text changes
      });
    });
  }

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end, // Anchor to bottom
      children: [
        // Chat messages area in a scrolling container
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppThemeHelpers.getDividerColor(isDarkMode)),
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: widget.chatMessages.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text("Describe your transaction here.", textAlign: TextAlign.center),
                  ))
              : Column(
                  children: [
                    // AI Status Indicator 
                    if (!keyboardVisible)  // Only show when keyboard is hidden
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: widget.isGeminiEnabled 
                              ? Colors.green.withOpacity(0.1) 
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.isGeminiEnabled 
                                  ? Icons.check_circle_outline 
                                  : Icons.info_outline,
                              size: 14,
                              color: widget.isGeminiEnabled 
                                  ? Colors.green 
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.isGeminiEnabled 
                                  ? "Google Gemini AI" 
                                  : "AI Simulation Mode",
                              style: TextStyle(
                                fontSize: 12,
                                color: widget.isGeminiEnabled 
                                    ? Colors.green 
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Chat messages
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: widget.chatMessages.length,
                        reverse: true,
                        padding: const EdgeInsets.all(8.0),
                        itemBuilder: (context, index) {
                          final message = widget.chatMessages.reversed.toList()[index];
                          final bool isUserMessage = message['sender'] == 'user';
                          return _buildMessageBubble(message['text']!, isUserMessage, isDarkMode);
                        },
                      ),
                    ),
                  ],
                ),
          ),
        ),
        
        // Input area fixed at bottom with expanded TextField and character counter
        Container(
          padding: EdgeInsets.only(bottom: keyboardVisible ? 8 : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Character counter
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  '${_chatController.text.length}/$maxInputLength',
                  style: TextStyle(
                    fontSize: 12,
                    color: _chatController.text.length > maxInputLength * 0.8
                      ? (_chatController.text.length >= maxInputLength ? Colors.red : Colors.orange)
                      : Colors.grey,
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _chatController,
                      decoration: InputDecoration(
                        hintText: 'Type your transaction...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
                      ),
                      // Make the TextField expand vertically
                      maxLines: null,
                      minLines: 1,
                      // Limit input to max characters
                      maxLength: maxInputLength,
                      // Hide the default counter as we're showing our own
                      buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                      textInputAction: TextInputAction.newline,
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send_outlined), // Using outlined variant per user preference
                    style: IconButton.styleFrom(
                      backgroundColor: AppThemeHelpers.getPrimaryColor(isDarkMode),
                      foregroundColor: isDarkMode ? AppColors.primaryBlack : AppColors.white,
                    ),
                    onPressed: widget.isAiProcessing || _chatController.text.isEmpty ? null : _handleSend,
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Loading indicator
        if (widget.isAiProcessing)
          const Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  void _handleSend() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    
    widget.onSendMessage(text);
    _chatController.clear();
    
    // Scroll to bottom after sending message
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  // Mock AI processing - in a real app, this would be handled by the parent
  static Transaction? mockProcessTransaction(String message, int interactionCount) {
    if (interactionCount == 1 && message.toLowerCase().contains('coffee')) {
      return null; // More info needed
    } else if (interactionCount <= 2 && 
        (message.toLowerCase().contains('500') || message.toLowerCase().contains('five hundred'))) {
      return Transaction(
        id: const Uuid().v4(),
        amount: 500.00,
        type: TransactionType.expense,
        category: 'Food',
        date: DateTime.now().subtract(const Duration(days: 1)),
        description: 'Coffee (from AI)',
        userId: 'temp-user-id',
      );
    }
    return null;
  }

  Widget _buildMessageBubble(String message, bool isUser, bool isDarkMode) {
    // Check if this is a JSON message or Gemini thinking text and hide it from the user
    if (!isUser) {
      // Hide raw JSON or code blocks
      if (message.trim().startsWith('{') || message.trim().startsWith('```json')) {
        return const SizedBox.shrink(); // Don't show raw JSON in the chat
      }
      
      // Hide Gemini's thinking text (which often includes calculation steps, summaries, etc.)
      if (message.contains('**Summary:**') || 
          message.contains('*Total') || 
          message.contains('=') || 
          message.contains('Naira**') ||
          message.contains('***') ||
          message.contains('```') ||
          message.trim().startsWith('*') && (message.contains('earned') || message.contains('spent'))) {
        // Don't add this thinking text to the chat view
        // The loading indicator will be shown instead (handled in the build method)
        return const SizedBox.shrink();
      }
    }
    
    return Container(
      margin: EdgeInsets.only(
        top: 8,
        bottom: 8,
        left: isUser ? 64 : 8,
        right: isUser ? 8 : 64,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isUser 
            ? AppThemeHelpers.getPrimaryColor(isDarkMode)
            : (isDarkMode ? AppColors.darkCardBackground : AppColors.lightGray),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: isUser 
              ? (isDarkMode ? AppColors.darkPrimaryText : AppColors.white)
              : AppThemeHelpers.getPrimaryTextColor(isDarkMode),
        ),
      ),
    );
  }
}



