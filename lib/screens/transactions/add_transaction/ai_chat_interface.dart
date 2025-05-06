import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:spending_income/models/transaction.dart';
import 'package:uuid/uuid.dart';
import '../../../utils/app_theme.dart';

class AiChatInterface extends StatefulWidget {
  final List<Map<String, String>> chatMessages;
  final bool isAiProcessing;
  final Function(String) onSendMessage;

  const AiChatInterface({
    super.key,
    required this.chatMessages,
    required this.isAiProcessing,
    required this.onSendMessage,
  });

  @override
  State<AiChatInterface> createState() => _AiChatInterfaceState();
}

class _AiChatInterfaceState extends State<AiChatInterface> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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
              border: Border.all(color: AppTheme.getDividerColor(isDarkMode)),
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: widget.chatMessages.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text("Describe your transaction here.", textAlign: TextAlign.center),
                  ))
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: widget.chatMessages.length,
                  reverse: true,
                  padding: const EdgeInsets.all(8.0),
                  itemBuilder: (context, index) {
                    final message = widget.chatMessages.reversed.toList()[index];
                    final bool isUserMessage = message['sender'] == 'user';
                    return Align(
                      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isUserMessage
                              ? AppTheme.getPrimaryColor(isDarkMode)
                              : (isDarkMode ? AppTheme.darkCardBackground : AppTheme.lightGray),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Text(
                          message['text']!,
                          style: TextStyle(
                            color: isUserMessage
                                ? (isDarkMode ? AppTheme.primaryBlack : AppTheme.white)
                                : AppTheme.getPrimaryTextColor(isDarkMode)),
                        ),
                      ),
                    );
                  },
                ),
          ),
        ),
        
        // Input area fixed at bottom
        Container(
          padding: EdgeInsets.only(bottom: keyboardVisible ? 8 : 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  decoration: InputDecoration(
                    hintText: 'Type your transaction...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.getPrimaryColor(isDarkMode),
                  foregroundColor: isDarkMode ? AppTheme.primaryBlack : AppTheme.white,
                ),
                onPressed: widget.isAiProcessing ? null : _handleSend,
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
}