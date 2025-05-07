import 'package:flutter/material.dart';
import 'colors.dart';
import 'helpers.dart';

/// Contains button styling for the app
class AppButtonStyles {
  // Private constructor to prevent instantiation
  AppButtonStyles._();

  /// Primary button style
  static ButtonStyle getPrimaryButtonStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ElevatedButton.styleFrom(
      backgroundColor: AppThemeHelpers.getPrimaryColor(isDark), 
      foregroundColor: isDark ? AppColors.primaryBlack : AppColors.white,
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
    );
  }

  /// Secondary button style
  static ButtonStyle getSecondaryButtonStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return OutlinedButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: AppThemeHelpers.getPrimaryTextColor(isDark),
      minimumSize: const Size(56, 56),
      maximumSize: const Size(64, 64),
      side: BorderSide(
        color: AppThemeHelpers.getDividerColor(isDark),
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      elevation: 0,
    );
  }

  /// Social button style (for auth providers)
  static ButtonStyle getOutlinedSocialButtonStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return OutlinedButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: AppThemeHelpers.getPrimaryTextColor(isDark),
      minimumSize: const Size(60, 60),
      maximumSize: const Size(60, 60),
      padding: EdgeInsets.zero,
      side: BorderSide(
        color: AppThemeHelpers.getDividerColor(isDark),
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  /// Text button style
  static ButtonStyle getTextButtonStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextButton.styleFrom(
      foregroundColor: AppThemeHelpers.getPrimaryColor(isDark),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      minimumSize: const Size(0, 30),
    );
  }
} 
