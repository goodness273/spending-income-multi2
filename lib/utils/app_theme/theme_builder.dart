import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';
import 'text_styles.dart';

/// Contains methods to build complete light and dark themes
class AppThemeBuilder {
  AppThemeBuilder._(); // Private constructor to prevent instantiation

  /// Creates the light theme
  static ThemeData buildLightTheme() {
    // Apply font globally using GoogleFonts textTheme method
    final textTheme = GoogleFonts.interTextTheme(ThemeData.light().textTheme);
    final customTextTheme = textTheme
        .copyWith(
          displayLarge: AppTextStyles.lightHeadingStyle,
          displayMedium: AppTextStyles.lightSubheadingStyle,
          titleLarge: AppTextStyles.lightTitleStyle,
          bodyLarge: AppTextStyles.lightBodyStyle,
          bodyMedium: AppTextStyles.lightSmallStyle,
          bodySmall: AppTextStyles.lightCaptionStyle,
          labelLarge: AppTextStyles.lightBodyStyle.copyWith(
            fontWeight: FontWeight.w500,
          ), // Button text
        )
        .apply(bodyColor: AppColors.lightSecondaryText, displayColor: AppColors.lightPrimaryText);

    final baseTheme = ThemeData.light(); // Start with base light theme
    return baseTheme.copyWith(
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.lightPrimaryAction, // Black
        onPrimary: AppColors.white, // White text on black button
        secondary: AppColors.darkGray, // Accent color? Using dark gray
        tertiary: AppColors.mediumGray, // Another accent? Using medium gray
        onSecondary: AppColors.white, // Text on secondary
        surface: AppColors.lightCardColor, // White
        onSurface: AppColors.lightPrimaryText, // Black text on surface
        error: Colors.red.shade700,
        onError: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground, // White
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBackground, // White background
        foregroundColor: AppColors.lightPrimaryText, // Black text/icons
        elevation: 0, // No shadow
        centerTitle: false,
        shadowColor: Colors.transparent,
        titleTextStyle: AppTextStyles.lightTitleStyle, // Use the Inter style
        iconTheme: IconThemeData(color: AppColors.lightPrimaryText), // Black icons
        actionsIconTheme: IconThemeData(color: AppColors.lightPrimaryText), // Black icons
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white, // White background
        selectedItemColor: AppColors.primaryBlack, // Black selected item
        unselectedItemColor: AppColors.darkGray, // Gray unselected
        type: BottomNavigationBarType.fixed,
        elevation: 0, // No elevation
        showSelectedLabels: true, // Keep labels visible
        showUnselectedLabels: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryBlack, // Black FAB
        foregroundColor: AppColors.white, // White icon
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)), // Keep radius
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.lightCardColor, // White
        elevation: 0, // Remove elevation if using borders/shadows sparingly
        margin: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ), // Keep radius
        shadowColor: AppColors.lightShadowColor, // Use theme shadow
      ),
      dividerColor: AppColors.lightDividerColor, // Light gray
      textTheme: customTextTheme, // Apply the Inter font theme
      inputDecorationTheme: InputDecorationTheme(
        // Define global input theme
        hintStyle: AppTextStyles.lightCaptionStyle, // Medium gray hint
        prefixIconColor: AppColors.lightSecondaryText, // Dark gray icon
        suffixIconColor: AppColors.lightSecondaryText, // Dark gray icon
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightDividerColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightDividerColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primaryBlack,
            width: 1,
          ), // Black focus border
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade700, width: 1),
        ),
        errorStyle: TextStyle(fontSize: 12, color: Colors.red.shade700),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        filled: false, // No fill
        floatingLabelBehavior: FloatingLabelBehavior.never,
        labelStyle: AppTextStyles.lightSmallStyle, // Example: ensure label uses font
      ),
      buttonTheme: ButtonThemeData(
        // Legacy, but set for completeness
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        buttonColor: AppColors.primaryBlack,
        textTheme: ButtonTextTheme.primary, // Ensures contrast text color
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryBlack, // Black text
          textStyle: AppTextStyles.lightSmallStyle.copyWith(
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          minimumSize: const Size(0, 30),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlack, // Black background
          foregroundColor: AppColors.white, // White text
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          textStyle: textTheme.labelLarge, // Use themed button text style
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        // Style for secondary/social buttons
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primaryBlack,
          minimumSize: const Size(52, 52),
          side: BorderSide(color: AppColors.lightDividerColor, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          padding: const EdgeInsets.all(12),
          textStyle: textTheme.labelLarge,
        ),
      ),
    );
  }

  /// Creates the dark theme
  static ThemeData buildDarkTheme() {
    // Apply font globally using GoogleFonts textTheme method
    final textTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    final customTextTheme = textTheme
        .copyWith(
          displayLarge: AppTextStyles.darkHeadingStyle,
          displayMedium: AppTextStyles.darkSubheadingStyle,
          titleLarge: AppTextStyles.darkTitleStyle,
          bodyLarge: AppTextStyles.darkBodyStyle,
          bodyMedium: AppTextStyles.darkSmallStyle,
          bodySmall: AppTextStyles.darkCaptionStyle,
          labelLarge: AppTextStyles.darkBodyStyle.copyWith(
            fontWeight: FontWeight.w500,
          ), // Button text
        )
        .apply(bodyColor: AppColors.darkSecondaryText, displayColor: AppColors.darkPrimaryText);

    final baseTheme = ThemeData.dark(); // Start with base dark theme
    return baseTheme.copyWith(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.darkPrimaryAction, // White action color
        onPrimary: AppColors.primaryBlack, // Black text on white button
        secondary: AppColors.mediumGray, // Accent? Medium Gray
        tertiary: AppColors.darkGray, // Accent? Dark Gray
        onSecondary: AppColors.primaryBlack, // Text on secondary
        surface: AppColors.darkCardBackground, // Dark Gray surface
        onSurface: AppColors.darkPrimaryText, // White text
        error: Colors.red.shade300,
        onError: AppColors.primaryBlack, // Black text on error color
      ),
      scaffoldBackgroundColor: AppColors.darkBackground, // Near-black
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground, // Near-black background
        foregroundColor: AppColors.darkPrimaryText, // White text/icons
        elevation: 0,
        centerTitle: false, // Match light theme default
        shadowColor: Colors.transparent,
        titleTextStyle: AppTextStyles.darkTitleStyle, // Use the Inter style
        iconTheme: IconThemeData(color: AppColors.darkPrimaryText), // White icons
        actionsIconTheme: IconThemeData(color: AppColors.darkPrimaryText), // White icons
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkCardBackground, // Dark gray background
        selectedItemColor: AppColors.white, // White selected item
        unselectedItemColor: AppColors.mediumGray, // Medium gray unselected
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.white, // White FAB
        foregroundColor: AppColors.primaryBlack, // Black icon
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.darkCardBackground, // Dark Gray
        elevation: 0,
        margin: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: AppColors.darkShadowColor, // Use theme shadow
      ),
      dividerColor: AppColors.darkDividerColor, // Dark gray divider
      textTheme: customTextTheme, // Apply the Inter font theme
      inputDecorationTheme: InputDecorationTheme(
        // Define global input theme
        hintStyle: AppTextStyles.darkCaptionStyle, // Dark gray hint
        prefixIconColor: AppColors.darkSecondaryText, // Medium gray icon
        suffixIconColor: AppColors.darkSecondaryText, // Medium gray icon
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.darkDividerColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.darkDividerColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.white,
            width: 1,
          ), // White focus border
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade300, width: 1),
        ),
        errorStyle: TextStyle(fontSize: 12, color: Colors.red.shade300),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        filled: false, // No fill
        floatingLabelBehavior: FloatingLabelBehavior.never,
        labelStyle: AppTextStyles.darkSmallStyle,
      ),
      buttonTheme: ButtonThemeData(
        // Legacy
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        buttonColor: AppColors.white, // White button background
        textTheme: ButtonTextTheme.primary, // Should ensure black text
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.white, // White text
          textStyle: AppTextStyles.darkSmallStyle.copyWith(
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          minimumSize: const Size(0, 30),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.white, // White background
          foregroundColor: AppColors.primaryBlack, // Black text
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          textStyle: textTheme.labelLarge, // Ensure correct color for dark
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        // Style for secondary/social buttons
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.white,
          minimumSize: const Size(52, 52),
          side: BorderSide(color: AppColors.darkDividerColor, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          padding: const EdgeInsets.all(12),
          textStyle: textTheme.labelLarge,
        ),
      ),
    );
  }
} 
