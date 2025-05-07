import 'package:flutter/material.dart';
import 'package:spending_income/utils/app_theme/index.dart';

class OnboardingPageData {
  final String title;
  final String description;
  final IconData image;
  final Color backgroundColor;

  OnboardingPageData({
    required this.title,
    required this.description,
    required this.image,
    required this.backgroundColor,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingPageData data;
  final bool isDark;

  const OnboardingPage({super.key, required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image container with icon
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: data.backgroundColor.withAlpha(26),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: data.backgroundColor.withAlpha(51),
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(data.image, size: 70, color: data.backgroundColor),
            ),
          ),

          const SizedBox(height: 40),

          // Title
          Text(
            data.title,
            style: AppThemeHelpers.getHeadingStyle(isDark).copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Container(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Text(
              data.description,
              style: AppThemeHelpers.getBodyStyle(
                isDark,
              ).copyWith(height: 1.5, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}



