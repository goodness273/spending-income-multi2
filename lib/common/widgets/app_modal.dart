import 'package:flutter/material.dart';
import 'package:spending_income/utils/app_theme/helpers.dart';
import 'package:spending_income/utils/constants.dart';

/// A reusable modal bottom sheet component that maintains consistent styling
/// across the application.
class AppModal {
  /// Shows a modal bottom sheet with consistent styling.
  /// 
  /// [context] - The build context
  /// [builder] - Builder function that returns the content widget
  /// [title] - Optional title to display at the top of the modal
  /// [height] - Height of the modal as a fraction of the screen height (default: 0.75)
  /// [isDismissible] - Whether the modal can be dismissed by tapping outside (default: true)
  /// [enableDrag] - Whether the modal can be dragged up/down (default: true)
  /// [showCloseButton] - Whether to show a close button in the top right (default: true)
  /// [onClose] - Optional callback when modal is closed
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    String? title,
    double height = 0.75,
    bool isDismissible = true,
    bool enableDrag = true,
    bool showCloseButton = true,
    VoidCallback? onClose,
  }) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.borderRadiusExtraLarge)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * (height > 0 ? height : AppConstants.modalHeightRatio),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Modal header with title and optional close button
              if (title != null || showCloseButton)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppConstants.paddingExtraLarge, 
                    AppConstants.paddingLarge, 
                    AppConstants.paddingExtraLarge, 
                    AppConstants.paddingSmall
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (title != null)
                        Expanded(
                          child: Text(
                            title,
                            style: AppThemeHelpers.getTitleStyle(isDarkMode),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      else
                        const Spacer(),
                      
                      if (showCloseButton)
                        IconButton(
                          icon: const Icon(Icons.close_outlined),
                          onPressed: () {
                            Navigator.of(context).pop();
                            if (onClose != null) {
                              onClose();
                            }
                          },
                          splashRadius: 24,
                          tooltip: 'Close',
                        ),
                    ],
                  ),
                ),
              
              // Content with consistent padding
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppConstants.paddingExtraLarge,
                    0,
                    AppConstants.paddingExtraLarge,
                    AppConstants.paddingPage
                  ),
                  child: builder(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Shows a confirmation dialog with consistent styling.
  /// 
  /// [context] - The build context
  /// [title] - Title of the confirmation dialog
  /// [message] - The message to display
  /// [confirmText] - Text for the confirm button (default: 'Confirm')
  /// [cancelText] - Text for the cancel button (default: 'Cancel')
  /// [isDangerous] - Whether the action is destructive (shows confirm in red)
  static Future<bool> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = AppStrings.confirm,
    String cancelText = AppStrings.cancel,
    bool isDangerous = false,
  }) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: isDangerous 
                ? AppThemeHelpers.getAccentRed(isDarkMode)
                : null,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
}
