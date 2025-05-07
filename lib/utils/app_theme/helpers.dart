import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';

/// Contains helper methods to get theme-appropriate styles and colors
class AppThemeHelpers {
  // Private constructor to prevent instantiation
  AppThemeHelpers._();

  // Color helpers
  static Color getCardColor(bool isDarkMode) =>
      isDarkMode ? AppColors.darkCardBackground : AppColors.lightCardColor;
      
  static Color getBackgroundColor(bool isDarkMode) =>
      isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
      
  static Color getPrimaryTextColor(bool isDarkMode) =>
      isDarkMode ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
      
  static Color getSecondaryTextColor(bool isDarkMode) =>
      isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
      
  static Color getTertiaryTextColor(bool isDarkMode) =>
      isDarkMode ? AppColors.darkTertiaryText : AppColors.lightTertiaryText;
      
  static Color getDividerColor(bool isDarkMode) =>
      isDarkMode ? AppColors.darkDividerColor : AppColors.lightDividerColor;
      
  static List<Color> getChartColors(bool isDarkMode) =>
      isDarkMode ? AppColors.darkChartColors : AppColors.lightChartColors;
      
  static Color getPrimaryColor(bool isDarkMode) =>
      isDarkMode ? AppColors.darkPrimaryAction : AppColors.lightPrimaryAction;
      
  static Color getAccentYellow(bool isDarkMode) =>
      isDarkMode ? AppColors.accentYellowDark : AppColors.accentYellow;
      
  static Color getAccentGreen(bool isDarkMode) =>
      isDarkMode ? AppColors.accentGreenDark : AppColors.accentGreen;

  // TextStyle helpers
  static TextStyle getHeadingStyle(bool isDarkMode) =>
      isDarkMode ? AppTextStyles.darkHeadingStyle : AppTextStyles.lightHeadingStyle;
      
  static TextStyle getSubheadingStyle(bool isDarkMode) =>
      isDarkMode ? AppTextStyles.darkSubheadingStyle : AppTextStyles.lightSubheadingStyle;
      
  static TextStyle getTitleStyle(bool isDarkMode) =>
      isDarkMode ? AppTextStyles.darkTitleStyle : AppTextStyles.lightTitleStyle;
      
  static TextStyle getBodyStyle(bool isDarkMode) =>
      isDarkMode ? AppTextStyles.darkBodyStyle : AppTextStyles.lightBodyStyle;
      
  static TextStyle getSmallStyle(bool isDarkMode) =>
      isDarkMode ? AppTextStyles.darkSmallStyle : AppTextStyles.lightSmallStyle;
      
  static TextStyle getCaptionStyle(bool isDarkMode) =>
      isDarkMode ? AppTextStyles.darkCaptionStyle : AppTextStyles.lightCaptionStyle;
      
  // Input decoration - for form fields
  static InputDecoration getInputDecoration({
    required BuildContext context,
    required String labelText,
    String? fieldLabel,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderSideColor = getDividerColor(isDark);
    
    return InputDecoration(
      hintText: labelText,
      hintStyle: getCaptionStyle(isDark),
      prefixIcon: prefixIcon != null
          ? Icon(
              prefixIcon,
              color: getSecondaryTextColor(isDark),
              size: 20,
            )
          : null,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: borderSideColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: borderSideColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: getPrimaryTextColor(isDark), width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(
          color: isDark ? Colors.red.shade300 : Colors.red.shade700,
          width: 1,
        ),
      ),
      errorStyle: TextStyle(
        fontSize: 12,
        color: isDark ? Colors.red.shade300 : Colors.red.shade700,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: false,
      floatingLabelBehavior: FloatingLabelBehavior.never,
    );
  }

  // Card decoration - for cards and containers
  static BoxDecoration getCardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: getCardColor(isDark),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: isDark ? AppColors.darkShadowColor : AppColors.lightShadowColor,
          blurRadius: 15,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ],
    );
  }
} 
