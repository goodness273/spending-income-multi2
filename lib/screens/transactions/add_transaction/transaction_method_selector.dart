import 'package:flutter/material.dart';
import '../../../utils/app_theme/colors.dart';
import '../../../utils/app_theme/helpers.dart';
import 'transaction_models.dart';

class TransactionMethodSelector extends StatelessWidget {
  final TransactionInputMethod currentInputMethod;
  final Function(TransactionInputMethod) onMethodChanged;

  const TransactionMethodSelector({
    super.key,
    required this.currentInputMethod,
    required this.onMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: ToggleButtons(
        isSelected: [
          currentInputMethod == TransactionInputMethod.aiChat,
          currentInputMethod == TransactionInputMethod.manual,
        ],
        onPressed: (int index) {
          onMethodChanged(
            index == 0 ? TransactionInputMethod.aiChat : TransactionInputMethod.manual
          );
        },
        borderRadius: BorderRadius.circular(8),
        selectedColor: isDarkMode ? AppColors.primaryBlack : AppColors.white,
        color: AppThemeHelpers.getPrimaryTextColor(isDarkMode),
        fillColor: AppThemeHelpers.getPrimaryColor(isDarkMode),
        borderColor: AppThemeHelpers.getPrimaryColor(isDarkMode).withOpacity(0.5),
        selectedBorderColor: AppThemeHelpers.getPrimaryColor(isDarkMode),
        constraints: const BoxConstraints(minHeight: 40.0, minWidth: 120.0),
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min, 
              children: [
                Icon(Icons.chat_bubble_outline, size: 18), 
                SizedBox(width: 8), 
                Text('AI Chat')
              ]
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min, 
              children: [
                Icon(Icons.edit_note_outlined, size: 18), 
                SizedBox(width: 8), 
                Text('Manual')
              ]
            ),
          ),
        ],
      ),
    );
  }
} 



