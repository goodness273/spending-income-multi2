import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.3),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.getDividerColor(isDarkMode)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: widget.chatMessages.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text("Describe your transaction here.", textAlign: TextAlign.center),
                  ))
              : ListView.builder(
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
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _chatController,
                decoration: InputDecoration(
                    hintText: 'Type your transaction...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
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
        if (widget.isAiProcessing)
          const Padding(
            padding: EdgeInsets.only(top: 16.0),
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