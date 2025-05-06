import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import google_fonts

/// AppTheme provides a centralized location for all styling in the app
/// including colors, text styles, input decorations, and button styles.
class AppTheme {
  AppTheme._(); // Private constructor to prevent instantiation

  // Main color palette - Based on Image (Black/White/Gray)
  static const Color primaryBlack = Color(0xFF000000); // Primary black
  static const Color white = Color(0xFFFFFFFF); // White
  static const Color lightGray = Color(
    0xFFF1F1F1,
  ); // Light gray for borders/backgrounds
  static const Color mediumGray = Color(
    0xFFB3B3B3,
  ); // Medium gray for hints/secondary text
  static const Color darkGray = Color(
    0xFF666666,
  ); // Darker gray for labels/secondary text
  static const Color nearBlack = Color(
    0xFF1A1A1A,
  ); // Slightly off-black for dark background

  // --- Re-evaluate Accent Colors based on new theme ---
  // These might not be used as prominently if sticking to the image's B&W theme
  static const Color accentYellow = Color(
    0xFFFFB800,
  ); // Keeping defined, but maybe unused
  static const Color accentYellowDark = Color(0xFFFFD04B);
  static const Color accentGreen = Color(
    0xFF22C55E,
  ); // Keeping defined, but maybe unused
  static const Color accentGreenDark = Color(0xFF4ADE80);
  // --- Primary color reference for themes ---
  // Light theme uses Black as primary action color
  // Dark theme will use a contrasting color (white)
  static const Color lightPrimaryAction = primaryBlack;
  static const Color darkPrimaryAction = white;

  // Light mode colors - Based on Image
  static const Color lightBackground = white; // White background
  static const Color lightPrimaryText = primaryBlack; // Black text
  static const Color lightSecondaryText =
      darkGray; // Dark Gray text for labels/secondary info
  static const Color lightTertiaryText =
      mediumGray; // Medium Gray text for hints
  static const Color lightCardColor = white; // Cards are white
  static const Color lightDividerColor =
      lightGray; // Light gray dividers/borders
  static const Color lightShadowColor = Color(
    0x0D000000,
  ); // Very subtle black shadow (8%)

  // Dark mode colors - Inverted B&W theme
  static const Color darkBackground = nearBlack; // Near-black background
  static const Color darkCardBackground = Color(
    0xFF2C2C2C,
  ); // Dark gray surface
  static const Color darkPrimaryText = white; // White text
  static const Color darkSecondaryText = mediumGray; // Medium gray text
  static const Color darkTertiaryText = darkGray; // Darker gray for hints
  static const Color darkDividerColor = Color(0xFF3D3D3D); // Dark gray dividers
  static const Color darkShadowColor = Color(
    0x1A000000,
  ); // Subtle shadow on dark

  // Charts & data visualization colors - Keep previous ones or adapt?
  // Sticking to B&W might make charts hard to read. Let's keep the vibrant ones for now.
  static const List<Color> lightChartColors = [
    primaryBlack, // Use black as a primary chart color? Maybe keep blue? Let's keep previous colors.
    Color(0xFF246BFD), // Reverting chart colors to previous state
    accentYellow,
    accentGreen,
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
    Color(0xFFF97316),
    Color(0xFFA855F7),
  ];

  static const List<Color> darkChartColors = [
    Color(0xFF4B8EFF), // Reverting chart colors to previous state
    accentYellowDark,
    accentGreenDark,
    Color(0xFFF87171),
    Color(0xFFA78BFA),
    Color(0xFF22D3EE),
    Color(0xFFFB923C),
    Color(0xFFD8B4FE),
  ];

  // Text styles - Light Theme - Using 'Inter' font
  static TextStyle get lightHeadingStyle => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: lightPrimaryText,
    height: 1.3,
    letterSpacing: -0.5,
  );

  static TextStyle get lightSubheadingStyle => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: lightPrimaryText,
    height: 1.3,
    letterSpacing: -0.3,
  );

  static TextStyle get lightTitleStyle => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: lightPrimaryText,
    height: 1.3,
  );

  static TextStyle get lightBodyStyle => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: lightSecondaryText,
    height: 1.5,
  );

  static TextStyle get lightSmallStyle => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: lightTertiaryText,
    height: 1.4,
  );

  static TextStyle get lightCaptionStyle => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: lightTertiaryText,
    height: 1.3,
  );

  // Text styles - Dark Theme - Using 'Inter' font
  static TextStyle get darkHeadingStyle => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: darkPrimaryText,
    height: 1.3,
    letterSpacing: -0.5,
  );

  static TextStyle get darkSubheadingStyle => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: darkPrimaryText,
    height: 1.3,
    letterSpacing: -0.3,
  );

  static TextStyle get darkTitleStyle => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: darkPrimaryText,
    height: 1.3,
  );

  static TextStyle get darkBodyStyle => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: darkSecondaryText,
    height: 1.5,
  );

  static TextStyle get darkSmallStyle => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: darkTertiaryText,
    height: 1.4,
  );

  static TextStyle get darkCaptionStyle => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: darkTertiaryText,
    height: 1.3,
  );

  // Helper methods to get theme-appropriate styles and colors
  static Color getCardColor(bool isDarkMode) =>
      isDarkMode ? darkCardBackground : lightCardColor;
  static Color getBackgroundColor(bool isDarkMode) =>
      isDarkMode ? darkBackground : lightBackground;
  static Color getPrimaryTextColor(bool isDarkMode) =>
      isDarkMode ? darkPrimaryText : lightPrimaryText;
  static Color getSecondaryTextColor(bool isDarkMode) =>
      isDarkMode ? darkSecondaryText : lightSecondaryText;
  static Color getTertiaryTextColor(bool isDarkMode) => // Added helper
      isDarkMode ? darkTertiaryText : lightTertiaryText;
  static Color getDividerColor(bool isDarkMode) =>
      isDarkMode ? darkDividerColor : lightDividerColor;
  static List<Color> getChartColors(bool isDarkMode) =>
      isDarkMode ? darkChartColors : lightChartColors;
  // --- Primary Action Color Helper ---
  static Color getPrimaryColor(bool isDarkMode) =>
      isDarkMode ? darkPrimaryAction : lightPrimaryAction;
  // --- Accent Color Helpers (Keeping previous logic, may need adjustment based on usage) ---
  static Color getAccentYellow(bool isDarkMode) =>
      isDarkMode ? accentYellowDark : accentYellow;
  static Color getAccentGreen(bool isDarkMode) =>
      isDarkMode ? accentGreenDark : accentGreen;

  static TextStyle getHeadingStyle(bool isDarkMode) =>
      isDarkMode ? darkHeadingStyle : lightHeadingStyle;
  static TextStyle getSubheadingStyle(bool isDarkMode) =>
      isDarkMode ? darkSubheadingStyle : lightSubheadingStyle;
  static TextStyle getTitleStyle(bool isDarkMode) =>
      isDarkMode ? darkTitleStyle : lightTitleStyle;
  static TextStyle getBodyStyle(bool isDarkMode) =>
      isDarkMode ? darkBodyStyle : lightBodyStyle;
  static TextStyle getSmallStyle(bool isDarkMode) =>
      isDarkMode ? darkSmallStyle : lightSmallStyle;
  static TextStyle getCaptionStyle(bool isDarkMode) =>
      isDarkMode
          ? darkCaptionStyle
          : lightCaptionStyle; // Helper for Hint Text Style

  // Button styles - Context-aware for light/dark mode
  static ButtonStyle getPrimaryButtonStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ElevatedButton.styleFrom(
      backgroundColor: getPrimaryColor(isDark), // Black (light), White (dark)
      foregroundColor:
          isDark ? primaryBlack : white, // White (light), Black (dark)
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ), // Keep radius
      elevation: 0, // No elevation as per image
      textStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ), // Match inspiration button text
      padding: const EdgeInsets.symmetric(vertical: 12),
    );
  }

  static ButtonStyle getSecondaryButtonStyle(BuildContext context) {
    // Inspiration shows social buttons as simple outlined squares. Let's adapt this.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return OutlinedButton.styleFrom(
      backgroundColor: Colors.transparent, // No background
      foregroundColor: getPrimaryTextColor(isDark), // Text/icon color matches primary text
      minimumSize: const Size(56, 56), // Make it squarish
      maximumSize: const Size(64, 64),
      side: BorderSide(
        color: getDividerColor(isDark), // Border color matches divider
        width: 1.5, // Slightly thicker border maybe?
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ), // Match other radius
      padding: const EdgeInsets.all(12),
      elevation: 0,
    );
  }

  // --- New Style for Social Buttons ---
  static ButtonStyle getOutlinedSocialButtonStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return OutlinedButton.styleFrom(
      backgroundColor: Colors.transparent, // No background fill
      foregroundColor: getPrimaryTextColor(isDark), // Icon color
      minimumSize: const Size(60, 60), // Fixed square size
      maximumSize: const Size(60, 60),
      padding: EdgeInsets.zero, // Let the icon/image determine padding implicitly
      side: BorderSide(
        color: getDividerColor(isDark), // Use divider color for border
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Slightly more rounded corners for social icons
      ),
      elevation: 0,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Minimize tap area outside button
    );
  }

  static ButtonStyle getTextButtonStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextButton.styleFrom(
      foregroundColor: getPrimaryColor(isDark), // Black (light), White (dark)
      textStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ), // Match style from screens
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 8,
      ), // Minimal padding
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ), // Smaller radius?
      minimumSize: Size(0, 30), // Smaller minimum size
    );
  }

  // Input decoration - Context-aware for light/dark mode
  static InputDecoration getInputDecoration({
    required BuildContext context,
    required String labelText, // This will now act as HINT text
    String? fieldLabel, // Optional label ABOVE the field
    IconData? prefixIcon, // Keep option, but default to null
    Widget? suffixIcon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderSideColor = getDividerColor(isDark); // Use divider color for border
    
    return InputDecoration(
      // labelText is now the HINT text
      hintText: labelText,
      hintStyle: getCaptionStyle(isDark), // Use caption style for hint
      // floatingLabelBehavior: FloatingLabelBehavior.always, // Keep label always visible above if provided?
      // labelText: fieldLabel, // The actual label text above
      // labelStyle: getSmallStyle(isDark), // Use small style for the label above

      // Let's stick to the implementation in screens (Text widget above TextFormField)
      // Remove labelText/labelStyle from here if labels are handled outside
      prefixIcon:
          prefixIcon != null
              ? Icon(
                prefixIcon,
                color: getSecondaryTextColor(
                  isDark,
                ), // Use secondary text color for icons
                size: 20,
              )
              : null,
      suffixIcon: suffixIcon, // Keep suffix icon capability
      // Border styles
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(12),
        ), // Keep radius
        borderSide: BorderSide(
          color: borderSideColor,
          width: 1,
        ), // Standard border
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(
          color: borderSideColor,
          width: 1,
        ), // Standard border
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(
          color: getPrimaryTextColor(isDark),
          width: 1,
        ), // Use Primary Text color (Black/White) for focus
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(
          color:
              isDark
                  ? Colors.red.shade300
                  : Colors.red.shade700, // Keep error color
          width: 1,
        ),
      ),
      errorStyle: TextStyle(
        fontSize: 12,
        color: isDark ? Colors.red.shade300 : Colors.red.shade700,
      ), // Smaller error text

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ), // Keep padding
      filled: false, // Image inputs look like they have no fill, just border
      // fillColor: fillColor, // Removed fill
      floatingLabelBehavior:
          FloatingLabelBehavior
              .never, // Ensure label doesn't float if used accidently
    );
  }

  // Card decorations - Keep subtle shadow
  static BoxDecoration getCardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: getCardColor(isDark), // White (light), Dark Gray (dark)
      borderRadius: BorderRadius.circular(16), // Keep radius
      boxShadow: [
        BoxShadow(
          color:
              isDark ? darkShadowColor : lightShadowColor, // Use theme shadows
          blurRadius: 15,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ],
    );
  }

  // Create the light app theme
  static ThemeData buildLightTheme() {
    // Apply font globally using GoogleFonts textTheme method
    final textTheme = GoogleFonts.interTextTheme(ThemeData.light().textTheme);
    final customTextTheme = textTheme
        .copyWith(
          displayLarge: lightHeadingStyle,
          displayMedium: lightSubheadingStyle,
          titleLarge: lightTitleStyle,
          bodyLarge: lightBodyStyle,
          bodyMedium: lightSmallStyle,
          bodySmall: lightCaptionStyle,
          labelLarge: lightBodyStyle.copyWith(
            fontWeight: FontWeight.w500,
          ), // Button text
        )
        .apply(bodyColor: lightSecondaryText, displayColor: lightPrimaryText);

    final baseTheme = ThemeData.light(); // Start with base light theme
    return baseTheme.copyWith(
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: lightPrimaryAction, // Black
        onPrimary: white, // White text on black button
        secondary: darkGray, // Accent color? Using dark gray
        tertiary: mediumGray, // Another accent? Using medium gray
        onSecondary: white, // Text on secondary
        surface: lightCardColor, // White
        onSurface: lightPrimaryText, // Black text on surface
        error: Colors.red.shade700,
        onError: white,
      ),
      scaffoldBackgroundColor: lightBackground, // White
      appBarTheme: AppBarTheme(
        backgroundColor: lightBackground, // White background
        foregroundColor: lightPrimaryText, // Black text/icons
        elevation: 0, // No shadow
        centerTitle: false,
        shadowColor: Colors.transparent,
        titleTextStyle: lightTitleStyle, // Use the Inter style
        iconTheme: IconThemeData(color: lightPrimaryText), // Black icons
        actionsIconTheme: IconThemeData(color: lightPrimaryText), // Black icons
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white, // White background
        selectedItemColor: primaryBlack, // Black selected item
        unselectedItemColor: darkGray, // Gray unselected
        type: BottomNavigationBarType.fixed,
        elevation: 0, // No elevation
        showSelectedLabels: true, // Keep labels visible
        showUnselectedLabels: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryBlack, // Black FAB
        foregroundColor: white, // White icon
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)), // Keep radius
        ),
      ),
      cardTheme: CardTheme(
        color: lightCardColor, // White
        elevation: 0, // Remove elevation if using borders/shadows sparingly
        margin: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ), // Keep radius
        shadowColor: lightShadowColor, // Use theme shadow
      ),
      dividerColor: lightDividerColor, // Light gray
      textTheme: customTextTheme, // Apply the Inter font theme
      inputDecorationTheme: InputDecorationTheme(
        // Define global input theme
        hintStyle: lightCaptionStyle, // Medium gray hint
        prefixIconColor: lightSecondaryText, // Dark gray icon
        suffixIconColor: lightSecondaryText, // Dark gray icon
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightDividerColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightDividerColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: primaryBlack,
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
        labelStyle: lightSmallStyle, // Example: ensure label uses font
      ),
      buttonTheme: ButtonThemeData(
        // Legacy, but set for completeness
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        buttonColor: primaryBlack,
        textTheme: ButtonTextTheme.primary, // Ensures contrast text color
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlack, // Black text
          textStyle: lightSmallStyle.copyWith(
            fontWeight: FontWeight.w500,
            color: getPrimaryColor(false),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          minimumSize: Size(0, 30),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlack, // Black background
          foregroundColor: white, // White text
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
          foregroundColor: primaryBlack,
          minimumSize: const Size(52, 52),
          side: BorderSide(color: lightDividerColor, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          padding: const EdgeInsets.all(12),
          textStyle: textTheme.labelLarge?.copyWith(
            color: getPrimaryColor(false),
          ),
        ),
      ),
    );
  }

  // Create the dark app theme
  static ThemeData buildDarkTheme() {
    // Apply font globally using GoogleFonts textTheme method
    final textTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    final customTextTheme = textTheme
        .copyWith(
          displayLarge: darkHeadingStyle,
          displayMedium: darkSubheadingStyle,
          titleLarge: darkTitleStyle,
          bodyLarge: darkBodyStyle,
          bodyMedium: darkSmallStyle,
          bodySmall: darkCaptionStyle,
          labelLarge: darkBodyStyle.copyWith(
            fontWeight: FontWeight.w500,
            color: getPrimaryColor(false),
          ), // Button text color needs context?
        )
        .apply(bodyColor: darkSecondaryText, displayColor: darkPrimaryText);

    final baseTheme = ThemeData.dark(); // Start with base dark theme
    return baseTheme.copyWith(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: darkPrimaryAction, // White action color
        onPrimary: primaryBlack, // Black text on white button
        secondary: mediumGray, // Accent? Medium Gray
        tertiary: darkGray, // Accent? Dark Gray
        onSecondary: primaryBlack, // Text on secondary
        surface: darkCardBackground, // Dark Gray surface
        onSurface: darkPrimaryText, // White text
        error: Colors.red.shade300,
        onError: primaryBlack, // Black text on error color
      ),
      scaffoldBackgroundColor: darkBackground, // Near-black
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground, // Near-black background
        foregroundColor: darkPrimaryText, // White text/icons
        elevation: 0,
        centerTitle: false, // Match light theme default
        shadowColor: Colors.transparent,
        titleTextStyle: darkTitleStyle, // Use the Inter style
        iconTheme: IconThemeData(color: darkPrimaryText), // White icons
        actionsIconTheme: IconThemeData(color: darkPrimaryText), // White icons
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkCardBackground, // Dark gray background
        selectedItemColor: white, // White selected item
        unselectedItemColor: mediumGray, // Medium gray unselected
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: white, // White FAB
        foregroundColor: primaryBlack, // Black icon
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      cardTheme: CardTheme(
        color: darkCardBackground, // Dark Gray
        elevation: 0,
        margin: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: darkShadowColor, // Use theme shadow
      ),
      dividerColor: darkDividerColor, // Dark gray divider
      textTheme: customTextTheme, // Apply the Inter font theme
      inputDecorationTheme: InputDecorationTheme(
        // Define global input theme
        hintStyle: darkCaptionStyle, // Dark gray hint
        prefixIconColor: darkSecondaryText, // Medium gray icon
        suffixIconColor: darkSecondaryText, // Medium gray icon
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkDividerColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkDividerColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: white,
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
        labelStyle: darkSmallStyle,
      ),
      buttonTheme: ButtonThemeData(
        // Legacy
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        buttonColor: white, // White button background
        textTheme: ButtonTextTheme.primary, // Should ensure black text
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: white, // White text
          textStyle: darkSmallStyle.copyWith(
            fontWeight: FontWeight.w500,
            color: getPrimaryColor(true),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          minimumSize: Size(0, 30),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: white, // White background
          foregroundColor: primaryBlack, // Black text
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          textStyle: textTheme.labelLarge?.copyWith(
            color: getPrimaryColor(false),
          ), // Ensure correct color for dark
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        // Style for secondary/social buttons
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: white,
          minimumSize: const Size(52, 52),
          side: BorderSide(color: darkDividerColor, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          padding: const EdgeInsets.all(12),
          textStyle: textTheme.labelLarge?.copyWith(
            color: getPrimaryColor(true),
          ),
        ),
      ),
    );
  }
}
