import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Provides reusable UI components for consistent appearance across the app
class UIComponents {
  UIComponents._(); // Private constructor

  /// Standard page loading indicator
  static Widget loadingIndicator(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: CircularProgressIndicator(
        color: isDark ? AppTheme.accentYellow : AppTheme.primaryBlue,
      ),
    );
  }

  /// Standard error widget with retry option
  static Widget errorWidget({
    required BuildContext context,
    required String message,
    VoidCallback? onRetry,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final errorColor = isDark ? Colors.red.shade300 : Colors.red.shade700;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: errorColor, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              style: (isDark ? AppTheme.darkBodyStyle : AppTheme.lightBodyStyle)
                  .copyWith(color: errorColor),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: errorColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Standard empty state widget
  static Widget emptyStateWidget({
    required BuildContext context,
    required String message,
    IconData icon = Icons.info_outline,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: textColor, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              style: (isDark ? AppTheme.darkBodyStyle : AppTheme.lightBodyStyle)
                  .copyWith(color: textColor),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onAction,
                style: AppTheme.getPrimaryButtonStyle(context),
                child: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Custom alert dialog
  static Future<bool?> showCustomDialog({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDismissible = true,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return await showDialog<bool>(
      context: context,
      barrierDismissible: isDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor:
              isDark ? AppTheme.darkCardBackground : AppTheme.white,
          title: Text(
            title,
            style: isDark ? AppTheme.darkTitleStyle : AppTheme.lightTitleStyle,
          ),
          content: Text(
            message,
            style: isDark ? AppTheme.darkBodyStyle : AppTheme.lightBodyStyle,
          ),
          actions: [
            if (cancelText != null)
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(cancelText),
                style: AppTheme.getTextButtonStyle(context),
              ),
            if (confirmText != null)
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(confirmText),
                style: AppTheme.getPrimaryButtonStyle(context),
              ),
          ],
        );
      },
    );
  }

  /// Custom snackbar
  static void showSnackBar({
    required BuildContext context,
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    Color backgroundColor;
    IconData icon;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Set the appropriate color and icon based on the type
    switch (type) {
      case SnackBarType.success:
        backgroundColor = Colors.green.shade600;
        icon = Icons.check_circle;
        break;
      case SnackBarType.error:
        backgroundColor = isDark ? Colors.red.shade400 : Colors.red.shade700;
        icon = Icons.error;
        break;
      case SnackBarType.warning:
        backgroundColor =
            isDark ? Colors.amber.shade600 : Colors.amber.shade800;
        icon = Icons.warning;
        break;
      case SnackBarType.info:
      default:
        backgroundColor = isDark ? Colors.blue.shade400 : Colors.blue.shade700;
        icon = Icons.info;
        break;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        duration: duration,
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action:
            onAction != null && actionLabel != null
                ? SnackBarAction(
                  label: actionLabel,
                  textColor: Colors.white,
                  onPressed: onAction,
                )
                : null,
      ),
    );
  }

  /// Custom app bar with back button
  static AppBar appBarWithBack({
    required BuildContext context,
    required String title,
    List<Widget>? actions,
    bool centerTitle = true,
  }) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppTheme.primaryBlue,
      foregroundColor: AppTheme.white,
      centerTitle: centerTitle,
      actions: actions,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Standard form section header
  static Widget formSectionHeader(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style:
            isDark
                ? AppTheme.darkSubheadingStyle
                : AppTheme.lightSubheadingStyle,
      ),
    );
  }

  /// Standard card with content
  static Widget card({
    required BuildContext context,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    Color? backgroundColor,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(12)),
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            (isDark ? AppTheme.darkCardBackground : AppTheme.white),
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color:
                isDark ? AppTheme.darkShadowColor : AppTheme.lightShadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Enum for SnackBar types
enum SnackBarType { info, success, warning, error }
