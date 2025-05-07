import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Contains all text styles used throughout the app
class AppTextStyles {
  // Private constructor to prevent instantiation
  AppTextStyles._();

  // Text styles - Light Theme - Using 'Inter' font
  static TextStyle get lightHeadingStyle => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.lightPrimaryText,
    height: 1.3,
    letterSpacing: -0.5,
  );

  static TextStyle get lightSubheadingStyle => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.lightPrimaryText,
    height: 1.3,
    letterSpacing: -0.3,
  );

  static TextStyle get lightTitleStyle => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.lightPrimaryText,
    height: 1.3,
  );

  static TextStyle get lightBodyStyle => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.lightSecondaryText,
    height: 1.5,
  );

  static TextStyle get lightSmallStyle => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.lightTertiaryText,
    height: 1.4,
  );

  static TextStyle get lightCaptionStyle => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.lightTertiaryText,
    height: 1.3,
  );

  // Text styles - Dark Theme - Using 'Inter' font
  static TextStyle get darkHeadingStyle => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.darkPrimaryText,
    height: 1.3,
    letterSpacing: -0.5,
  );

  static TextStyle get darkSubheadingStyle => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.darkPrimaryText,
    height: 1.3,
    letterSpacing: -0.3,
  );

  static TextStyle get darkTitleStyle => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.darkPrimaryText,
    height: 1.3,
  );

  static TextStyle get darkBodyStyle => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.darkSecondaryText,
    height: 1.5,
  );

  static TextStyle get darkSmallStyle => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.darkTertiaryText,
    height: 1.4,
  );

  static TextStyle get darkCaptionStyle => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.darkTertiaryText,
    height: 1.3,
  );
} 
