import 'package:flutter/material.dart';

/// Contains all color constants used throughout the app
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Main color palette - Based on Image (Black/White/Gray)
  static const Color primaryBlack = Color(0xFF000000); // Primary black
  static const Color white = Color(0xFFFFFFFF); // White
  static const Color lightGray = Color(0xFFF1F1F1); // Light gray for borders/backgrounds
  static const Color mediumGray = Color(0xFFB3B3B3); // Medium gray for hints/secondary text
  static const Color darkGray = Color(0xFF666666); // Darker gray for labels/secondary text
  static const Color nearBlack = Color(0xFF1A1A1A); // Slightly off-black for dark background

  // Accent Colors
  static const Color accentYellow = Color(0xFFFFB800); 
  static const Color accentYellowDark = Color(0xFFFFD04B);
  static const Color accentGreen = Color(0xFF22C55E);
  static const Color accentGreenDark = Color(0xFF4ADE80);
  
  // Primary color reference for themes
  static const Color lightPrimaryAction = primaryBlack;
  static const Color darkPrimaryAction = white;

  // Light mode colors
  static const Color lightBackground = white; 
  static const Color lightPrimaryText = primaryBlack;
  static const Color lightSecondaryText = darkGray;
  static const Color lightTertiaryText = mediumGray;
  static const Color lightCardColor = white;
  static const Color lightDividerColor = lightGray;
  static const Color lightShadowColor = Color(0x0D000000); // Very subtle black shadow (8%)

  // Dark mode colors
  static const Color darkBackground = nearBlack;
  static const Color darkCardBackground = Color(0xFF2C2C2C);
  static const Color darkPrimaryText = white;
  static const Color darkSecondaryText = mediumGray;
  static const Color darkTertiaryText = darkGray;
  static const Color darkDividerColor = Color(0xFF3D3D3D);
  static const Color darkShadowColor = Color(0x1A000000); // Subtle shadow on dark

  // Charts & data visualization colors
  static const List<Color> lightChartColors = [
    primaryBlack,
    Color(0xFF246BFD),
    accentYellow,
    accentGreen,
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
    Color(0xFFF97316),
    Color(0xFFA855F7),
  ];

  static const List<Color> darkChartColors = [
    Color(0xFF4B8EFF),
    accentYellowDark,
    accentGreenDark,
    Color(0xFFF87171),
    Color(0xFFA78BFA),
    Color(0xFF22D3EE),
    Color(0xFFFB923C),
    Color(0xFFD8B4FE),
  ];
} 
