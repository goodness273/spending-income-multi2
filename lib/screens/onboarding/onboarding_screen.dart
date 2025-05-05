import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/app_theme.dart';
import '../auth/auth_wrapper.dart';
import '../../providers/preferences_provider.dart';
import 'onboarding_page.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _numPages = 3;

  List<OnboardingPageData> onboardingPages = [];

  @override
  void initState() {
    super.initState();
    // We'll set up the pages in didChangeDependencies to have access to context
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Initialize the pages here so we can use the context to get proper theme colors
    onboardingPages = [
      OnboardingPageData(
        title: 'Track Your Finances',
        description:
            'Easily record and categorize your income and expenses with just a few taps.',
        image: Icons.account_balance_wallet_outlined,
        backgroundColor: AppTheme.getPrimaryColor(isDark),
      ),
      OnboardingPageData(
        title: 'Visualize Your Spending',
        description:
            'See where your money goes with beautiful charts and detailed reports.',
        image: Icons.pie_chart_outline,
        backgroundColor: AppTheme.getPrimaryColor(isDark),
      ),
      OnboardingPageData(
        title: 'Reach Your Goals',
        description:
            'Set budgets and financial goals to help you save and stay on track.',
        image: Icons.emoji_events_outlined,
        backgroundColor: AppTheme.getPrimaryColor(isDark),
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _completeOnboarding() async {
    // Mark onboarding as completed
    await ref.read(preferencesProvider.notifier).setOnboardingCompleted(true);

    // Navigate to auth wrapper
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(isDark),
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.getPrimaryColor(isDark),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    'Skip',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),

            // Onboarding pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _numPages,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  return OnboardingPage(
                    data: onboardingPages[index],
                    isDark: isDark,
                  );
                },
              ),
            ),

            // Indicators and buttons
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 40.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page indicators
                  Row(
                    children: List.generate(
                      _numPages,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color:
                              _currentPage == index
                                  ? AppTheme.getPrimaryColor(isDark)
                                  : (isDark
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ),

                  // Next/Get Started button
                  SizedBox(
                    width: 140, // Fixed width for the button
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _numPages - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        } else {
                          _completeOnboarding();
                        }
                      },
                      child: Text(
                        _currentPage < _numPages - 1 ? 'Next' : 'Get Started',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
