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
      
  static Color getAccentRed(bool isDarkMode) =>
      isDarkMode ? AppColors.accentRedDark : AppColors.accentRed;
      
  // Category color helper
  static Color getCategoryColor(bool isDarkMode, String category) {
    final categoryMap = isDarkMode
        ? AppColors.darkCategoryColors
        : AppColors.lightCategoryColors;
    
    // Normalize category name for color lookup
    final normalizedCategory = _normalizeCategoryForColor(category);
    
    return categoryMap[normalizedCategory] ?? 
        (isDarkMode ? AppColors.darkTertiaryText : AppColors.lightTertiaryText);
  }
  
  // Helper to normalize category names for color lookups
  static String _normalizeCategoryForColor(String category) {
    // Handle possible alternate forms/variations of category names
    switch (category.toLowerCase()) {
      case 'health':
        return 'Health';
      case 'healthcare':
        return 'Health';
      case 'transport':
        return 'Transport';
      case 'transportation':
        return 'Transport';
      case 'food':
        return 'Food & Dining';
      case 'food & dining':
        return 'Food & Dining';
      case 'gift':
        return 'Gifts';
      case 'gifts':
        return 'Gifts';
      case 'freelance':
        return 'Business';
      case 'saving':
        return 'Savings';
      case 'lend':
      case 'loan':
        return 'Lending';
      case 'return':
        return 'Returns';
      case 'repayment':
        return 'Repayments';
      default:
        return category;
    }
  }

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
