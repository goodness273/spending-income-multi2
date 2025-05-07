import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../utils/auth_error_handler.dart';
import 'package:spending_income/utils/app_theme/index.dart';
// import '../../utils/ui_components.dart'; // Removing dependency

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _message = null;
        _isSuccess = false; // Reset success state
      });

      try {
        final authNotifier = ref.read(authNotifierProvider.notifier);
        await authNotifier.resetPassword(_emailController.text.trim());

        if (mounted) {
          setState(() {
            _isSuccess = true;
            _message =
                'Password reset email has been sent to ${_emailController.text.trim()}.';
            _emailController.clear(); // Clear field on success
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSuccess = false;
            _message = AuthErrorHandler.handleError(e);
          });
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot password?'), // Match inspiration title
        centerTitle: false,
        elevation: 0,
        backgroundColor: AppThemeHelpers.getBackgroundColor(isDark),
      ),
      backgroundColor: AppThemeHelpers.getBackgroundColor(isDark),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  Text(
                    'Forgot password?',
                    style: AppThemeHelpers.getHeadingStyle(
                      isDark,
                    ).copyWith(fontSize: 32),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 12),
                  // Subtitle/Description from inspiration
                  Text(
                    'Don\'t worry! It happens. Please enter the email address associated with your account.',
                    style: AppThemeHelpers.getBodyStyle(isDark),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 32),

                  // Email field with Label
                  Text(
                    'Email address', // Label text
                    style: AppThemeHelpers.getSmallStyle(isDark).copyWith(
                      color: AppThemeHelpers.getSecondaryTextColor(isDark),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    decoration: AppThemeHelpers.getInputDecoration(
                      context: context,
                      labelText: 'Enter your email address',
                      prefixIcon: null,
                    ).copyWith(
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      labelStyle: AppThemeHelpers.getBodyStyle(isDark).copyWith(
                        color:
                            isDark
                                ? AppColors.darkTertiaryText
                                : AppColors.lightTertiaryText,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32), // Spacing before message/button
                  // Message (Success or Error)
                  if (_message != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _message!,
                        style: TextStyle(
                          color:
                              _isSuccess
                                  ? (isDark
                                      ? AppColors.accentGreenDark
                                      : AppColors.accentGreen) // Use theme success color
                                  : (isDark
                                      ? Colors.red.shade300
                                      : Colors.red.shade700),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Reset Button
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _resetPassword,
                      style: AppButtonStyles.getPrimaryButtonStyle(context),
                      child: _isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: isDark ? AppColors.primaryBlack : AppColors.white, // Ensure correct contrast
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Send link', // Match inspiration text
                              style: AppThemeHelpers.getBodyStyle(isDark).copyWith(
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppColors.primaryBlack : AppColors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24), // Spacing before login link
                  // Login link (Remember Password?)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Remember password?',
                        style: AppThemeHelpers.getBodyStyle(
                          isDark,
                        ).copyWith(fontSize: 14),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: AppButtonStyles.getTextButtonStyle(context).copyWith(
                          padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(horizontal: 4.0),
                          ),
                        ),
                        child: Text(
                          'Log in',
                          style: AppThemeHelpers.getBodyStyle(isDark).copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppThemeHelpers.getPrimaryColor(isDark),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16), // Bottom padding
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



